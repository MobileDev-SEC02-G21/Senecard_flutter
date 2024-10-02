import 'package:flutter/material.dart';

class BusinessInfoPage extends StatelessWidget {
  const BusinessInfoPage({super.key});

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
            Navigator.pop(context); // Regresar a la pantalla anterior
          },
        ),
        title: const Text(
          'Business Info',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Acción para editar la información
            },
            child: const Text(
              'EDIT',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Foto del negocio (puedes reemplazarlo con una imagen real)

            const SizedBox(height: 20),
            // Nombre del negocio
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.orange[100], // Color de fondo (imagen del negocio)
                  child: const Icon(
                    Icons.store, // Ícono de negocio
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20), // Espaciado entre la imagen y el texto
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'One Burrito',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Best Burritos',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),
            // Caja de información del negocio
            Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    icon: Icons.person,
                    label: 'FULL NAME',
                    value: 'Andres Escobar',
                  ),
                  const SizedBox(height: 15),
                  _buildInfoRow(
                    icon: Icons.email,
                    label: 'EMAIL',
                    value: 'a.escobar@uniandes.edu.co',
                  ),
                  const SizedBox(height: 15),
                  _buildInfoRow(
                    icon: Icons.location_on,
                    label: 'ADDRESS',
                    value: '408-841-0926',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper para construir filas de información
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.black),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
