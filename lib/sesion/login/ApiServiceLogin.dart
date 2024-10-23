import 'dart:convert';
import 'package:digital_event_hub/sesion/login/idUser.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceLogin {
  final String apiUrl = "https://api-digital.fly.dev/api/users/login";

  // Método de login que guarda el token en SharedPreferences
  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al iniciar sesión');
    }

    final responseBody = json.decode(response.body);
    if (responseBody.containsKey('token')) {
      String token = responseBody['token'];

      // Decodificar el token JWT para obtener el ID del usuario
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      UserSession().userId = decodedToken['id'].toString();

      // Guardar el token en SharedPreferences para recordar la sesión
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwtToken', token);
    }

    return responseBody;
  }

  // Método para verificar si el usuario ya tiene una sesión activa
  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token != null && !JwtDecoder.isExpired(token)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      UserSession().userId = decodedToken['id'].toString();
      return true; // El usuario tiene una sesión activa
    }

    return false; // No hay sesión activa o el token ha expirado
  }

  // Método para cerrar sesión y eliminar el token
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwtToken'); // Elimina el token almacenado
    UserSession().userId = ''; // Limpia el ID de usuario
  }
}
