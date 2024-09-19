import 'dart:io';  // Asegúrate de importar dart:io para usar FileImage
import 'package:digital_event_hub/Profile/ProfileHome.dart';
import 'package:flutter/material.dart';

class HeaderHome extends StatelessWidget {
  final String? username;
  final String? fotoPerfil;

  // Constructor
  HeaderHome(this.username, this.fotoPerfil);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username != null && username!.isNotEmpty ? "Hola, $username" : "Hola!",
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Text(
              'Bienvenido',
              style: TextStyle(
                fontSize: 16.0,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
        Spacer(),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileHome()),
            );
          },
          child: CircleAvatar(
            radius: 24.0,
            child: ClipOval(
              child: FadeInImage(
                placeholder: const AssetImage('assets/profile.png'), // Imagen predeterminada
                image: fotoPerfil != null && fotoPerfil!.isNotEmpty
                    ? (fotoPerfil!.startsWith('http')
                        ? NetworkImage(fotoPerfil!)
                        : FileImage(File(fotoPerfil!)) as ImageProvider)
                    : const AssetImage('assets/profile.png'),
                fit: BoxFit.cover,
                width: 48.0,
                height: 48.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
