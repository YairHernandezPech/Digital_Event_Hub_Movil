import 'package:digital_event_hub/reviews/ApiServiceEventSeat.dart';
import 'package:digital_event_hub/sesion/login/idUser.dart';
import 'package:flutter/material.dart';

class EventBuySeat extends StatefulWidget {
  final int id;

  const EventBuySeat({super.key, this.id = 2});

  @override
  State<EventBuySeat> createState() => _EventBuySeatState();
}

class _EventBuySeatState extends State<EventBuySeat> {
  Map<String, dynamic>? event;
  int get id => widget.id;
  int userId =
      int.parse(UserSession().userId!); // Obtén el userId dinámico aquí
  List<dynamic> userSeats = [];

  @override
  void initState() {
    super.initState();
    fetchEventById(id);
  }

  void fetchEventById(int eventId) async {
    try {
      List<dynamic> fetchedEvents = await ApiServiceEventSeat().fetchEvents();
      Map<String, dynamic>? fetchedEvent = fetchedEvents
          .firstWhere((e) => e['evento_id'] == eventId, orElse: () => null);

      if (fetchedEvent != null) {
        fetchScenarioSeats(eventId);
      }

      setState(() {
        event = fetchedEvent;
      });
    } catch (e) {
      print("Failed to load event: $e");
    }
  }

  void fetchScenarioSeats(int eventId) async {
    try {
      List<dynamic> scenarios = await ApiServiceEventSeat().fetchScenarios();
      Map<String, dynamic>? scenario = scenarios
          .firstWhere((s) => s['evento_id'] == eventId, orElse: () => null);

      if (scenario != null) {
        List<dynamic> seats = scenario['asientos'];
        List<dynamic> userSeatsList =
            seats.where((seat) => seat['usuario_id'] == userId).toList();

        setState(() {
          userSeats = userSeatsList;
        });
      }
    } catch (e) {
      print("Failed to load scenario: $e");
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
                        'http://www.palmares.lemondeduchiffre.fr/images/joomlart/demo/default.jpg', // URL de la imagen desde el evento o una imagen por defecto
                    width: 100,
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
                        ? event!['nombre_evento'] ?? 'Evento'
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        event != null
                            ? "${event!['fecha_inicio']?.substring(0, 10)}"
                            : 'Fecha',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        event != null
                            ? '${event!['hora']}'
                            : 'Hora: Desconocida',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Image.asset('assets/Seat.png',
                          height: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      userSeats.isNotEmpty
                          ? Expanded(
                              child: Text(
                                "Asiento Reservado: ${userSeats.map((seat) => seat['numero_asiento'].split('-')[1]).join(', ')}",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : const Text(
                              "Asientos disponibles",
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
