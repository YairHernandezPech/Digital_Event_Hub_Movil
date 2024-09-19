import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceEventSeat {
  String get apiUrl =>
      "https://api-digitalevent.onrender.com/api/eventos/events";

  Future<List<dynamic>> fetchEvents() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<dynamic>> fetchScenarios() async {
    final response = await http.get(Uri.parse("https://api-digitalevent.onrender.com/api/escenarios"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load scenario data');
    }
  }
}
