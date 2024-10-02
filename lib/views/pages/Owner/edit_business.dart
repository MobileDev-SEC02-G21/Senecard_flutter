import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController(text: 'One Burrito');
  final TextEditingController emailController = TextEditingController(text: 'hello@halallab.co');
  final TextEditingController addressController = TextEditingController(text: 'Cra 3 #16-55');
  final TextEditingController descriptionController = TextEditingController(text: 'I love fast food');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Volver a la pantalla anterior
          },
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Foto de perfil editable
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.orange[100],
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // Acción para cambiar la imagen de perfil
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Campo: Business Name
            const Text('BUSINESS NAME', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            _buildTextField(nameController),
            const SizedBox(height: 20),
            // Campo: Email
            const Text('EMAIL', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            _buildTextField(emailController),
            const SizedBox(height: 20),
            // Campo: Address
            const Text('ADDRESS', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            _buildTextField(addressController),
            const SizedBox(height: 20),
            // Campo: Description
            const Text('DESCRIPTION', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            _buildTextField(descriptionController, maxLines: 3),
            const Spacer(),
            // Botón: Save
            ElevatedButton(
              onPressed: () {
                // Acción al guardar los cambios
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                minimumSize: const Size(double.infinity, 50), // Botón de ancho completo
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'SAVE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Método para construir los campos de texto
  Widget _buildTextField(TextEditingController controller, {int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }
}
