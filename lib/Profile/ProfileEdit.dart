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
  final TextEditingController _contrasenaController = TextEditingController();

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
        _imageUrl = userData['fotoPerfil']; // Asigna la URL de la imagen existente
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
        'contrasena': _contrasenaController.text,
        'fotoPerfil': _imageUrl,
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
    _contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Spacer(flex: 1),
                      Center(
                        child: Stack(
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
                                onTap: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: const Center(
                                          child: Text('Elige una opción')),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              _pickImage(ImageSource.gallery);
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 40,
                                                      vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ), // Color del botón
                                            ),
                                            child: const Text(
                                              'Selecciona una imagen',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.0),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          ElevatedButton(
                                            onPressed: () {
                                              _pickImage(ImageSource.camera);
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 40,
                                                      vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ), // Color del botón
                                            ),
                                            child: const Text(
                                              'Tomar foto',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.grey,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),
                      _buildProfileTextField(
                          Icons.person, 'Eider Pool', _nameController),
                      const SizedBox(height: 20),
                      _buildProfileTextField(
                          Icons.email, 'John@gmail.com', _emailController),
                      const SizedBox(height: 20),
                      _buildProfileTextField(
                          Icons.phone, '+52(999)929737', _phoneController),
                      const SizedBox(height: 20),
                      _buildProfileTextField(Icons.lock, '*************', _contrasenaController,
                          obscureText: false),
                      const Spacer(flex: 3),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 70.0,
                  left: 16.0,
                  right: 16.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.tertiary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 55, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileHome()),
                          );
                        },
                        child: const Text('Cancelar',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.tertiary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 55, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _updateProfile,
                        child: const Text('Guardar',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileTextField(
      IconData icon, String hintText, TextEditingController? controller,
      {bool obscureText = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2.0),
          child: Icon(icon, color: Colors.grey),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
            ),
          ),
        ),
      ],
    );
  }
}
