import 'dart:convert';

import 'package:digital_event_hub/Profile/ApiServiceProfile.dart';
import 'package:digital_event_hub/event_detail/event_page.dart';
import 'package:digital_event_hub/history/purchase_history.dart';
import 'package:digital_event_hub/home/header.dart';
import 'package:digital_event_hub/map_event/map_event.dart';
import 'package:digital_event_hub/notification/notif.dart';
import 'package:digital_event_hub/widgets/cards/cardEvent.dart';
import 'package:digital_event_hub/widgets/scrollChips.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skeletonizer/skeletonizer.dart';

class EventsList extends StatefulWidget {
  @override
  _EventsListState createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    EventsListBody(),
    PurchaseHistoryPage(),
    NotificationBar(),
    GoogleMapScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image(
                image: AssetImage('assets/bag.png'),
                height: 22,
                color: _selectedIndex == 1
                    ? Theme.of(context).colorScheme.tertiary
                    : Colors.grey),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image(
                image: AssetImage('assets/bell.png'),
                height: 22,
                color: _selectedIndex == 2
                    ? Theme.of(context).colorScheme.tertiary
                    : Colors.grey),
            //FontAwesomeIcons.gamepad
            label: '',
          ),
          // BottomNavigationBarItem(
          //   icon: Image(
          //       image: AssetImage('assets/Pin.png'),
          //       height: 22,
          //       color: _selectedIndex == 3
          //           ? Theme.of(context).colorScheme.tertiary
          //           : Colors.grey),
          //   label: '',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pin_drop_outlined,
                color: _selectedIndex == 3
                    ? Theme.of(context).colorScheme.tertiary
                    : Colors.grey),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.tertiary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////

// class EventsListBody  extends StatefulWidget {

//   @override
//   State<EventsListBody> createState() => _EventsListBodyState();
// }

// List<Map<String, String>> datos = [
//   {
//     'title': 'Evento de lanzamiento',
//     'img': 'https://e.radio-grpp.io/normal/2016/08/17/553455_221714.png',
//     'ubication': 'Ciudad de Ejemplo',
//     'date': '2024-07-01',
//     'id': '1',
//   },
//   {
//     'title': 'Conferencia Virtual',
//     'img':
//         'https://www.latevaweb.com/diseno-web/webs-para-eventos.jpg',
//     'ubication': 'Online',
//     'date': '2024-07-15',
//     'id': '2',
//   },
//   {
//     'title': 'Evento de lanzamiento',
//     'img': 'https://www.latevaweb.com/diseno-web/webs-para-eventos.jpg',
//     'ubication': 'Ciudad de Ejemplo',
//     'date': '2024-07-01',
//     'id': '1',
//   },
//   {
//     'title': 'Conferencia Virtual',
//     'img':
//         'https://e.radio-grpp.io/normal/2016/08/17/553455_221714.png',
//     'ubication': 'Online',
//     'date': '2024-07-15',
//     'id': '2',
//   },
// ];

class EventsListBody extends StatefulWidget {
  @override
  State<EventsListBody> createState() => _EventsListBodyState();
}

class _EventsListBodyState extends State<EventsListBody> {
  bool isLoading = true;
  List<dynamic> datos = [];
  String selectedCategory = '';
  final List<String> categories = ['Tecnología','Educación', 'Entretenimiento', 'Deportes', 'Teatro'];

  Future<void> fetchEventos({String category = ""}) async {
    setState(() {
      isLoading = true;
    });

    // Nueva URL sin filtro
    final response = await http.get(Uri.parse(
        'https://api-digitalevent.onrender.com/api/events/get/approved'));

    if (response.statusCode == 200) {
      List<dynamic> eventos = jsonDecode(response.body);
      
      // Filtrar manualmente según la categoría seleccionada
      if (category.isNotEmpty) {
        eventos = eventos.where((evento) {
          return evento['categoria'] == category;
        }).toList();
      }

      setState(() {
        datos = eventos;
        isLoading = false;
      });
    } else {
      setState(() {
        datos = [];
        isLoading = false;
      });
      print('Error al obtener los eventos');
    }
  }

  ApiServiceProfile apiService = ApiServiceProfile();

  Map<String, dynamic>? userData;
  void fetchUser() async {
    try {
      final dataRes = await apiService.fetchUserData();
      setState(() {
        userData = dataRes;
      });
    } catch (e) {
      print(e);
    }
  }

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      fetchEventos(category: selectedCategory);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchEventos();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 50, right: 24, bottom: 0, left: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderHome(userData?['nombre'], userData?['fotoPerfil'] ?? "",),
          SizedBox(height: 10.0),
          ScrollChips(
              categories: categories,
              onCategorySelected: onCategorySelected,
              selectedCategory: selectedCategory),
          SizedBox(height: 10.0),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(0.0),
              itemCount: datos.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EventPage(id: datos[index]['evento_id'])),
                    );
                  },
                  child: Skeletonizer(
                    enabled: isLoading,
                    child: Column(
                      children: [
                        CardEvent(
                            datos[index]['evento_nombre'] ?? '',
                            datos[index]['imagen_url'] ?? '',
                            datos[index]['ubicacion'] ?? '',
                            datos[index]['fecha_inicio'] ?? '',
                            datos[index]['evento_id'] ?? 0),
                        SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}