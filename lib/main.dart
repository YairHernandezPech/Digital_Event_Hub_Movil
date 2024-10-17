import 'package:digital_event_hub/sesion/login/ApiServiceLogin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/theme.dart';
import 'home/eventsList.dart';
import 'sesion/login/login.dart';
import 'widgets/Splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar el tema guardado al iniciar la aplicación
  final prefs = await SharedPreferences.getInstance();
  int themeIndex = prefs.getInt('selectedTheme') ?? 0;

  // Lista de temas disponibles
  List<ThemeData> themes = [theme1, theme2, theme3, theme4];
  ThemeData initialTheme = themes[themeIndex];

  Stripe.publishableKey =
      "pk_test_51PXQwjRvOexYqm868BaEds2SOFXYVM32nhnnBCKNUvDiyf14mBpHoFETJYJ7kdLPrQ2VuXHLp5hwgJsHMlYCl6x400OGvYJj9h";
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(initialTheme),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();

    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  void _checkUserLoginStatus() async {
    bool isLoggedIn = await ApiServiceLogin().isUserLoggedIn();
    // Simular verificación del inicio de sesión del usuario
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          theme: themeNotifier.currentTheme,
          debugShowCheckedModeBanner: false,
          home: _showSplash
              ? SplashScreen()
              : (_isLoggedIn ? EventsList() : SignInScreen()),
        );
      },
    );
  }
}
