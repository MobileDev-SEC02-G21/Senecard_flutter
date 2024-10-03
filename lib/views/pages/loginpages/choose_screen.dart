
import 'package:flutter/material.dart';


import '../../elements/login/values/app_routes.dart';
import '../../elements/login/utils/helpers/navigation_helper.dart';

import 'package:senecard/views/pages/loginpages/login_screen.dart';
import 'package:senecard/views/pages/loginpages/register_screen.dart';
import 'package:senecard/views/pages/loginpages/registerowner_screen.dart';


void _navigateToLoginPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
}

void _navigateToRegisterPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => RegisterPage()),
  );
}

void _navigateToRegisterownerPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => RegisterownerPage()),
  );
}



class RegisterSelectionPage extends StatelessWidget {
  const RegisterSelectionPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent, size: 30),
                      onPressed: () {
                        _navigateToLoginPage(context);
                        // Agregue la lógica de retroceso aquí
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                "Please select if you are member of the \nuniandes community or a store owner",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  _navigateToRegisterPage(context);
                  // Navegar a la pantalla de registro de la comunidad uniandes
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "UNIANDES COMMUNITY",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _navigateToRegisterownerPage(context);
                  // Navegar a la pantalla de registro del propietario de la tienda
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "STORE OWNER",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already you have an account?",
                    style: TextStyle(color: Colors.black),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () {
                      _navigateToLoginPage(context);
                      // Navegar a la pantalla de inicio de sesión
                      NavigationHelper.pushReplacementNamed(AppRoutes.login);
                    },
                    child: const Text(
                      "Sign in",
                      style: TextStyle(color: Colors.orangeAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}