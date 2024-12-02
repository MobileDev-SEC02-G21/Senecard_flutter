import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:senecard/view_models/owner/edit_business_viewmodel.dart';

class EditProfilePage extends StatefulWidget {
  final String storeId;

  const EditProfilePage({super.key, required this.storeId});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  File? _image;
  bool _isDataLoaded = false; // Flag para evitar múltiples llamadas

  late StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    // Escuchar cambios en el estado de conectividad
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No internet connection.')),
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      final viewModel = Provider.of<EditBusinessViewModel>(context, listen: false);
      viewModel.fetchStoreData(widget.storeId).then((_) {
        setState(() {
          nameController.text = viewModel.store?.name ?? '';
          addressController.text = viewModel.store?.address ?? '';
          _isDataLoaded = true;
        });
      });
    }
  }

  @override
  void dispose() {
    // Asegurar que la suscripción se haya inicializado antes de cancelarla
    _connectivitySubscription?.cancel();
    nameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Actualizar la imagen seleccionada
      });
    }
  }

  void _saveChanges() async {
    if (nameController.text.isEmpty || addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business name and address cannot be empty.')),
      );
      return;
    }

    final viewModel = Provider.of<EditBusinessViewModel>(context, listen: false);
    await viewModel.updateBusiness(
      widget.storeId,
      name: nameController.text,
      address: addressController.text,
      image: _image,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Business updated successfully!')),
    );
    Navigator.pop(context);
  }

  void _deleteBusiness() async {
    final viewModel = Provider.of<EditBusinessViewModel>(context, listen: false);
    await viewModel.deleteBusiness(widget.storeId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Business deleted successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EditBusinessViewModel>(context);

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
          'Edit Business',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView( // Permitir desplazamiento
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Foto del negocio editable
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                    image: _image != null
                        ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                        : viewModel.store?.image.isNotEmpty == true
                        ? DecorationImage(
                      image: NetworkImage(viewModel.store!.image),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: (_image == null && (viewModel.store?.image.isEmpty ?? true))
                      ? const Icon(Icons.camera_alt, size: 50, color: Colors.black54)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Campo: Business Name
            const Text('BUSINESS NAME', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            _buildTextField(nameController),
            const SizedBox(height: 20),
            // Campo: Address
            const Text('ADDRESS', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            _buildTextField(addressController),
            const SizedBox(height: 30),
            // Botón para eliminar el negocio
            ElevatedButton(
              onPressed: _deleteBusiness,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'DELETE BUSINESS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Botón para guardar cambios
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'SAVE CHANGES',
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

  Widget _buildTextField(TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }
}
