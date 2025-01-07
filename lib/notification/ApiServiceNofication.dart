import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceNotification {
  final String baseUrl = 'https://api-digitalevent.onrender.com/api/notification/getAll';

  Future<List<Map<String, dynamic>>> getNotifications(int userId) async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .where((notification) => notification['usuario_id'] == userId)
          .map((notification) => {
                'mensaje': notification['mensaje'],
                'fecha_envio': notification['fecha_envio'],
              })
          .toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}
