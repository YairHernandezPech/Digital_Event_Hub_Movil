import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Horario {
  final int horarioId;
  final int eventoId;
  final String horaInicio;
  final String horaFin;

  Horario({
    required this.horarioId,
    required this.eventoId,
    required this.horaInicio,
    required this.horaFin,
  });

  // Método para crear una instancia de Horario a partir de un mapa
  factory Horario.fromJson(Map<String, dynamic> json) {
    return Horario(
      horarioId: json['horario_id'],
      eventoId: json['evento_id'],
      horaInicio: json['hora_inicio'],
      horaFin: json['hora_fin'],
    );
  }
}


class QrcodePage extends StatefulWidget {
  final String imageUrl;
  final String eventName;
  final int eventoId;

  const QrcodePage({
    super.key,
    required this.imageUrl,
    required this.eventName,
    required this.eventoId,
  });

  @override
  State<QrcodePage> createState() => _QrcodePageState();
}

class _QrcodePageState extends State<QrcodePage> {
  final TextEditingController _textController = TextEditingController(text: '');
  String data = '';
  String? selectedHorario;
  int? selectedHorarioId; // Nuevo campo para almacenar el ID del horario
  bool showTicketInfo = false;

  List<Horario> horarios = [];

  dynamic externalDir = '/storage/emulated/0/Download/Qr_code';

  

   @override
  void initState() {
    super.initState();
    fetchHorarios(widget.eventoId); // Llama a la función para obtener los horarios
  }

