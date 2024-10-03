import 'package:flutter/material.dart';
import '../../elements/login/components/app_text_form_field.dart';

import '../../elements/login/utils/helpers/snackbar_helper.dart';

import '../../elements/login/values/app_constants.dart';
import '../../elements/login/values/app_regex.dart';
import '../../elements/login/values/app_routes.dart';
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
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty && email.isEmpty && password.isEmpty && confirmPassword.isEmpty) return;

    if (AppRegex.emailRegex.hasMatch(email) &&
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
                onPressed: (){
                  _navigateToRegisterSelectionPage(context);
                }
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Bussiness Owner',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            'Enter the information',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NAME', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
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
                        : value.length < 4
                        ? AppStrings.invalidName
                        : null;
                  },
                ),
                SizedBox(height: 20),
                Text('EMAIL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
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
                SizedBox(height: 20),
                Text('PHONE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
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
                        ? 'Please enter phone number'
                        : value.length < 10
                        ? 'Invalid phone number'
                        : null;
                  },
                ),
                SizedBox(height: 20),
                Text('PASSWORD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
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
                SizedBox(height: 20),
                Text('CONFIRM PASSWORD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
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
                SizedBox(height: 30),
                ValueListenableBuilder(
                  valueListenable: fieldValidNotifier,
                  builder: (_, isValid, __) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isValid
                            ? () {
                          _navigateToRegisterownerStorePage(context);
                          SnackbarHelper.showSnackBar(AppStrings.registrationComplete);
                          nameController.clear();
                          emailController.clear();
                          phoneController.clear();
                          passwordController.clear();
                          confirmPasswordController.clear();
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