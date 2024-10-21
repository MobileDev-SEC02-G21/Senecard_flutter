import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senecard/view_models/owner/business_viewmodel.dart';
import 'edit_business.dart';  // Importa la página EditBusinessPage

class BusinessInfoPage extends StatefulWidget {
  final String storeId; // Recibe el ID de la tienda

  const BusinessInfoPage({super.key, required this.storeId});

  @override
  _BusinessInfoPageState createState() => _BusinessInfoPageState();
}

class _BusinessInfoPageState extends State<BusinessInfoPage> {
  @override
  void initState() {
    super.initState();
    // Llamamos a la función del ViewModel para obtener los datos del negocio
    final businessInfoViewModel = Provider.of<BusinessInfoViewModel>(context, listen: false);
    businessInfoViewModel.fetchStoreData(widget.storeId);
  }

  @override
  Widget build(BuildContext context) {
    final businessInfoViewModel = Provider.of<BusinessInfoViewModel>(context);

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
              // Navegar a la página de edición pasando el storeId
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(storeId: widget.storeId),
                ),
              );
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
      body: businessInfoViewModel.isLoading
          ? const Center(child: CircularProgressIndicator()) // Mostrar un indicador de carga
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessInfoViewModel.storeName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      businessInfoViewModel.category,
                      style: const TextStyle(
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
                    value: businessInfoViewModel.ownerName,
                  ),
                  const SizedBox(height: 15),
                  _buildInfoRow(
                    icon: Icons.email,
                    label: 'EMAIL',
                    value: businessInfoViewModel.ownerEmail,
                  ),
                  const SizedBox(height: 15),
                  _buildInfoRow(
                    icon: Icons.location_on,
                    label: 'ADDRESS',
                    value: businessInfoViewModel.storeAddress,
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
