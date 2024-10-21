import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/widgets.dart' as pw;

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
  final GlobalKey _qrkey = GlobalKey();
  bool dirExists = false;
  dynamic externalDir = '/storage/emulated/0/Download/Qr_code';
  String? selectedHorario;
  bool showTicketInfo = false;

   // Solicitar permiso para escribir en el almacenamiento
  Future<void> _requestPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  // Función para guardar el archivo PDF
  Future<void> _captureAndSavePdf() async {
    try {
      // Capturar el QR como imagen
      RenderRepaintBoundary boundary =
          _qrkey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Crear el documento PDF
      final pdf = pw.Document();

      // Agregar el código QR como imagen al PDF
    
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(pw.MemoryImage(pngBytes)),
            );
          },
        ),
      );

      // Verificar permisos
      await _requestPermission();

      // Definir la ruta de guardado
      Directory? externalDir = Directory('/storage/emulated/0/Download/Qr_code');

      // Verificar si el directorio existe, si no, crearlo
      if (!await externalDir.exists()) {
        await externalDir.create(recursive: true);
      }

      // Guardar el PDF en la ubicación especificada
      String filePath = "${externalDir.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.pdf";
      File file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;

      // Mostrar mensaje de éxito
      const snackBar = SnackBar(content: Text('QR code saved as PDF in Downloads/Qr_code'));
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
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          SizedBox(
                          height: 250,
                          width: 250,
                          child: Center(
                            child: RepaintBoundary(
                                key: _qrkey,
                                child: data.isEmpty
                                ? Text("Ingrese su codigo para generar el qr")
                                : QrImageView(
                                  data: data,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                  errorStateBuilder: (ctx, err) {
                                    return Center(
                                      child: Text(
                                        "Algo salio mal",
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ),
                                                ),
                          SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "¿Tienes un codigo promocional?",
                                    style: TextStyle(color: Colors.grey[800]),
                                   
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                            
                              TextField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.deepPurple,
                                      width: 2.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.deepPurple,
                                      width: 2.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.deepPurple,
                                      width: 2.0,
                                    ),
                                  ),
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
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              await _captureAndSavePdf(); // Exportar el QR como PDF y guardarlo
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
            AnimatedOpacity(
              opacity: showTicketInfo ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: showTicketInfo ? _buildTicketInfo() : SizedBox.shrink(),
            ),
            SizedBox(height: 20),
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
          border: Border.all(color: Colors.black, width: 1), // Borde negro
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Sombra negra
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
          showTicketInfo = true; // Muestra el recuadro al seleccionar
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
          border: Border.all(color: Colors.black, width: 1), // Borde negro
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Sombra negra
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
