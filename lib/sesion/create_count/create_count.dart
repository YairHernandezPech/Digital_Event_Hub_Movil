import 'package:digital_event_hub/home/eventsList.dart';
import 'package:digital_event_hub/sesion/create_count/ApiServiceCount.dart';
import 'package:digital_event_hub/sesion/login/ApiServiceLogin.dart';
import 'package:digital_event_hub/sesion/login/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateCount extends StatefulWidget {
  const CreateCount({super.key});

  @override
  State<CreateCount> createState() => _CreateCountState();
}

class _CreateCountState extends State<CreateCount> {
  bool _isObscured = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final ApiServiceCount _apiServiceCount = ApiServiceCount();
  final ApiServiceLogin _apiServiceLogin = ApiServiceLogin();

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  //* Función para registrar y luego iniciar sesión automáticamente
  void _register(BuildContext context) async {
    final Map<String, dynamic> data = {
      'nombre': nameController.text,
      'email': emailController.text,
      'last_name': lastNameController.text,
      'contrasena': passwordController.text,
      'telefono': phoneController.text,
      'rol_id': 2, // Puedes cambiar el rol si es necesario
    };

    try {
      // Registrar al usuario
      await _apiServiceCount.register(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada exitosamente')),
      );

      // Iniciar sesión automáticamente tras el registro
      final loginData = {
        'email': emailController.text,
        'contrasena': passwordController.text,
      };

      // Obtener la respuesta de login
      final response = await _apiServiceLogin.login(loginData);

      // Verificar si se recibió el token
      if (response.containsKey('token')) {
        String token = response['token'];

        // Guardar el token en SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        // Navegar a la pantalla de EventsList después de guardar el token
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EventsList()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error al crear la cuenta o iniciar sesión, intente de nuevo',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: ColorFiltered(
              colorFilter:
                  const ColorFilter.mode(Colors.purple, BlendMode.srcATop),
              child: Image.asset(
                'assets/main_top.png',
                width: size.width * 0.37,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                // Permite hacer scroll cuando el teclado aparece
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                          Color(0xFF6F35A5), BlendMode.srcATop),
                      child: Image.asset(
                        'assets/LOGO HUB BLANCO 1.png',
                        fit: BoxFit.cover,
                        width: 200,
                      ),
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      nameController,
                      'Nombre:',
                      const Icon(Icons.person, color: Color(0xFF6F35A5)),
                    ),
                    const SizedBox(height: 10),
                    buildTextField(
                      lastNameController,
                      'Apellido:',
                      const Icon(Icons.person, color: Color(0xFF6F35A5)),
                    ),
                    const SizedBox(height: 10),
                    buildTextField(
                      emailController,
                      'Correo Electrónico:',
                      const Icon(Icons.email, color: Color(0xFF6F35A5)),
                    ),
                    const SizedBox(height: 10),
                    buildTextField(
                      phoneController,
                      'Teléfono:',
                      const Icon(Icons.phone, color: Color(0xFF6F35A5)),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 325,
                      child: TextField(
                        controller: passwordController,
                        obscureText: _isObscured,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(255, 234, 219, 252),
                          labelText: 'Contraseña:',
                          labelStyle: GoogleFonts.openSans(
                            color: const Color.fromARGB(255, 86, 86, 86),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          prefixIcon:
                              const Icon(Icons.lock, color: Color(0xFF6F35A5)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFF6F35A5),
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _register(context),
                      child: Container(
                        width: 250,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.purple,
                              Colors.deepPurple,
                              Colors.purpleAccent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Registrar',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.openSans(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "¿Ya tienes una cuenta?",
                          style: GoogleFonts.openSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignInScreen()),
                            );
                          },
                          child: Text(
                            "Inicia sesión",
                            style: GoogleFonts.openSans(
                              fontSize: 16,
                              color: Color(0xFF6F35A5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(
      TextEditingController controller, String labelText, Icon icon) {
    return SizedBox(
      width: 325,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color.fromARGB(255, 234, 219, 252),
          labelText: labelText,
          labelStyle: GoogleFonts.openSans(
            color: const Color.fromARGB(255, 86, 86, 86),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: icon,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
      ),
    );
  }
}
