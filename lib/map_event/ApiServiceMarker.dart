
import 'dart:convert';
import 'package:http/http.dart' as http;
class Evento {
  final int eventoId;
  final String nombreEvento;
  final String ubicacion;
  final String imagenUrl;

  Evento({
    required this.eventoId,
    required this.nombreEvento,
    required this.ubicacion,
    required this.imagenUrl,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      eventoId: json['evento_id'],
      nombreEvento: json['evento_nombre'],
      ubicacion: json['ubicacion'],
      imagenUrl: json['imagen_url'],
    );
  }
}


Future<List<Evento>> fetchEventos() async {
  final response = await http.get(
      Uri.parse('https://api-digital.fly.dev/api/events/approved'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((event) => Evento.fromJson(event)).toList();
  } else {
    throw Exception('Failed to load eventos');
  }
}
