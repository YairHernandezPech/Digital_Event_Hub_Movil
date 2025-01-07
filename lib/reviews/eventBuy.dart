import 'package:digital_event_hub/event_detail/ApiServiceEvent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Eventbuy extends StatefulWidget {
  final int id;

  const Eventbuy({super.key, this.id = 2});
  @override
  State<Eventbuy> createState() => _EventbuyState();
}

class _EventbuyState extends State<Eventbuy> {
  Map<String, dynamic>? event;
  int get id => widget.id;

  @override
  void initState() {
    super.initState();
    fetchEventById(id);
  }

  void fetchEventById(int eventId) async {
    try {
      List<dynamic> fetchedEvents = await ApiServiceEvent().fetchEvents();
      Map<String, dynamic>? fetchedEvent = fetchedEvents
          .firstWhere((e) => e['evento_id'] == eventId, orElse: () => null);
      setState(() {
        event = fetchedEvent;
        print(event);
      });
    } catch (e) {
      print("Failed to load event: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            event != null
                ? Image.network(
                    event!['imagen_url'] ??
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKF_YlFFlKS6AQ8no0Qs_xM6AkjvwFwP61og&s', // URL de la imagen desde el evento o una imagen por defecto
                    width: 120,
                    height: 120,
                  )
                : const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event != null
                        ? event!['evento_nombre'] ?? 'Evento'
                        : 'Evento',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Image(
                        image: AssetImage('assets/Pin.png'),
                        height: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event != null
                            ? event!['ubicacion'] ?? 'Ubicación'
                            : 'Ubicación',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        event != null
                            ? "${event!['fecha_inicio']?.substring(0, 10)}"
                            : 'Fecha',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        event != null
                            ? '${event!['hora']}'
                            : 'Hora: Desconocida',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
