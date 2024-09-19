import 'package:digital_event_hub/notification/ApiServiceNofication.dart';
import 'package:digital_event_hub/sesion/login/idUser.dart';
import 'package:flutter/material.dart';

class NotificationBar extends StatefulWidget {
  @override
  _NotificationBarState createState() => _NotificationBarState();
}

class _NotificationBarState extends State<NotificationBar> {
  int _selectedIndex = 0; // Asegúrate de que _selectedIndex esté aquí y sea accesible

  static List<Widget> _widgetOptions = <Widget>[
    NotificationScreen(),
    Center(child: Text('Tienda')),
    Center(child: Text('Perfil')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }
}

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];
  int userId = int.parse(UserSession().userId!); // Simulated user session ID
  final ApiServiceNotification apiService = ApiServiceNotification();
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final fetchedNotifications = await apiService.getNotifications(userId);
      setState(() {
        notifications = fetchedNotifications;
      });
    } catch (error) {
      print('Error fetching notifications: $error');
    }
  }

  Future<void> _refreshNotifications() async {
    await _fetchNotifications();
  }

  List<Map<String, dynamic>> _filterNotifications() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(Duration(days: 1));
    DateTime oneWeekAgo = today.subtract(Duration(days: 7));
    DateTime oneMonthAgo = DateTime(now.year, now.month - 1, now.day);

    return notifications.where((notification) {
      DateTime notificationDate = DateTime.parse(notification['fecha_envio']);
      DateTime notificationDay = DateTime(notificationDate.year, notificationDate.month, notificationDate.day);
      switch (_selectedFilter) {
        case 'Hoy':
          return notificationDay.isAtSameMomentAs(today);
        case 'Ayer':
          return notificationDay.isAtSameMomentAs(yesterday);
        case 'La semana pasada':
          return notificationDay.isAfter(oneWeekAgo) && notificationDay.isBefore(today);
        case 'El mes pasado':
          return notificationDay.isAfter(oneMonthAgo) && notificationDay.isBefore(today);
        case 'Todos':
        default:
          return true;
      }
    }).toList();
  }

  void _removeNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notificación eliminada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredNotifications = _filterNotifications();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        title: Center(child: Text('Notificaciones', style: TextStyle(color: Colors.white))),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: Text('Todos', style: TextStyle(color: Colors.white)),
                    selected: _selectedFilter == 'Todos',
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedFilter = 'Todos';
                      });
                    },
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                  ),
                  SizedBox(width: 10),
                  FilterChip(
                    label: Text('Hoy', style: TextStyle(color: Colors.white)),
                    selected: _selectedFilter == 'Hoy',
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedFilter = 'Hoy';
                      });
                    },
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                  ),
                  SizedBox(width: 10),
                  FilterChip(
                    label: Text('Ayer', style: TextStyle(color: Colors.white)),
                    selected: _selectedFilter == 'Ayer',
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedFilter = 'Ayer';
                      });
                    },
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                  ),
                  SizedBox(width: 10),
                  FilterChip(
                    label: Text('La semana pasada', style: TextStyle(color: Colors.white)),
                    selected: _selectedFilter == 'La semana pasada',
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedFilter = 'La semana pasada';
                      });
                    },
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                  ),
                  SizedBox(width: 10),
                  FilterChip(
                    label: Text('El mes pasado', style: TextStyle(color: Colors.white)),
                    selected: _selectedFilter == 'El mes pasado',
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedFilter = 'El mes pasado';
                      });
                    },
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshNotifications,
              child: ListView.builder(
                itemCount: filteredNotifications.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(filteredNotifications[index]['mensaje']),
                    onDismissed: (direction) {
                      _removeNotification(index);
                    },
                    background: Container(color: Color.fromARGB(255, 255, 255, 255)),
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: ListTile(
                        title: Text(filteredNotifications[index]['mensaje']),
                        subtitle: Text(filteredNotifications[index]['fecha_envio'].substring(0, 10)),
                        trailing: Icon(Icons.notifications, color: Theme.of(context).colorScheme.tertiary,),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
