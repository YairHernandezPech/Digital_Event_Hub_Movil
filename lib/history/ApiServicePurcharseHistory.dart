import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ApiServicePayments {
  final String apiUrl = "https://api-digital.fly.dev/api/payment/history/detailed";

  // Método para obtener el historial de pagos detallado
  Future<List<dynamic>> getPaymentHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null || JwtDecoder.isExpired(token)) {
      throw Exception('No hay sesión activa o el token ha expirado');
    }

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener el historial de pagos: ${response.body}');
    }

    return json.decode(response.body); // Devuelve la lista de pagos directamente
  }
}

