import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Paymentdetailview extends StatelessWidget {
  final Map<String, dynamic> paymentDetails;
  const Paymentdetailview({super.key, required this.paymentDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de Compra'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título del evento
              Text(
                paymentDetails['nombre_evento'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              // Tarjeta con detalles de la compra
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fecha de Pago: ${paymentDetails['fecha_pago']}', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Ubicación: ${paymentDetails['ubicacion']}', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Hora: ${paymentDetails['hora_inicio']} - ${paymentDetails['hora_fin']}', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Código de Ticket: ${paymentDetails['codigo_ticket']}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Sección del código QR
              Text('Código QR:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Center(
                child: QrImageView(
                  data: paymentDetails['codigo_ticket'], // Usar el código de ticket
                  version: QrVersions.auto,
                  size: 200.0,
                  gapless: false,
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );

  }
}