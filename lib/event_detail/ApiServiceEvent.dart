import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceEvent {
  String get apiUrl =>
      "https://api-digital.fly.dev/api/events/approved";
  Future<List<dynamic>> fetchEvents() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
