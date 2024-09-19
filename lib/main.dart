import 'package:digital_event_hub/sesion/login/login.dart';
import 'package:digital_event_hub/theme/theme.dart';
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, theme, child) {
        return MaterialApp(
          theme: theme.currentTheme,
          debugShowCheckedModeBanner: false,
          home: SignInScreen(),
        );
      },
    );
  }
}
// import 'package:digital_event_hub/sesion/login/login.dart';
// import 'package:flutter/material.dart';

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SignInScreen(),
//     );
//   }
// }