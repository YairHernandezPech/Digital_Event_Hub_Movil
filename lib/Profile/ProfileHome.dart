import 'package:digital_event_hub/Profile/ApiServiceProfile.dart';
import 'package:digital_event_hub/Profile/ProfileEdit.dart';
import 'package:digital_event_hub/home/eventsList.dart';
import 'package:digital_event_hub/sesion/login/login.dart';
import 'package:digital_event_hub/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:io';

class ProfileHome extends StatefulWidget {
  final List<ThemeData> themes = [theme1, theme2, theme3, theme4];
  ProfileHome({super.key});

  @override
  _ProfileHomeState createState() => _ProfileHomeState();
}

class _ProfileHomeState extends State<ProfileHome> {
  int selectedIndex = -1; // Índice del tema seleccionado
  ApiServiceProfile apiService = ApiServiceProfile();
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Este método asegura que los datos del perfil se recarguen cada vez que se muestra la pantalla
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchData(); // Recarga los datos del perfil cuando se entra a la pantalla
  }

  void fetchData() async {
    setState(() {
      isLoading = true; // Mostrar el estado de carga
    });
    try {
      final data = await apiService.fetchUserData();
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(''),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EventsList()),
            );
          },
        ),
      ),
      body: Skeletonizer(
        enabled: isLoading,
        child: Container(
          color: Colors.white, // Cambia el color de fondo aquí
          child: Column(
            children: [
              Stack(
                children: [
                  ClipPath(
                    clipper: NavbarClipper(),
                    child: Container(
                      height: 265.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100.0,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 1),
                        CircleAvatar(
                          radius: 80.0,
                          backgroundImage: userData?['fotoPerfil'] != null
                              ? (userData!['fotoPerfil'].startsWith('http')
                                  ? NetworkImage(userData!['fotoPerfil'])
                                  : FileImage(File(userData!['fotoPerfil'])))
                              : AssetImage('assets/profile.png')
                                  as ImageProvider,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10.0),
                      Text(
                        '${userData?['nombre'] ?? ''} ${userData?['last_name'] ?? 'Nombre no disponible'}',
                        style: const TextStyle(
                          fontSize: 35.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userData?['email'] ?? 'Correo no disponible',
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileEdith()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.tertiary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 35, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ), // Color del botón
                        ),
                        child: const Text(
                          'Editar Perfil',
                          style: TextStyle(color: Colors.white, fontSize: 25.0),
                        ),
                      ),
                      const SizedBox(height: 42.0),
                      const Text(
                        'Numero de telefono',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        userData?['telefono'] ?? 'Teléfono no disponible',
                        style: const TextStyle(
                          fontSize: 23.0,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      // const Text(
                      //   'Contraseña',
                      //   style: TextStyle(
                      //     fontSize: 23.0,
                      //     color: Colors.black,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      const SizedBox(height: 10.0),
                      // const Text(
                      //   '****************',
                      //   style: TextStyle(
                      //     fontSize: 23.0,
                      //     color: Colors.grey,
                      //   ),
                      // ),
                      const SizedBox(height: 90.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final themeColors = [
                            Color.fromARGB(255, 214, 113, 229),
                            Colors.pink.shade100,
                            Colors.purple.shade100,
                            Colors.blue.shade100,
                          ];

                          final themes = [
                            theme1,
                            theme2,
                            theme3,
                            theme4,
                          ];

                          return Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Provider.of<ThemeNotifier>(context,
                                          listen: false)
                                      .setTheme(themes[index], index);
                                  setState(() {
                                    selectedIndex =
                                        index; // Actualiza el índice seleccionado
                                  });
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 25.0,
                                      backgroundColor: themeColors[index],
                                    ),
                                    if (selectedIndex == index)
                                      const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10.0),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(height: 83.0),
                      ElevatedButton(
                        onPressed: () async {
                          // Eliminar los datos de la sesión (ejemplo usando SharedPreferences)
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs
                              .clear(); // Esto elimina todos los datos almacenados

                          // Navegar a la pantalla de inicio de sesión y eliminar todas las pantallas anteriores
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => SignInScreen()),
                            (Route<dynamic> route) =>
                                false, // Elimina todas las rutas anteriores
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.tertiary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 90, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cerrar sesión',
                          style: TextStyle(color: Colors.white, fontSize: 25.0),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavbarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 100);
    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width, size.height - 100);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}