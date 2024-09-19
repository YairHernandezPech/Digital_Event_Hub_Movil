import 'package:digital_event_hub/sesion/login/idUser.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Para iconos adicionales

class PaymentHistoryPage extends StatefulWidget {
  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  Future<List<dynamic>> fetchPaymentHistory() async {
    final paymentResponse = await http.get(Uri.parse(
        'https://api-digitalevent.onrender.com/api/pagos/historial/${UserSession().userId}'));

    if (paymentResponse.statusCode != 200) {
      throw Exception('Failed to load payment history');
    }

    final paymentHistory = jsonDecode(paymentResponse.body);

    // Fetch user names
    final userNames = {};
    for (var item in paymentHistory) {
      final userId = item['usuario_id'];
      if (!userNames.containsKey(userId)) {
        final userResponse = await http.get(Uri.parse(
            'https://api-digitalevent.onrender.com/api/users/$userId'));

        if (userResponse.statusCode == 200) {
          final userData = jsonDecode(userResponse.body);
          userNames[userId] =
              userData['nombre']; // Assuming 'nombre' is the key for user name
        } else {
          userNames[userId] = 'Unknown User'; // Fallback
        }
      }
    }

    // Attach user names to payment history
    for (var item in paymentHistory) {
      item['usuario_nombre'] = userNames[item['usuario_id']];
    }

    // Map only the required fields
    final filteredPaymentHistory = paymentHistory.map((item) {
      return {
        'usuario_nombre': item['usuario_nombre'],
        'fecha': item['fecha'],
        'fecha_expiracion': item['fecha_expiracion'],
        'numero_tarjeta': item['numero_tarjeta'],
        'monto': item['monto'],
      };
    }).toList();

    return filteredPaymentHistory;
  }

  String formatDate(String date) {
    return date.split('T')[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Historial de Pagos', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<dynamic>>(
        future: fetchPaymentHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('No hay datos disponibles',
                    style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          final paymentHistory = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: paymentHistory.length,
            itemBuilder: (context, index) {
              final item = paymentHistory[index];
              return Card(
                margin: EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 6,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(FontAwesomeIcons.dollarSign,
                                    size: 20, color: Colors.green[700]),
                                SizedBox(width: 8.0),
                                Flexible(
                                  child: Text(
                                    'Monto: ${item['monto']}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700]),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.0),
                            Row(
                              children: [
                                Icon(Icons.person,
                                    size: 20, color: Colors.blueGrey[600]),
                                SizedBox(width: 8.0),
                                Flexible(
                                  child: Text(
                                    'Pablo Antonio',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blueGrey[600]),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.0),
                            Row(
                              children: [
                                Icon(Icons.credit_card,
                                    size: 20, color: Colors.blueGrey[600]),
                                SizedBox(width: 8.0),
                                Flexible(
                                  child: Text(
                                    '${item['numero_tarjeta']}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blueGrey[600]),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Fecha: ${formatDate(item['fecha'])}',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.blueGrey[600]),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Expiración: ${formatDate(item['fecha_expiracion'])}',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.blueGrey[600]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
