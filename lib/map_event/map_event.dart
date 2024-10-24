import 'package:digital_event_hub/map_event/ApiServiceMarker.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapScreen extends StatefulWidget {
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController mapController;
  final LatLng _center =
      const LatLng(20.5850752, -90.0223038); // Coordenadas de ejemplo
  Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _fetchAndAddMarkers();
  }

  Future<void> _fetchAndAddMarkers() async {
    try {
      List<Evento> eventos = await fetchEventos();
      Set<Marker> newMarkers = eventos.map((evento) {
        // Aquí puedes convertir las ubicaciones a coordenadas LatLng reales si es necesario
        // Actualmente se usan coordenadas de ejemplo
        LatLng position = _getLatLngFromUbicacion(evento.ubicacion);
        return Marker(
          markerId: MarkerId(evento.eventoId.toString()),
          position: position,
          infoWindow: InfoWindow(
            title: evento.nombreEvento,
            snippet: evento.ubicacion,
          ),
        );
      }).toSet();
      setState(() {
        _markers = newMarkers;
      });
    } catch (e) {
      print(e);
    }
  }

  LatLng _getLatLngFromUbicacion(String ubicacion) {
    // Aquí puedes implementar un método para convertir la ubicación a coordenadas reales
    // Por ahora, devuelve coordenadas de ejemplo
    switch (ubicacion) {
      case "Auditorio Nacional":
        return LatLng(19.426726, -99.1718706);
      case "Centro de Convenciones":
        return LatLng(19.432608, -99.133209);
      case "Estadio Kukulcán Alamo":
        return LatLng(20.9421633, -89.6035732);
      case "Maxcanu":
        return LatLng(20.5870974, -90.0170427);
      case "Cementerio Municipal, Maxcanú Yucatán":
        return LatLng(20.581407795908042, -90.01356055406555);
      case "Universidad tecnologica del poniente UTP Maxcanú":
        return LatLng(20.5784501, -90.0107107);
      default:
        return _center;
    }
    // if (ubicacion == "Auditorio Nacional") {
    //   return LatLng(19.426726, -99.1718706);
    // } else if (ubicacion == "Centro de Convenciones") {
    //   return LatLng(19.432608, -99.133209);
    // } else {
    //   return _center;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Mapa de eventos cercanos',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        automaticallyImplyLeading: false,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
        markers: _markers,
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }
}
