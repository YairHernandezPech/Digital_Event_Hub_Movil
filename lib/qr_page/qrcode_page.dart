import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrcodePage extends StatefulWidget {
   final String imageUrl;

    QrcodePage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<QrcodePage> createState() => _QrcodePageState();
}

class _QrcodePageState extends State<QrcodePage> {
   final TextEditingController _textController = TextEditingController(text: '');
  String data = '';
  final GlobalKey _qrkey = GlobalKey();
  bool dirExists = false;
  dynamic externalDir = '/storage/emulated/0/Download/Qr_code';

  Future<void> _captureAndSavePng() async {
    try{
      RenderRepaintBoundary boundary = _qrkey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);

      //Drawing White Background because Qr Code is Black
      final whitePaint = Paint()..color = Colors.white;
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder,Rect.fromLTWH(0,0,image.width.toDouble(),image.height.toDouble()));
      canvas.drawRect(Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()), whitePaint);
      canvas.drawImage(image, Offset.zero, Paint());
      final picture = recorder.endRecording();
      final img = await picture.toImage(image.width, image.height);
      ByteData? byteData = await img.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      //Check for duplicate file name to avoid Override
      String fileName = 'qr_code';
      int i = 1;
      while(await File('$externalDir/$fileName.png').exists()){
        fileName = 'qr_code_$i';
        i++;
      }

      // Check if Directory Path exists or not
      dirExists = await File(externalDir).exists();
      //if not then create the path
      if(!dirExists){
        await Directory(externalDir).create(recursive: true);
        dirExists = true;
      }

      final file = await File('$externalDir/$fileName.png').create();
      await file.writeAsBytes(pngBytes);

      if(!mounted)return;
      const snackBar = SnackBar(content: Text('QR code saved to gallery'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

    }catch(e){
      if(!mounted)return;
      const snackBar = SnackBar(content: Text('Something went wrong!!!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
  child: Column( 
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            height: 200,
            child: Card(
              color: Colors.purple.shade300,
              elevation: 4,
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Felices\nFiestas',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Exitoso',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Boletos disponibles',
                            style: TextStyle(fontSize: 16, color: Colors.white)),
                        Text('50', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total de boletos',
                            style: TextStyle(fontSize: 16, color: Colors.white)),
                        Text('150', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
  ClipRRect(
  
child:Image.network(
          widget.imageUrl ??
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKF_YlFFlKS6AQ8no0Qs_xM6AkjvwFwP61og&s', // URL de imagen por defecto si no está disponible en el evento
width: 350,
          height: 250,
          fit: BoxFit.cover,
   ) // Muestra un indicador de carga mientras se obtienen los datos
       ),
       SizedBox(height: 15,),
     Center(
       child: Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0),
        child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  labelText: 'ingrese su codigo',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 0, 0, 0),
                      width: 2.0
                    )
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0)
                  )
                ),
              ),
       ),
     ),
     SizedBox(
      height: 10,
     ),
     ElevatedButton(
      onPressed: () {
        setState(() {
          data = _textController.text;
        });
      },
      child: Text("Comprar", style: TextStyle( color: Colors.white),),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.deepPurple),
      ),
     ),
     SizedBox(
      height: 10,
     ),
     Center(
      child: RepaintBoundary(
        key: _qrkey,
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          size: 200.0,
          gapless: true,
          errorStateBuilder: (ctx, err) {
              return Center(
                child: Text("Algo salio mal", textAlign: TextAlign.center,),
                
              );
          },
        ),
      ),
     ),
      SizedBox(
      height: 10,
     ),
      ElevatedButton(
      onPressed: _captureAndSavePng,
      child: Text("Exportar", style: TextStyle( color: Colors.white),),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.deepPurple),
      ),
     ),
    ],
  ),
),

    );
  }
}