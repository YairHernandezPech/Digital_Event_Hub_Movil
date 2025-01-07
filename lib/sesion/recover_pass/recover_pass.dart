import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:digital_event_hub/sesion/login/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class RecoverPass extends StatelessWidget {
  //const name({super.key});

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final url = Uri.parse('http://10.0.2.2:5000/api/reset-password/629cc839f6bb29617fe6cb84610a869f919db3d9/');

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cambio de Contraseña'),
          content: Text('La contraseña ha sido cambiada exitosamente.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí puedes añadir cualquier acción adicional que desees realizar
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SignInScreen()), // Navega a la página de login
                );
              },
            ),
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí puedes añadir cualquier acción adicional que desees realizar
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SignInScreen()), // Navega a la página de login
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.jpg',
                  height: 100,
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Hide password input
                  decoration: InputDecoration(
                    labelText: 'Contraseña nueva',
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                  )
                ),
                const SizedBox(height: 10),
                GradientButton(
                  text: 'Confirmar cambio',
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 212, 172, 255),
                      Color.fromARGB(255, 162, 0, 255),
                    ],
                  ),
                  onPressed: () async {
                    String password = _passwordController.text;
                    Map<String, dynamic> data = {
                      'newPassword': password,
                    };
                    String jsonData = jsonEncode(data);

                    final response = await http.post(
                      url,
                      headers: <String, String>{
                        'Content-Type': 'application/json',
                      },
                      body: jsonData,
                    );

                    if (response.statusCode == 200) {
                      var decodedResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
                      print('Respuesta: $decodedResponse');
                      // Handle successful password change (e.g., show confirmation message)
                    } else {
                      // Handle error (e.g., show error message)
                      print('Error: ${response.statusCode}');
                    }
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
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero, // Eliminar el padding predeterminado
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Container(
          alignment: Alignment.center,
          width: double
              .infinity, // Hacer que el botón ocupe todo el ancho disponible
          padding: EdgeInsets.symmetric(
              vertical:
                  16.0), // Ajustar el padding vertical para cambiar la altura
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0, // Ajustar el tamaño de la fuente
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
