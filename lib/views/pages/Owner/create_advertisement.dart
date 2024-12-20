import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:senecard/views/pages/Owner/owner_page.dart';
import 'package:senecard/view_models/owner/advertisement_viewmodel.dart';

class CreateAdvertisementPage extends StatefulWidget {
  final String storeId; // Recibe el ID de la tienda

  const CreateAdvertisementPage({super.key, required this.storeId});

  @override
  CreateAdvertisementPageState createState() => CreateAdvertisementPageState();
}

class CreateAdvertisementPageState extends State<CreateAdvertisementPage> {
  File? _image;
  final TextEditingController _descriptionController = TextEditingController(); // Controlador para la descripción
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    // Escuchar cambios en el estado de la conectividad
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        // Si no hay conexión, redirigir a la pantalla de OwnerPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OwnerPage(storeId: widget.storeId),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No internet connection. Returning to Owner Page.')),
        );
      }
    });
  }

  @override
  void dispose() {
    // Cancelar la suscripción al estado de conectividad
    _connectivitySubscription.cancel();
    _descriptionController.dispose();
    super.dispose();
  }

  // Función para obtener la imagen desde la galería
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Convertir la imagen seleccionada en un archivo
      });
    }
  }

  // Función para guardar el anuncio
  void _saveAdvertisement() {
    if (_image == null || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide both an image and a description.')),
      );
      return;
    }

    final advertisementViewModel = Provider.of<AdvertisementViewModel>(context, listen: false);

    // Llamamos al ViewModel para crear el anuncio con la imagen y la descripción
    advertisementViewModel.createAdvertisement(
      storeId: widget.storeId, // Pasamos el storeId desde el widget
      description: _descriptionController.text, // Descripción del anuncio
      image: _image!, // Imagen del anuncio
    );

    // Mostrar mensaje de éxito y regresar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Advertisement created successfully!')),
    );
    Navigator.pop(context); // Volver a la página anterior después de crear el anuncio
  }

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
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Create Advertisement',
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
            // Widget para subir imagen
            GestureDetector(
              onTap: _pickImage, // Al hacer clic se abre la galería
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _image == null
                    ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file, size: 50, color: Colors.black54),
                    SizedBox(height: 10),
                    Text('Upload An Image', style: TextStyle(color: Colors.black54)),
                  ],
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Campo de descripción
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _descriptionController, // Controlador para capturar la descripción
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter description...',
                ),
                maxLines: 3,
              ),
            ),
            const Spacer(),
            // Botones de guardar y cancelar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _saveAdvertisement, // Llamar a la función de guardar
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0), // Aumenta el padding
                    minimumSize: const Size(150, 60), // Ancho y alto mínimo del botón
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Acción al cancelar
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0), // Aumenta el padding
                    minimumSize: const Size(150, 60), // Ancho y alto mínimo del botón
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
