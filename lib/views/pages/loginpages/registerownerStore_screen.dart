import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/FirebaseAuthService.dart';
import '../../elements/login/components/app_text_form_field.dart';
import 'dart:io';
import '../../elements/login/utils/helpers/snackbar_helper.dart';

import 'package:senecard/views/pages/loginpages/registerowner_screen.dart';
import 'package:senecard/views/pages/loginpages/registerownerStoreHorario_screen.dart';

class RegisterownerStorePage extends StatefulWidget {
  const RegisterownerStorePage({super.key});

  @override
  State<RegisterownerStorePage> createState() => _RegisterownerStorePageState();
}

void _navigateToRegisterownerPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const RegisterownerPage()),
  );
}

void _navigateToStoreSchedulePage(BuildContext context, String storeId) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => StoreSchedulePage(storeId: storeId)),
  );
}

class _RegisterownerStorePageState extends State<RegisterownerStorePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nameStoreController;
  late final TextEditingController addressController;
  late final TextEditingController categoryController;
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  XFile? _storeImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    nameStoreController = TextEditingController();
    addressController = TextEditingController();
    categoryController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    nameStoreController.dispose();
    addressController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.orange), // Indicador de carga
                const SizedBox(height: 20),
                const Text(
                  "Loading",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Please wait one moment while processing the information",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 60), // Icono de error
                const SizedBox(height: 20),
                const Text(
                  "Error",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 10),
                const Text(
                  " diligencie la informacion correctamente.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el popup de error

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Aceptar", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // Función para mostrar el Dialog de error
  void showErrorimageDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 60), // Icono de error
                const SizedBox(height: 20),
                const Text(
                  "Error",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 10),
                const Text(
                  " Hace falta la imagen para continuar el registro.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el popup de error

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Aceptar", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Función para mostrar el Dialog de error
  void showErrorConectionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 60), // Icono de error
                const SizedBox(height: 20),
                const Text(
                  "Error",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 10),
                const Text(
                  "No Se pudo completar la acción, porque no existe conexión a internet,\n conectesé e intenté de nuevo.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el popup de error
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Aceptar", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _storeImage = pickedImage;
    });
  }

  Future<void> _registerStore() async {
    if (_storeImage == null) {
      showErrorimageDialog(context);
      SnackbarHelper.showSnackBar('Please select an image for the store.');
      return;
    }

    try {

      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        showLoadingDialog(context);
        // Llamar al método para registrar la tienda
        DocumentReference storeRef = await _firebaseAuthService.registerStore(
          name: nameStoreController.text,
          address: addressController.text,
          category: categoryController.text,
          storeImage: File(_storeImage!.path), // Convertir XFile a File
          businessOwnerId: currentUser.uid, // Usar el UID del usuario autenticado
        );

        // Obtener el ID de la tienda recién creada
        String storeId = storeRef.id;

        // Redirigir a la página de horarios con el ID de la tienda
        _navigateToStoreSchedulePage(context, storeId);
      }
      else {
        // Si el inicio de sesión falla sin excepción específica
        showErrorConectionDialog(context);

      }


    } catch (e) {
      showErrorConectionDialog(context);
      SnackbarHelper.showSnackBar('Failed to register store: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.orange),
                  onPressed: () {
                    _navigateToRegisterownerPage(context); // Regresar a la pantalla anterior
                  }),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Store Owner',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter the information of the store',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('STORE NAME', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                AppTextFormField(
                  controller: nameStoreController,
                  labelText: 'Store Name',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text, // Tipo de texto para nombre de tienda
                  validator: (value) {
                    return value!.isEmpty ? 'Please enter store name' : null;
                  },
                ),
                const SizedBox(height: 20),
                const Text('STORE ADDRESS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                AppTextFormField(
                  controller: addressController,
                  labelText: 'Store Address',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.streetAddress, // Tipo de dirección para la dirección
                  validator: (value) {
                    return value!.isEmpty ? 'Please enter store address' : null;
                  },
                ),
                const SizedBox(height: 20),
                const Text('STORE CATEGORY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                AppTextFormField(
                  controller: categoryController,
                  labelText: 'Store Category',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text, // Tipo de texto para categoría
                  validator: (value) {
                    return value!.isEmpty ? 'Please enter store category' : null;
                  },
                ),
                const SizedBox(height: 20),
                const Text('STORE IMAGE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _storeImage == null
                        ? Center(
                      child: Icon(
                        Icons.add_a_photo,
                        color: Colors.grey[800],
                        size: 50,
                      ),
                    )
                        : Image.file(
                      File(_storeImage!.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _registerStore(); // Registrar la tienda y redirigir a la pantalla de horarios
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('NEXT'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
