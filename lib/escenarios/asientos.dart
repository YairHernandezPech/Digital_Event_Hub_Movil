import 'package:digital_event_hub/sesion/login/idUser.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:digital_event_hub/escenarios/ApiServiceAsientos.dart';

class Asientos extends StatefulWidget {
  final int idEvento;

  const Asientos({Key? key, required this.idEvento}) : super(key: key);

  @override
  AsientosState createState() => AsientosState();
}

class AsientosState extends State<Asientos> {
  Map<String, dynamic>? event;
  int totalSeats = 0;
  final int seatsPerRow = 10;
  Set<int> selectedSeats = Set<int>();

  int get id => widget.idEvento;

  @override
  void initState() {
    super.initState();
    fetchEscenarioById(id);
  }

  Future<void> fetchEscenarioById(int eventId) async {
    try {
      List<dynamic> fetchedEvents = await ApiServiceProfile().fetchAsientos();
      Map<String, dynamic>? fetchedEvent = fetchedEvents
          .firstWhere((e) => e['evento_id'] == eventId, orElse: () => null);

      setState(() {
        event = fetchedEvent;
        if (event != null && event!['asientos'] != null) {
          totalSeats = event!['asientos'].length;
        }
      });
    } catch (e) {
      print("Failed to load event: $e");
    }
  }

  Future<void> confirmarAsientos() async {
    int userId =
        int.parse(UserSession().userId!); // Obtén el userId dinámico aquí
    for (var seatIndex in selectedSeats) {
      var seat = event?['asientos'][seatIndex];
      if (seat != null) {
        int asientoId = seat['asiento_id'];
        await actualizarAsiento(asientoId, "Reservado", userId);
      }
    }
    setState(() {
      selectedSeats.clear();
    });
  }

  Future<void> actualizarAsiento(
      int asientoId, String estado, int usuarioId) async {
    String url =
        'https://api-digitalevent.onrender.com/api/asientos/$asientoId';
    Map<String, dynamic> body = {"estado": estado, "usuario_id": usuarioId};

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print('Asiento $asientoId actualizado correctamente.');
      } else {
        print('Error al actualizar asiento $asientoId: ${response.body}');
      }
    } catch (e) {
      print('Error al conectar con la API: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    int numRows = (totalSeats / seatsPerRow).ceil();
    double seatSize =
        (MediaQuery.of(context).size.width - 20) / seatsPerRow - 14;

    return Column(
      children: [
        Column(
          children: List.generate(numRows, (rowIndex) {
            int startSeat = rowIndex * seatsPerRow;
            int endSeat = startSeat + seatsPerRow;
            if (endSeat > totalSeats) endSeat = totalSeats;
            int seatsInRow = endSeat - startSeat;
            double padding = (seatsPerRow - seatsInRow) / 2 * seatSize;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(seatsInRow, (index) {
                  int seatIndex = startSeat + index;
                  var seat = event?['asientos'][seatIndex];
                  if (seat == null) return Container();
                  String estado = seat['estado'];
                  bool isSelected = selectedSeats.contains(seatIndex);
                  Color seatColor;

                  if (estado == 'Reservado') {
                    seatColor = Colors.purple;
                  } else if (isSelected) {
                    seatColor = Colors.blue;
                  } else {
                    seatColor = const Color.fromRGBO(158, 158, 158, 1);
                  }

                  return GestureDetector(
                    onTap: () {
                      if (estado != 'Reservado') {
                        setState(() {
                          if (isSelected) {
                            selectedSeats.remove(seatIndex);
                          } else {
                            selectedSeats.add(seatIndex);
                          }
                        });
                      }
                    },
                    child: Container(
                      width: seatSize,
                      height: seatSize,
                      margin: EdgeInsets.all(2),
                      color: seatColor,
                      child: Center(
                        child: Text(
                          seat['numero_asiento'].split('-').last,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
