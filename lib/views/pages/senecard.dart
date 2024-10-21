import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'loginpages/introLogin.dart';

class Senecard extends StatefulWidget {
  const Senecard({super.key});
  @override
  State<Senecard> createState() {
    return _SenecartState();
  }
}

class _SenecartState extends State<Senecard> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Widget screenWidget = const IntroScreen();
    return MaterialApp(
      title: 'Senecard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Container(
          color: Colors.white,
          child: screenWidget,
        ),
      ),
    );
  }
}
