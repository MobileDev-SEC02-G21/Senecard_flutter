import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

void _navigateToStoreSchedulePage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => StoreSchedulePage()),
  );
}

class _RegisterownerStorePageState extends State<RegisterownerStorePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nameStoreController;
  late final TextEditingController addressController;
  late final TextEditingController categoryController;
  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);
  XFile? _storeImage;
  final ImagePicker _picker = ImagePicker();

  void initializeControllers() {
    nameStoreController = TextEditingController()..addListener(controllerListener);
    addressController = TextEditingController()..addListener(controllerListener);
    categoryController = TextEditingController()..addListener(controllerListener);
  }

  void disposeControllers() {
    nameStoreController.dispose();
    addressController.dispose();
    categoryController.dispose();
  }

  void controllerListener() {
    final name = nameStoreController.text;
    final address = addressController.text;
    final category = categoryController.text;

    if (name.isEmpty && address.isEmpty && category.isEmpty) return;

    if (name.length >= 4 && address.length >= 4 && category.isNotEmpty) {
      fieldValidNotifier.value = true;
    } else {
      fieldValidNotifier.value = false;
    }
  }

  Future<void> pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _storeImage = pickedImage;
    });
  }

  @override
  void initState() {
    initializeControllers();
    super.initState();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
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
                  _navigateToRegisterownerPage(context);
                }
              ),
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
                  autofocus: true,
                  controller: nameStoreController,
                  labelText: 'Store Name',
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.orange.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => _formKey.currentState?.validate(),
                  validator: (value) {
                    return value!.isEmpty
                        ? 'Please enter store name'
                        : value.length < 4
                        ? 'Store name must be at least 4 characters long'
                        : null;
                  },
                ),
                SizedBox(height: 20),
                Text('STORE ADDRESS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                AppTextFormField(
                  controller: addressController,
                  labelText: 'Store Address',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.streetAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.orange.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => _formKey.currentState?.validate(),
                  validator: (value) {
                    return value!.isEmpty
                        ? 'Please enter address'
                        : value.length < 10
                        ? 'Address direction must be at least 10 characters long'
                        : null;
                  },
                ),
                SizedBox(height: 20),
                Text('STORE CATEGORY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                AppTextFormField(
                  controller: categoryController,
                  labelText: 'Store Category',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.orange.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                  onChanged: (_) => _formKey.currentState?.validate(),
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
                ValueListenableBuilder(
                  valueListenable: fieldValidNotifier,
                  builder: (_, isValid, __) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isValid
                            ? () {
                          _navigateToStoreSchedulePage(context);
                          SnackbarHelper.showSnackBar('Registration Complete');
                          nameStoreController.clear();
                          addressController.clear();
                          categoryController.clear();
                          setState(() {
                            _storeImage = null;
                          });
                        }
                            : null,
                        child: Text('NEXT'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}