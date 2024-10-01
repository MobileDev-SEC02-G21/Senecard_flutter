import 'package:flutter/material.dart';
import 'package:senecard/pages/customer/main_page.dart';

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
    Widget screenWidget = const MainPage();
    return MaterialApp(
      title: 'Senecard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: true,
      ),
      home: Scaffold(
        body:Container(
            color: Colors.white,
            child: screenWidget,
          ),
        ),
    );
  }
}
