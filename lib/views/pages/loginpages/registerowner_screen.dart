import 'package:flutter/material.dart';
import 'package:senecard/services/FirebaseAuthService.dart'; // Import your FirebaseAuthService
import '../../elements/login/components/app_text_form_field.dart';

import '../../elements/login/utils/helpers/snackbar_helper.dart';

import '../../elements/login/values/app_constants.dart';
import '../../elements/login/values/app_regex.dart';
import '../../elements/login/values/app_strings.dart';

import 'package:senecard/views/pages/loginpages/choose_screen.dart';
import 'package:senecard/views/pages/loginpages/registerownerStore_screen.dart';

class RegisterownerPage extends StatefulWidget {
  const RegisterownerPage({super.key});

  @override
  State<RegisterownerPage> createState() => _RegisterownerPageState();
}

void _navigateToRegisterSelectionPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => RegisterSelectionPage()),
  );
}

void _navigateToRegisterownerStorePage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => RegisterownerStorePage()),
  );
}

class _RegisterownerPageState extends State<RegisterownerPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService(); // Initialize FirebaseAuthService
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;
  final ValueNotifier<bool> passwordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> confirmPasswordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);

  void initializeControllers() {
    nameController = TextEditingController()..addListener(controllerListener);
    emailController = TextEditingController()..addListener(controllerListener);
    phoneController = TextEditingController()..addListener(controllerListener);
    passwordController = TextEditingController()..addListener(controllerListener);
    confirmPasswordController = TextEditingController()..addListener(controllerListener);
  }

  void disposeControllers() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  void controllerListener() {
    final name = nameController.text;
    final email = emailController.text;
    final phone = phoneController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty && email.isEmpty && phone.isEmpty && password.isEmpty && confirmPassword.isEmpty) return;

    if (AppRegex.emailRegex.hasMatch(email) &&
        AppRegex.phoneRegex.hasMatch(phone) &&
        AppRegex.passwordRegex.hasMatch(password) &&
        AppRegex.passwordRegex.hasMatch(confirmPassword)) {
      fieldValidNotifier.value = true;
    } else {
      fieldValidNotifier.value = false;
    }
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

  // Función para mostrar el Dialog de error
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
                  "El correo o la contraseña son incorrectos.",
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

  Future<void> _registerUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      final name = nameController.text;
      final email = emailController.text;
      final phone = phoneController.text;
      final password = passwordController.text;

      showLoadingDialog(context);

      try {
        // Register the user with the role "businessOwner"
        final user = await _firebaseAuthService.registerWithEmailAndPassword(
          email,
          password,
          name,
          phone,
          "businessOwner", // Assign the role of businessOwner
        );

        if (user != null) {
          // Navigate to the next page on successful registration
          _navigateToRegisterownerStorePage(context);
          SnackbarHelper.showSnackBar(AppStrings.registrationComplete);
          nameController.clear();
          emailController.clear();
          phoneController.clear();
          passwordController.clear();
          confirmPasswordController.clear();
        }
        else {
          showErrorConectionDialog(context);
          SnackbarHelper.showSnackBar('Registration failed. Please try again.');
        }

      } catch (e) {
        // error de conectividad con firebase
        showErrorConectionDialog(context);

      }
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
                  _navigateToRegisterSelectionPage(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Business Owner',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter the information',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NAME', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                AppTextFormField(
                  autofocus: true,
                  controller: nameController,
                  labelText: 'Name',
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => _formKey.currentState?.validate(),
                  validator: (value) {
                    return value!.isEmpty
                        ? AppStrings.pleaseEnterName
                        : (AppConstants.nameRegex.hasMatch(value)
                        ? null: AppStrings.invalidName);

                  },
                ),
                const SizedBox(height: 20),
                const Text('EMAIL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                AppTextFormField(
                  controller: emailController,
                  labelText: 'Email',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => _formKey.currentState?.validate(),
                  validator: (value) {
                    return value!.isEmpty
                        ? AppStrings.pleaseEnterEmailAddress
                        : AppConstants.emailRegex.hasMatch(value)
                        ? null
                        : AppStrings.invalidEmailAddress;
                  },
                ),
                const SizedBox(height: 20),
                const Text('PHONE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                AppTextFormField(
                  controller: phoneController,
                  labelText: 'Phone',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => _formKey.currentState?.validate(),
                  validator: (value) {
                    return value!.isEmpty
                        ? AppStrings.pleaseEnterPhone
                        : (AppConstants.phoneRegex.hasMatch(value)
                        ? null: AppStrings.invalidName);
                  },
                ),
                const SizedBox(height: 20),
                const Text('PASSWORD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                ValueListenableBuilder(
                  valueListenable: passwordNotifier,
                  builder: (_, passwordObscure, __) {
                    return AppTextFormField(
                      obscureText: passwordObscure,
                      controller: passwordController,
                      labelText: 'Password',
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) => _formKey.currentState?.validate(),
                      validator: (value) {
                        return value!.isEmpty
                            ? AppStrings.pleaseEnterPassword
                            : AppConstants.passwordRegex.hasMatch(value)
                            ? null
                            : AppStrings.invalidPassword;
                      },
                      suffixIcon: IconButton(
                        onPressed: () => passwordNotifier.value = !passwordObscure,
                        icon: Icon(
                          passwordObscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text('CONFIRM PASSWORD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                ValueListenableBuilder(
                  valueListenable: confirmPasswordNotifier,
                  builder: (_, confirmPasswordObscure, __) {
                    return AppTextFormField(
                      obscureText: confirmPasswordObscure,
                      controller: confirmPasswordController,
                      labelText: 'Confirm Password',
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) => _formKey.currentState?.validate(),
                      validator: (value) {
                        return value!.isEmpty
                            ? AppStrings.pleaseReEnterPassword
                            : AppConstants.passwordRegex.hasMatch(value)
                            ? passwordController.text == confirmPasswordController.text
                            ? null
                            : AppStrings.passwordNotMatched
                            : AppStrings.invalidPassword;
                      },
                      suffixIcon: IconButton(
                        onPressed: () => confirmPasswordNotifier.value = !confirmPasswordObscure,
                        icon: Icon(
                          confirmPasswordObscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                ValueListenableBuilder(
                  valueListenable: fieldValidNotifier,
                  builder: (_, isValid, __) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isValid
                            ? _registerUser // Call the registration method here
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('NEXT'),
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
