import 'dart:convert';
import 'package:digital_event_hub/sesion/login/idUser.dart';
import 'package:http/http.dart' as http;

class ApiServicePurcharseHistory {
  final String baseUrl = 'https://api-digitalevent.onrender.com/api/pagos/historial/${UserSession().userId}';

  Future<List<dynamic>> getPurcharseHistories(int userId) async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to load histories');
    }
  }
}
