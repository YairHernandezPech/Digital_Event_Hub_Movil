import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:open_file/open_file.dart';

class QrcodePage extends StatefulWidget {
  final String imageUrl;
  final String eventName;

  const QrcodePage({
    super.key,
    required this.imageUrl,
    required this.eventName,
  });

  @override
  State<QrcodePage> createState() => _QrcodePageState();
}

class _QrcodePageState extends State<QrcodePage> {
  final TextEditingController _textController = TextEditingController(text: '');
  String data = '';
  String? selectedHorario;
  bool showTicketInfo = false;

  dynamic externalDir = '/storage/emulated/0/Download/Qr_code';

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
                    await _captureAndSavePdf(); // Generar y guardar el PDF
                    if (!context.mounted) return;
                    Navigator.pop(context); // Cerrar el diálogo
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
              children: [
                _horarioBox("10:00 AM", "11:00 PM"),
                _horarioBox("2:00 PM", "10:00 PM"),
                _horarioBox("5:00 PM", "12:00 PM"),
              ],
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
