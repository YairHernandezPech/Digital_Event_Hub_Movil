import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceProfile {
  String get apiUrl => "https://api-digitalevent.onrender.com/api/escenarios/";
  Future<List<dynamic>> fetchAsientos() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
