import 'package:digital_event_hub/home/eventsList.dart';
import 'package:digital_event_hub/sesion/login/login.dart';
import 'package:digital_event_hub/theme/theme.dart';
import 'package:digital_event_hub/widgets/Splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:digital_event_hub/sesion/login/ApiServiceLogin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Stripe si es necesario
  Stripe.publishableKey =
      "pk_test_51PXQwjRvOexYqm868BaEds2SOFXYVM32nhnnBCKNUvDiyf14mBpHoFETJYJ7kdLPrQ2VuXHLp5hwgJsHMlYCl6x400OGvYJj9h";

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(theme1),
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

    // Mostrar el SplashScreen por 3 segundos.
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  // Método para verificar si el usuario está logueado
  void _checkUserLoginStatus() async {
    bool isLoggedIn = await ApiServiceLogin().isUserLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, theme, child) {
        return MaterialApp(
          theme: theme.currentTheme,
          debugShowCheckedModeBanner: false,
          home: _showSplash
              ? SplashScreen()
              : (_isLoggedIn
                  ? EventsList()
                  : SignInScreen()), // Si el usuario está logueado, muestra la pantalla principal; de lo contrario, la de inicio de sesión
        );
      },
    );
  }
}
