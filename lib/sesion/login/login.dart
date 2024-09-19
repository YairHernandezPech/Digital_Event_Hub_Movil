import 'package:digital_event_hub/home/eventsList.dart';
import 'package:digital_event_hub/sesion/create_count/create_count.dart';
import 'package:digital_event_hub/sesion/login/ApiServiceLogin.dart';
import 'package:digital_event_hub/sesion/recover_pass/confirm_email.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ApiServiceLogin _apiServiceLogin = ApiServiceLogin();

  void _login(BuildContext context) async {
    final Map<String, dynamic> data = {
      'email': _emailController.text,
      'contrasena': _passwordController.text,
    };

    try {
      final response = await _apiServiceLogin.login(data);
      if (response.containsKey('token')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventsList()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Center(child: Text('Error al iniciar sesión'))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Error al iniciar sesión'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.jpg', // Asegúrate de tener el logo en la carpeta assets
                  height: 250,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo o username...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ConfirmEmail()),
                      );
                    },
                    child: Text(
                      'Olvidé mi contraseña',
                      style: TextStyle(color: Colors.pinkAccent),
                    ),
                  ),
                ),
                SizedBox(height: 0),
                GradientButton(
                  text: 'Ingresar',
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 212, 172, 255),
                      Color.fromARGB(255, 162, 0, 255),
                    ],
                  ),
                  onPressed: () => _login(context),
                ),
                SizedBox(height: 10),
                GradientButton(
                  text: 'Crear Cuenta',
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 153, 0, 255),
                      Color.fromARGB(255, 218, 163, 255),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateCount()),
                    );
                  },
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final VoidCallback onPressed;

  const GradientButton({
    Key? key,
    required this.text,
    required this.gradient,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Text(
            text,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
