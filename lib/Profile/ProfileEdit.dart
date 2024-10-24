import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'ApiServiceProfile.dart';
import 'ProfileHome.dart';

class ProfileEdith extends StatefulWidget {
  @override
  _ProfileEdithState createState() => _ProfileEdithState();
}

class _ProfileEdithState extends State<ProfileEdith> {
  File? _image;
  String? _imageUrl;
  final String _defaultImagePath = 'assets/profile.png';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  ApiServiceProfile apiService = ApiServiceProfile();
  bool _isLoading = true;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Guarda la imagen seleccionada en la memoria interna
      final directory = await getApplicationDocumentsDirectory();
      final String dirPath = directory.path;
      final String fileName = path.basename(pickedFile.path);
      final File localImage = await imageFile.copy('$dirPath/$fileName');

      setState(() {
        _image = localImage;
        _imageUrl = localImage.path; // Guarda la URL de la imagen
        print('Image path: $_imageUrl');
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final userData = await apiService.fetchUserData();
      setState(() {
        _nameController.text = userData['nombre'];
        _emailController.text = userData['email'];
        _phoneController.text = userData['telefono'];
        _imageUrl = userData['fotoPerfil'];
        _lastNameController.text = userData['last_name'];
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    try {
      final updatedData = {
        'nombre': _nameController.text,
        'email': _emailController.text,
        'telefono': _phoneController.text,
        'fotoPerfil': _imageUrl,
        'last_name': _lastNameController.text
      };
      await apiService.updateUserData(updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(child: Text('Perfil actualizado exitosamente')),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileHome()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el perfil: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: _image == null
                            ? _imageUrl == null
                                ? AssetImage(_defaultImagePath)
                                : _imageUrl!.startsWith('http')
                                    ? NetworkImage(_imageUrl!)
                                    : FileImage(File(_imageUrl!))
                            : FileImage(_image!) as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showImagePickerDialog(),
                          child: const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.camera_alt, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                  _buildProfileTextField(
                    icon: Icons.person,
                    hintText: 'Name',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 20),
                  _buildProfileTextField(
                    icon: Icons.person,
                    hintText: 'Last Name',
                    controller: _lastNameController,
                  ),
                  const SizedBox(height: 20),
                  _buildProfileTextField(
                    icon: Icons.phone,
                    hintText: '+52(999)929737',
                    controller: _phoneController,
                  ),
                  const SizedBox(height: 40),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileTextField({
    required IconData icon,
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textAlign: TextAlign.left,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFB5B5B5)),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD2D2D2)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButton('Cancelar', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfileHome()),
            );
          }),
          _buildButton('Guardar', _updateProfile),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child:
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Elige una opción')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogButton('Selecciona una imagen', () {
              _pickImage(ImageSource.gallery);
              Navigator.pop(context);
            }),
            const SizedBox(height: 10),
            _buildDialogButton('Tomar foto', () {
              _pickImage(ImageSource.camera);
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}