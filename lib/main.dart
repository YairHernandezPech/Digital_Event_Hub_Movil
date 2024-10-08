import 'package:digital_event_hub/sesion/login/login.dart';
import 'package:digital_event_hub/theme/theme.dart';
import 'package:digital_event_hub/widgets/Splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = "pk_test_51PXQwjRvOexYqm868BaEds2SOFXYVM32nhnnBCKNUvDiyf14mBpHoFETJYJ7kdLPrQ2VuXHLp5hwgJsHMlYCl6x400OGvYJj9h";

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(theme1),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Mostrar el SplashScreen por 3 segundos.
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, theme, child) {
        return MaterialApp(
          theme: theme.currentTheme,
          debugShowCheckedModeBanner: false,
          home: _showSplash ? SplashScreen() : SignInScreen(), // Mostrar SplashScreen primero, luego SignInScreen
        );
      },
    );
  }
}