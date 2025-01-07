import 'package:digital_event_hub/buy_page/buy_page.dart';
import 'package:digital_event_hub/escenarios/asientos.dart';
import 'package:digital_event_hub/escenarios/symbology.dart';
import 'package:digital_event_hub/reviews/eventBuy.dart';
import 'package:flutter/material.dart';

class Escenario1 extends StatelessWidget {
  final int id;
  final double monto;
  Escenario1({
    super.key,
    required this.id,
    required this.monto,
  });

  final GlobalKey<AsientosState> asientosKey = GlobalKey<AsientosState>();

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño de la pantalla
    final Size screenSize = MediaQuery.of(context).size;
    // Calculamos el padding horizontal de manera proporcional al tamaño de la pantalla
    final double horizontalPadding = screenSize.width * 0.2;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        title: const Text('Selecciona tus asientos',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40, right: 24, bottom: 0, left: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eventbuy(id: id), //Componente de la compra
            const SizedBox(height: 20.0),

            Center(
              child: Symbology(), //Componente de la simbologia
            ),
            const SizedBox(height: 80),
            Expanded(
              child: Stack(
                children: [
                  Image.asset(
                    //Imagen solo del escenario
                    'assets/stage.png',
                    fit: BoxFit.contain,
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 140),
                      child: SingleChildScrollView(
                        scrollDirection: Axis
                            .vertical, // Para permitir desplazamiento horizontal, cambia a Axis.vertical si prefieres vertical
                        child: Asientos(
                          key: asientosKey,
                          idEvento: id,
                        ), // Componente de los asientos
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    asientosKey.currentState?.confirmarAsientos();

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => MetodoPagoScreen(
                                id: id,
                                monto: monto,
                              )),
                      (Route<dynamic> route) =>
                          false, // Elimina todas las rutas anteriores
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Confirmar asientos',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
