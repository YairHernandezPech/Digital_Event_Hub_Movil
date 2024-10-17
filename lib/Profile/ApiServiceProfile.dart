import 'dart:convert';
import 'package:digital_event_hub/sesion/login/idUser.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceProfile {
  String get apiUrl =>
      "https://api-digitalevent.onrender.com/api/users/${UserSession().userId}";

  // Método para obtener los datos del usuario con token de autenticación
  Future<Map<String, dynamic>> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      throw Exception('No se ha encontrado un token de sesión');
    }

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Pasar el token en la cabecera
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar los datos del usuario');
    }
  }

  // Método para actualizar los datos del usuario con token de autenticación
  Future<void> updateUserData(Map<String, dynamic> updatedData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      throw Exception('No se ha encontrado un token de sesión');
    }

    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Pasar el token en la cabecera
      },
      body: json.encode(updatedData),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar los datos');
    }
  }
}
