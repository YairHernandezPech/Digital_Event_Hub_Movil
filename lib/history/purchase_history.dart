import 'package:digital_event_hub/history/ApiServicePurcharseHistory.dart';
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
  final ApiServicePurcharseHistory apiService = ApiServicePurcharseHistory();
  int userId = int.parse(UserSession().userId!); // Simulated user session
  List<dynamic> history = [];

  Future<void> _fetchHistory() async {
    try {
      final fetchedHistory = await apiService.getPurcharseHistories(userId);
      print(fetchedHistory);
      setState(() {
        history = fetchedHistory;
      });
    } catch (error) {
      print('Error fetching history: $error');
    }
  }

  Future<void> _refreshHistory() async {
    await _fetchHistory();
  }

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    DateFormat formato = DateFormat('dd/MM/yyyy');

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
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: TextField(
          //     decoration: InputDecoration(
          //       hintText: 'Buscar compra realizada...',
          //       prefixIcon: const Icon(Icons.search),
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(16.0),
          //         borderSide: BorderSide.none,
          //       ),
          //       filled: true,
          //       fillColor: Colors.grey[200],
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: Container(
          //     padding: const EdgeInsets.all(8.0),
          //     decoration: BoxDecoration(
          //       color: Colors.grey[200],
          //       borderRadius: BorderRadius.circular(16.0),
          //     ),
          //     child: Row(
          //       children: [
          //         ClipRRect(
          //           borderRadius: BorderRadius.circular(8.0),
          //           child: Image.asset(
          //             'assets/event_image.jpg',
          //             width: 50,
          //             height: 50,
          //             fit: BoxFit.cover,
          //           ),
          //         ),
          //         const SizedBox(width: 8),
          //         Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             const Text('2 eventos esperan tu compra'),
          //             GestureDetector(
          //               onTap: () {},
          //               child: const Text(
          //                 'Ver carrito',
          //                 style: TextStyle(color: Colors.blue),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: history.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/eventolocal.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Compra realizada',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Fecha de la compra: ${history[index]?['fecha'] == null ? "" : formato.format(DateTime.parse(history[index]['fecha']))}',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    history[index]?['pago_id'] == null
                                        ? ""
                                        : history[index]['pago_id'].toString(),
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.qr_code,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => QRScreen(
                                          eventId: history[index]['evento_id']
                                              .toString(),
                                          paymentId: history[index]['pago_id']
                                              .toString(),
                                        )));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
