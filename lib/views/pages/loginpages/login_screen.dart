import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:senecard/services/FirebaseAuthService.dart';

import '../../elements/login/components/app_text_form_field.dart';
import '../../elements/login/utils/helpers/navigation_helper.dart';

import '../../elements/login/values/app_routes.dart';
import '../../elements/login/utils/helpers/snackbar_helper.dart';

import '../../elements/login/values/app_constants.dart';
import '../../elements/login/values/app_regex.dart';
import '../../elements/login/values/app_routes.dart';
import '../../elements/login/values/app_strings.dart';

import 'package:senecard/views/pages/loginpages/Principallogin_screen.dart';
import 'package:senecard/views/pages/loginpages/choose_screen.dart';
import 'package:senecard/views/pages/customer/main_page.dart';
import 'package:senecard/views/pages/loginpages/forgotpass.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

void _navigateToSigninSignupPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => SigninSignupPage()),
  );
}

void _navigateToRegisterSelectionPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => RegisterSelectionPage()),
  );
}

void _navigateToMainPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => MainPage()),
  );
}

void _navigateToForgotPassPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => ForgotPassPage()),
  );
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final ValueNotifier<bool> passwordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  void initializeControllers() {
    emailController = TextEditingController()..addListener(controllerListener);
    passwordController = TextEditingController()..addListener(controllerListener);
  }

  void disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
  }

  void controllerListener() {
    final email = emailController.text;
    final password = passwordController.text;
    if (email.isEmpty && password.isEmpty) return;
    if (AppRegex.emailRegex.hasMatch(email) ) {
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

  Future<void> _signInUser(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      // Verifica la conexión a internet
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Muestra el diálogo de error de conexión si no hay internet
        showErrorConectionDialog(context);
        return;
      }

      final email = emailController.text;
      final password = passwordController.text;

      // Mostrar el popup de carga
      showLoadingDialog(context);

      try {
        // Intentar iniciar sesión utilizando Firebase Auth
        final user = await _firebaseAuthService.signInWithEmailAndPassword(email, password, context);

        if (user != null) {
          SnackbarHelper.showSnackBar("Logged In Successfully");
          emailController.clear();
          passwordController.clear();
        }
        else{
          showErrorDialog(context);
        }

      } catch (e) {
        // Muestra el diálogo de error de inicio de sesión
        showErrorDialog(context);
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 20),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.orange, size: 30),
                  onPressed: () {
                    _navigateToSigninSignupPage(context);
                  },
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Sign In",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                "Please sign in to your existing account",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
            ],
          ),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "EMAIL",
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? "Please, Enter Email Address"
                          : AppRegex.emailRegex.hasMatch(value)
                          ? null
                          : "Invalid Email Address";
                    },
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder(
                    valueListenable: passwordNotifier,
                    builder: (_, passwordObscure, __) {
                      return TextFormField(
                        obscureText: passwordObscure,
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: "PASSWORD",
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () =>
                            passwordNotifier.value = !passwordObscure,
                            icon: Icon(
                              passwordObscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: (_) => _formKey.currentState?.validate(),
                        validator: (value) {
                          return value!.isEmpty
                              ? "Please, Enter Password"
                              : AppRegex.passwordRegex.hasMatch(value)
                              ? null
                              : "";
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        _navigateToForgotPassPage(context);
                      },
                      child: const Text(
                        "Did you forget your password?",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder(
                    valueListenable: fieldValidNotifier,
                    builder: (_, isValid, __) {
                      return ElevatedButton(
                        onPressed: isValid
                            ? () {
                          _signInUser(context); // Call the sign-in function
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "ENTER",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account?",
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: () {
                  _navigateToRegisterSelectionPage(context);
                },
                child: const Text(
                  "Sign up",
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}