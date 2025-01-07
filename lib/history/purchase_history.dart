import 'package:digital_event_hub/history/ApiServicePurcharseHistory.dart';
import 'package:digital_event_hub/history/paymentdetailview.dart';
import 'package:digital_event_hub/history/qr/qr_screen.dart';
import 'package:digital_event_hub/sesion/login/idUser.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PurchaseHistoryPage extends StatefulWidget {
  const PurchaseHistoryPage({super.key});

  @override
  State<PurchaseHistoryPage> createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {

  late Future<List<dynamic>> _paymentHistory;

  @override
  void initState() {
    super.initState();
    _paymentHistory = ApiServicePayments().getPaymentHistory();
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        elevation: 0,
        title: const Text(
          'Historial de compras',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body:FutureBuilder<List<dynamic>>(
        future: _paymentHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay pagos disponibles.'));
          }

          final payments = snapshot.data!;

          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  title: Text(
                    payment['nombre_evento'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [              
                      SizedBox(height: 4),
                      Text(
                        'Fecha: ${payment['fecha_pago']}',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ubicación: ${payment['ubicacion']}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navegar a la vista de detalles
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Paymentdetailview(paymentDetails: payment),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}