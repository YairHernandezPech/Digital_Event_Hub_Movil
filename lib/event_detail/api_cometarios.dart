import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceComentarios {
  final String baseUrl = 'https://api-digital.fly.dev/api';

  // Elimina los parámetros de paginación ya que la API no los requiere
  Future<List<dynamic>> fetchComments(int eventId) async {
    final response = await http.get(Uri.parse('$baseUrl/comments/list/$eventId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<Map<String, dynamic>> fetchUser(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<void> createComment(int eventId, int userId, String comentario) async {
    final String url = '$baseUrl/comments/create';
    final DateTime now = DateTime.now();
    final String formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final Map<String, dynamic> body = {
      'evento_id': eventId,
      'usuario_id': userId,
      'comentario': comentario,
      'fecha': formattedDate,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create comment');
    }
  }

  Future<void> deleteComment(int comentarioId) async {
    final String url = '$baseUrl/comments/delete/$comentarioId';

    final response = await http.delete(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete comment');
    }
  }
}