 Future<void> fetchHorarios(int eventoId) async {
    final response = await http.get(Uri.parse('https://api-digital.fly.dev/api/schedule/by-event/$eventoId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      horarios = data.map((json) => Horario.fromJson(json)).toList(); // Usa el modelo Horario
      setState(() {});
      print("el id de: $eventoId");
    } else {
      throw Exception('Failed to load horarios');
    }
  }

  // Solicitar permiso para escribir en el almacenamiento
  Future<void> _requestPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  // Función para guardar el archivo PDF y abrirlo después de la descarga
  Future<void> _captureAndSavePdf() async {
    try {
      // Crear el documento PDF
      final pdf = pw.Document();

      // Generar el código QR como imagen
      final qrImage = QrPainter(
        data: data,
        version: QrVersions.auto,
        gapless: true,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
      );
      final image = await qrImage.toImage(200);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

// Agregar la información al PDF
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Container(
                padding: pw.EdgeInsets.all(24),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Evento: ${widget.eventName}',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueAccent,
                      ),
                    ),
                    pw.SizedBox(height: 15),
                    pw.Text(
                      'Horario: $selectedHorario',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 22,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 30),
                    pw.Center(
                      child: pw.Container(
                        width: 430,
                        height: 430,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: PdfColors.blueAccent,
                            width: 2,
                          ),
                          borderRadius: pw.BorderRadius.circular(15),
                        ),
                        child: pw.Center(
                          // Centrar el QR dentro del contenedor
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Image(
                              pw.MemoryImage(pngBytes),
                              width: 400,
                              height: 400,
                              fit: pw.BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      '¡Gracias por asistir!',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 18,
                        color: PdfColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Verificar permisos
      await _requestPermission();

      // Definir la ruta de guardado
      Directory? externalDir =
          Directory('/storage/emulated/0/Download/Qr_code');

      // Verificar si el directorio existe, si no, crearlo
      if (!await externalDir.exists()) {
        await externalDir.create(recursive: true);
      }

      // Guardar el PDF en la ubicación especificada
      String filePath =
          "${externalDir.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.pdf";
      File file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;

      // Abrir el archivo PDF después de guardarlo
      await OpenFile.open(filePath);

      // Mostrar mensaje de éxito
      const snackBar =
          SnackBar(content: Text('QR code saved and downloaded as PDF.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      if (!mounted) return;
      const snackBar = SnackBar(content: Text('Something went wrong!!!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

   // Función para verificar el código
Future<String> checkCode(String code) async {
  try {
    final response = await http.post(
      Uri.parse('https://api-digital.fly.dev/api/ticket/check'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code}), // Envía el código introducido
    );

    print('Respuesta de verificar código: ${response.statusCode} - ${response.body}'); // Imprimir respuesta

    if (response.statusCode == 200) {
      return json.decode(response.body)['message']; // Retorna el mensaje de éxito
    } else {
      throw Exception('Código no válido o error en la API');
    }
  } catch (e) {
    // Manejo de errores
    if (!context.mounted) return 'Error'; // Verifica que el contexto esté montado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al verificar el código: $e')),
    );
    return 'Error'; // Retorna un mensaje de error
  }
}

Future<void> redeemCode(String code) async {
  try {
    final response = await http.post(
      Uri.parse('https://api-digital.fly.dev/api/ticket/redeem'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'evento_id': widget.eventoId, // Enviar el evento ID
        'code': code,                  // Enviar el código introducido
        'horario_id': selectedHorarioId // Enviar el horario ID
      }),
    );
  print('Respuesta de canjear código: ${response.statusCode} - ${response.body}'); // Imprimir respuesta

    if (response.statusCode == 200) {
      print('Código canjeado con éxito');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Código canjeado con éxito')),
      );
    } else {
      throw Exception('Error al canjear el código: ${response.body}');
    }
  } catch (e) {
    // Manejo de errores
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al canjear el código: $e')),
    );
  }
}

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text("Información de Pago"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                     controller: _textController, 
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Ingrese su código promocional',
                    ),
                    onChanged: (value) {
                      setState(() {
                        data = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                      final String code = _textController.text; // Obtener el código del TextController

                  // Primero verificar el código
                  String message = await checkCode(code);

                  if (message == 'Error') {
                    return; // Si hay un error, no hacemos nada más
                  }

                  // Mostrar el mensaje de verificación en el SnackBar
                  if (!context.mounted) return; // Verificar si el contexto está montado
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

                  // Si el mensaje indica que el cupón es válido, proceder a canjearlo
                  if (message == "El cupón es válido y puede ser canjeado.") {
                    await redeemCode(code); // Canjear el código
                    await _captureAndSavePdf(); // Lógica para capturar y guardar el PDF

                    if (!context.mounted) return; // Verificar si el contexto está montado
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Código canjeado con éxito')));

                    Navigator.pop(context); // Cerrar el diálogo
                  }
                  },
                  child: Text("Canjear"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: Image.network(
                    widget.imageUrl,
                    width: double.infinity,
                    height: 350,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Seleccionar un horario',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildHorarioSelector(),
            SizedBox(height: 20),
            if (showTicketInfo) _buildTicketInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHorarioSelector() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              "Selecciona Horario",
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 40,
                runSpacing: 15,
                alignment: WrapAlignment.center,
                children: horarios.map((horario) {
                  String inicio = horario.horaInicio.substring(0, 5); // Puedes formatear aquí
                  String fin = horario.horaFin.substring(0, 5); // Puedes formatear aquí
                  return _horarioBox(inicio, fin);
                }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _horarioBox(String inicio, String fin) {
    final isSelected = selectedHorario == "$inicio - $fin";
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedHorario = "$inicio - $fin";
          showTicketInfo = true;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey[300]!,
            width: 2,
          ),
          color: isSelected ? Colors.purple : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              inicio,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.deepPurple,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              fin,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.deepPurple,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.deepPurpleAccent],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Comprar Boleto',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Evento:",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 5),
            Text(
              widget.eventName,
              style: TextStyle(
                fontSize: 22,
                color: selectedHorario == null
                    ? Colors.black.withOpacity(0.6)
                    : Colors.deepPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Horario:",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 5),
            Text(
              selectedHorario ?? '',
              style: TextStyle(
                fontSize: 20,
                color: Colors.deepPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () {
                  _showDialog();
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Procesar Pago",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
