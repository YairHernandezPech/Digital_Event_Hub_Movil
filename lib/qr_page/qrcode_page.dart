import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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
    fetchHorarios(
        widget.eventoId); // Llama a la función para obtener los horarios
  }

  Future<void> fetchHorarios(int eventoId) async {
    final response = await http.get(Uri.parse(
        'https://api-digital.fly.dev/api/schedule/by-event/$eventoId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      horarios = data
          .map((json) => Horario.fromJson(json))
          .toList(); // Usa el modelo Horario
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

      // Diálogo de éxito con diseño mejorado
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: '¡Éxito!',
        desc: 'El QR ha sido descargado exitosamente.',
        autoDismiss: true,
        dismissOnTouchOutside: false,
        padding: const EdgeInsets.all(25),
        dialogBorderRadius: BorderRadius.circular(15),
        headerAnimationLoop: false,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        descTextStyle: const TextStyle(
          fontSize: 18,
          color: Colors.black54,
          height: 1.5,
        ),
      ).show();

      await Future.delayed(const Duration(seconds: 3));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      // Diálogo de error mejorado
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: '¡Error!',
        desc: 'Ocurrió un problema al descargar el QR.',
        padding: const EdgeInsets.all(25),
        dialogBorderRadius: BorderRadius.circular(15),
        headerAnimationLoop: false,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.redAccent,
        ),
        descTextStyle: const TextStyle(
          fontSize: 18,
          color: Colors.black54,
          height: 1.5,
        ),
      ).show();
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

      print(
          'Respuesta de verificar código: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body)['message'];
      } else {
        throw Exception('Código no válido o error en la API');
      }
    } catch (e) {
      // Manejo de errores
      /*
    if (!context.mounted) 
      return 'Error'; // Verifica que el contexto esté montado

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al verificar el código: $e')),
    );
    */
      return 'Error'; // Retorna un mensaje de error
    }
  }

  Future<void> redeemCode(String code) async {
    try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');
      final response = await http.post(
        Uri.parse('https://api-digital.fly.dev/api/ticket/redeem'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
          },
        body: jsonEncode({
          'evento_id': widget.eventoId, // Enviar el evento ID
          'code': code, // Enviar el código introducido
          'horario_id': selectedHorarioId // Enviar el horario ID
        }),
      );
      print(
          'Respuesta de canjear código: ${response.statusCode} - ${response.body}'); // Imprimir respuesta

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

  void _showDialog(BuildContext context) {
    String? errorMessage; // Variable para almacenar el mensaje de error.
 

    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      padding: const EdgeInsets.all(16),
      dialogBackgroundColor: Colors.white,
      borderSide: BorderSide(
        color: const Color.fromARGB(255, 229, 226, 235),
        width: 2,
      ),
      body: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer, color: Colors.deepPurple, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    "Introducir Cupón",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Ingrese su código promocional a continuación:",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                 controller: _textController, 
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                  hintText: 'Ingrese su código promocional',
                  fillColor: Colors.grey[200],
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                 
                  setState(() {
                  data = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              if (errorMessage !=
                  null) // Mostrar el mensaje de error si existe.
                Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () async {
                  // Validar el código antes de proceder.
                   final String code = _textController.text;
                  String? validationMessage = validateCode(code);
                  if (validationMessage != null) {
                    setState(() {
                      errorMessage =
                          validationMessage; // Actualizar el mensaje de error.
                    });
                    return; // Detener si la validación falla.
                  }

                  // Verificar el código en el servidor.
                  String message = await checkCode(code);
                  if (message == 'Error') {
                    setState(() {
                      errorMessage =
                          'Código inválido o error del servidor.'; // Mensaje de error.
                    });
                    return;
                  } else if (message == 'El cupón ya ha sido canjeado.') {
                    setState(() {
                      errorMessage =
                          'Este cupón ya ha sido canjeado.'; // Mensaje para cupón canjeado.
                    });
                    // No cerramos el diálogo, solo mostramos el mensaje.
                    return;
                  }

                  // Si el código es válido y puede ser canjeado.
                  if (message == "El cupón es válido y puede ser canjeado.") {
                    await redeemCode(code); // Canjear el código.
                    await _captureAndSavePdf(); // Generar el PDF.
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(
                    //       content: Text('Código canjeado con éxito')),
                    // );
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(
                  "Canjear",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ).show();
  }

// Función de validación del código
  String? validateCode(String code) {
    if (code.isEmpty) {
      return "El código no puede estar vacío.";
    }
    if (code.length < 5) {
      return "El código debe tener al menos 5 caracteres.";
    }
    // Agrega otras validaciones según tus requisitos
    return null; // Si todo está bien, retorna null
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
                String inicio =
                    horario.horaInicio.substring(0, 5); // Puedes formatear aquí
                String fin =
                    horario.horaFin.substring(0, 5); 
                selectedHorarioId = horario.horarioId;    // Puedes formatear aquí
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
                  _showDialog(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Canjear Boleto",
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
