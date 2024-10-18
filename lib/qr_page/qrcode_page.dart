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
                  child: Image.network(
                    widget.imageUrl,
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    'Seleccionar un horario',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            _buildHorarioSelector(),
            SizedBox(height: 15),
            // Show "Comprar Boleto" only if a horario is selected
            if (selectedHorario != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Contenedor para "Comprar Boleto"
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Comprar Boleto',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Evento: ${widget.eventName}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Mostrar el horario seleccionado
                      Text(
                        "Horario: $selectedHorario",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 16),
                      // Botón "Procesar Pago"
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 123, 255),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton(
                          onPressed: () {
                            // Aquí puedes agregar la lógica para procesar el pago
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Procesar Pago"),
                                  content: Text(
                                      "Se procesará el pago para el horario: $selectedHorario"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text("Cerrar"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Procesar Pago",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 10),
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
          ],
        ),
      ),
    );
  }

  Widget _buildHorarioSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "Selecciona horario",
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 48,
                  runSpacing: 10,
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
        ),
      ],
    );
  }

  Widget _horarioBox(String inicio, String fin) {
    final isSelected = selectedHorario == "$inicio - $fin";
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedHorario = "$inicio - $fin";
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.deepPurple,
            width: 2,
          ),
          color: isSelected ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(8),
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
            const SizedBox(height: 5),
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
}
