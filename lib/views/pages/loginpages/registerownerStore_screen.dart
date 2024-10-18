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
    MaterialPageRoute(builder: (context) => RegisterownerPage()),
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
  String? _storeId; // Almacenar el ID de la tienda

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

  Future<void> pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _storeImage = pickedImage;
    });
  }

  Future<void> _registerStore() async {
    if (_storeImage == null) {
      SnackbarHelper.showSnackBar('Please select an image for the store.');
      return;
    }

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Llamar al método para registrar la tienda
        DocumentReference storeRef = await _firebaseAuthService.registerStore(
          storeName: nameStoreController.text,
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
    } catch (e) {
      SnackbarHelper.showSnackBar('Failed to register store: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Row(
            children: [
              IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.orange),
                  onPressed: () {
                    _navigateToRegisterownerPage(context); // Regresar a la pantalla anterior
                  }),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Store Owner',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            'Enter the information of the store',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STORE NAME', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                AppTextFormField(
                  controller: nameStoreController,
                  labelText: 'Store Name',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text, // Tipo de texto para nombre de tienda
                  validator: (value) {
                    return value!.isEmpty ? 'Please enter store name' : null;
                  },
                ),
                SizedBox(height: 20),
                Text('STORE ADDRESS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                AppTextFormField(
                  controller: addressController,
                  labelText: 'Store Address',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.streetAddress, // Tipo de dirección para la dirección
                  validator: (value) {
                    return value!.isEmpty ? 'Please enter store address' : null;
                  },
                ),
                SizedBox(height: 20),
                Text('STORE CATEGORY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                AppTextFormField(
                  controller: categoryController,
                  labelText: 'Store Category',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text, // Tipo de texto para categoría
                  validator: (value) {
                    return value!.isEmpty ? 'Please enter store category' : null;
                  },
                ),
                SizedBox(height: 20),
                Text('STORE IMAGE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
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
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _registerStore(); // Registrar la tienda y redirigir a la pantalla de horarios
                      }
                    },
                    child: Text('NEXT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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
