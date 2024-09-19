import 'package:digital_event_hub/sesion/create_count/ApiServiceCount.dart';
import 'package:digital_event_hub/sesion/login/login.dart';
import 'package:flutter/material.dart';

class CreateCount extends StatefulWidget {
  @override
  _CreateCountState createState() => _CreateCountState();
}

class _CreateCountState extends State<CreateCount> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final ApiServiceCount _apiServiceCount = ApiServiceCount();

  void _register(BuildContext context) async {
    final Map<String, dynamic> data = {
      'nombre': _nameController.text,
      'email': _emailController.text,
      'last_name': _lastNameController.text,
      'contrasena': _passwordController.text,
      'telefono': _phoneController.text,
      'rol_id': 2,
    };

    try {
      await _apiServiceCount.register(data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Cuenta creada exitosamente'))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Center(
                child: Text('Error al crear la cuenta, intente de nuevo'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.jpg',
                  height: 70,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Crear cuenta',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Color.fromARGB(255, 137, 64, 255),
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Apellidos',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefono',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                GradientButton(
                  text: 'Crear cuenta',
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 153, 0, 255),
                      Color.fromARGB(255, 218, 163, 255)
                    ],
                  ),
                  onPressed: () => _register(context),
                ),
                const SizedBox(height: 10),
                GradientButton(
                  text: 'Ya tengo una cuenta',
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 153, 0, 255),
                      Color.fromARGB(255, 218, 163, 255)
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignInScreen()));
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
