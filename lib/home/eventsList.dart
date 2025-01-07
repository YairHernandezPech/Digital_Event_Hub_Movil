import 'dart:convert';
import 'package:digital_event_hub/Profile/ApiServiceProfile.dart';
import 'package:digital_event_hub/event_detail/event_page.dart';
import 'package:digital_event_hub/history/purchase_history.dart';
import 'package:digital_event_hub/home/header.dart';
import 'package:digital_event_hub/map_event/map_event.dart';
import 'package:digital_event_hub/notification/notif.dart';
import 'package:digital_event_hub/widgets/scrollChips.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class EventsList extends StatefulWidget {
  @override
  _EventsListState createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/bag.png',
              height: 22,
              color: _selectedIndex == 1
                  ? Theme.of(context).colorScheme.tertiary
                  : Colors.grey,
            ),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/bell.png',
              height: 22,
              color: _selectedIndex == 2
                  ? Theme.of(context).colorScheme.tertiary
                  : Colors.grey,
            ),
            label: 'Notificaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.pin_drop_outlined,
              color: _selectedIndex == 3
                  ? Theme.of(context).colorScheme.tertiary
                  : Colors.grey,
            ),
            label: 'Ubicacion',
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

class EventsListBody extends StatefulWidget {
  @override
  State<EventsListBody> createState() => _EventsListBodyState();
}

class _EventsListBodyState extends State<EventsListBody>
    with TickerProviderStateMixin {
  bool isLoading = true;
  List<dynamic> datos = [];
  String selectedCategory = '';
  final List<String> categories = [
    'Tecnología',
    'Educación',
    'Entretenimiento',
    'Deportes',
    'Teatro'
  ];

  ScrollController _scrollController = ScrollController();

  Future<void> fetchEventos({String category = ""}) async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://api-digital.fly.dev/api/events/approved'));

    if (response.statusCode == 200) {
      List<dynamic> eventos = jsonDecode(response.body);


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
      padding: const EdgeInsets.only(top: 50, right: 24, bottom: 0, left: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderHome(
            userData?['nombre'],
            userData?['fotoPerfil'] ?? "",
          ),
          const SizedBox(height: 10.0),
          ScrollChips(
            categories: categories,
            onCategorySelected: onCategorySelected,
            selectedCategory: selectedCategory,
          ),
          const SizedBox(height: 10.0),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: datos.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventPage(id: datos[index]['evento_id']),
                            ),
                          );
                        },
                        child: ElegantCardEvent(
                          title: datos[index]['evento_nombre'] ?? '',
                          imageUrl: datos[index]['imagen_url'] ?? '',
                          location: datos[index]['ubicacion'] ?? '',
                          date: datos[index]['fecha_inicio'] ?? '',
                          eventId: datos[index]['evento_id'] ?? 0,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ElegantCardEvent extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String location;
  final String date;
  final int eventId;

  const ElegantCardEvent({
    required this.title,
    required this.imageUrl,
    required this.location,
    required this.date,
    required this.eventId,
    Key? key,
  }) : super(key: key);

  String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return "Fecha inválida";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10, // Increased elevation for more depth
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6), // Slightly lighter
                    Colors.black.withOpacity(0.1),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(16.0)),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600, // Medium weight
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 18),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white, size: 18),
                      const SizedBox(width: 5),
                      Text(formatDate(date),
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
