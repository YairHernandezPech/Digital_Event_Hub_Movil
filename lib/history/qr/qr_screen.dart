import 'package:digital_event_hub/reviews/eventBuySeat.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRScreen extends StatelessWidget {
  final String eventId;
  final String paymentId;

  const QRScreen({super.key, required this.eventId, required this.paymentId});
  
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double horizontalPadding = screenSize.width * 0.2;

    // Convertimos el eventId a un entero para `EventBuySeat`
    int parsedEventId;
    try {
      parsedEventId = int.parse(eventId);
    } catch (e) {
      parsedEventId = 2; // Valor por defecto en caso de error
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        title: const Text('Resumen de Compra',
            style: TextStyle(color: Colors.white)),
             automaticallyImplyLeading: false,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40, right: 24, bottom: 0, left: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EventBuySeat(id: parsedEventId), // Usamos el evento_id
            const SizedBox(height: 36.0),
            Expanded(
              child: Center(
                child: Container(
                  width: 270,
                  height: 270,
                  alignment: Alignment.center,
                  child: QrImageView(
                    data: paymentId, // Usamos el paymentId para el código QR
                    version: QrVersions.auto,
                    size: 270,
                    gapless: true,
                    foregroundColor: Theme.of(context).colorScheme.tertiary, 
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () { Navigator.pop(context); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Regresar',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
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
