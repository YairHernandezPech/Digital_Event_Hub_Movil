import 'dart:convert';
import 'package:digital_event_hub/sesion/login/idUser.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class ApiServiceLogin {
  final String apiUrl = "https://api-digitalevent.onrender.com/api/auth/login";

  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create account');
    }

    final responseBody = json.decode(response.body);
    if (responseBody.containsKey('token')) {
      String token = responseBody['token'];
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      UserSession().userId = decodedToken['id'].toString();
    }

    return responseBody;
  }
}
