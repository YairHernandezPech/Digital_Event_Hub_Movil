import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

  Future<void> _captureAndSavePng() async {
    // Implementación para capturar y guardar como PNG
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

  // Center(
  //   child: Padding(
  //     padding: EdgeInsets.only(left: 16.0, right: 16.0),
  //     child: TextField(
  //       controller: _textController,
  //       decoration: InputDecoration(
  //         contentPadding: EdgeInsets.all(10),
  //         labelText: 'Ingrese su código',
  //         labelStyle: TextStyle(color: Colors.black),
  //         focusedBorder: OutlineInputBorder(
  //           borderSide: BorderSide(
  //               color: Color.fromARGB(255, 0, 0, 0), width: 2.0),
  //         ),
  //         enabledBorder: OutlineInputBorder(
  //           borderSide: BorderSide(color: Colors.black, width: 2.0),
  //         ),
  //       ),
  //     ),
  //   ),
  // ),
  // SizedBox(height: 10),
  // Center(
  //   child: RepaintBoundary(
  //     key: _qrkey,
  //     child: QrImageView(
  //       data: data,
  //       version: QrVersions.auto,
  //       size: 200.0,
  //       gapless: true,
  //       errorStateBuilder: (ctx, err) {
  //         return Center(
  //           child: Text(
  //             "Algo salió mal",
  //             textAlign: TextAlign.center,
  //           ),
  //         );
  //       },
  //     ),
  //   ),
  // ),
  // SizedBox(height: 10),
  // SizedBox(
  //   width: 200,
  //   height: 40,
  //   child: ElevatedButton(
  //     onPressed: () {
  //       setState(() {
  //         data = _textController.text;
  //       });
  //     },
  //     style: ButtonStyle(
  //       backgroundColor:
  //           // ignore: deprecated_member_use
  //           MaterialStateProperty.all<Color>(Colors.deepPurple),
  //     ),
  //     child: Text(
  //       "Comprar",
  //       style: TextStyle(color: Colors.white),
  //     ),
  //   ),
  // ),
  // SizedBox(height: 20),
  // ElevatedButton(
  //   onPressed: _captureAndSavePng,
  //   style: ButtonStyle(
  //     backgroundColor:
  //         MaterialStateProperty.all<Color>(Colors.deepPurple),
  //   ),
  //   child: Text(
  //     "Exportar",
  //     style: TextStyle(color: Colors.white),
  //   ),
  // ),
  // SizedBox(height: 20),
  //  ],
  //),
  //),
  //)
  //}
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
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Información de Pago"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Se procesará el pago para el evento:",
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                            SizedBox(height: 6),
                            Text(
                              widget.eventName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Horario: $selectedHorario",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            SizedBox(height: 10),
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
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("Cerrar"),
                          ),
                        ],
                      );
                    },
                  );
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
