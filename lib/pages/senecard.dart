import 'package:flutter/material.dart';

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
    return MaterialApp(
      title: 'Senecard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Container(
        ),
      ),
    );
  }
}
