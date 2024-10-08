import 'package:flutter/material.dart';
import 'loginpages/introLogin.dart';
import 'package:senecard/views/pages/Owner/advertisement_list.dart';
import 'package:senecard/views/pages/Owner/business_info.dart';
import 'package:senecard/views/pages/Owner/create_advertisement.dart';
import 'package:senecard/views/pages/Owner/edit_business.dart';
import 'package:senecard/views/pages/Owner/qr_declined_response.dart';
import 'package:senecard/views/pages/Owner/qr_page.dart';
import 'package:senecard/views/pages/Owner/qr_response_page.dart';
import 'package:senecard/views/pages/customer/main_page.dart';
import 'package:senecard/views/pages/Owner/owner_page.dart';


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
    Widget screenWidget = const IntroScreen();
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

