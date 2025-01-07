import 'package:digital_event_hub/buy_page/historial_pagos.dart';
import 'package:digital_event_hub/home/eventsList.dart';
import 'package:digital_event_hub/sesion/login/idUser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:digital_event_hub/reviews/eventBuy.dart';
import 'package:flutter/services.dart';

class MetodoPagoScreen extends StatelessWidget {
  final int id;
  final double monto;
  const MetodoPagoScreen({super.key, required this.id, required this.monto});

  Future<String> getEventDescription(int eventId) async {
    try {
      final response = await http.get(
        Uri.https('api-digitalevent.onrender.com', '/api/events/get/img/$eventId'),
      );

      if (response.statusCode == 200) {
        final eventData = jsonDecode(response.body);
        final eventName = eventData['evento_nombre'] as String;
        return eventName;
      } else {
        throw Exception('Failed to fetch event description');
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
      throw Exception('Failed to fetch event description');
    }
  }

  Future<String> createPaymentIntent(int amount, String currency, String description, int userId, int eventId) async {
    try {
      final body = jsonEncode({
        'amount': amount,
        'currency': currency,
        'descripcion': description,
        'usuario_id': userId,
        'evento_id': eventId,
      });

      final response = await http.post(
        Uri.https('api-digitalevent.onrender.com', '/api/pagos/pagar'),
        body: body,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final paymentIntentData = jsonDecode(response.body);
        final clientSecret = paymentIntentData['client_secret'] as String;
        return clientSecret;
      } else {
        throw Exception('Failed to create payment intent');
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
      throw Exception('Failed to create payment intent');
    }
  }

  Future<void> makePayment(BuildContext context) async {
    try {
      final int amountInCents = (monto * 100).toInt();
      final String eventDescription = await getEventDescription(id);
      final int userId = int.parse(UserSession().userId!);

      final paymentIntentClientSecret = await createPaymentIntent(
        amountInCents,
        'USD',
        eventDescription,
        userId,
        id,
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          style: ThemeMode.light,
          merchantDisplayName: 'ejemplo',
        ),
      );

      await displayPaymentSheet(context);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> displayPaymentSheet(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pago exitoso")),
        );
        // Redirigir a la pantalla de eventos después del pago exitoso
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EventsList()),
        );
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void _showUnavailableMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Este metodo de pago aun no esta disponible')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        title: const Text('Selecciona tu metodo de pago',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaymentHistoryPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white, // Establecer color de fondo a blanco
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Eventbuy(id: id),
            SizedBox(height: 20),
            PaymentOption(
              icons: [
                'assets/mastercard.png', // Reemplaza con la ruta de tu imagen
                'assets/visa.png', // Reemplaza con la ruta de tu imagen
                'assets/banco_azteca.jpg' // Reemplaza con la ruta de tu imagen
              ],
              text: 'Click to Pay',
              onTap: () {
                _showUnavailableMessage(context);
              },
            ),
            PaymentOption(
              icons: [
                'assets/tarjeta_bancaria.png'
              ], // Reemplaza con la ruta de tu imagen
              text: 'Tarjeta bancaria',
              onTap: () {
                _showUnavailableMessage(context);
              },
            ),
            PaymentOption(
              icons: [
                'assets/pay_pal.png'
              ], // Reemplaza con la ruta de tu imagen
              text: 'Pay Pal',
              onTap: () {
                _showUnavailableMessage(context);
              },
            ),
            PaymentOption(
              icons: [
                'assets/stripe.png'
              ], // Reemplaza con la ruta de tu imagen
              text: 'Stripe',
              onTap: () async {
                await makePayment(context);
              },
            ),
            Spacer(),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '$monto',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '$monto',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class PaymentOption extends StatelessWidget {
  final List<String> icons;
  final String text;
  final VoidCallback onTap;

  PaymentOption({required this.icons, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(255, 222, 222, 222)),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          children: [
            Row(
              children: icons
                  .map((icon) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Image.asset(
                          icon,
                          width: 32,
                          height: 32,
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
