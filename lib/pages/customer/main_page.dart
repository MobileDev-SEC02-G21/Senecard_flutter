import 'package:flutter/material.dart';
import 'package:senecard/elements/topbar/sidemenu.dart';
import 'package:senecard/elements/topbar/topbar.dart';
import 'package:senecard/pages/customer/offers_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  List<MenuItem> menuItems = [
    MenuItem(title: 'Profile'),
    MenuItem(title: 'Loyalty Cards'),
    MenuItem(title: 'Settings'),
    MenuItem(title: 'Log Out'),
  ];
  List<String> categories = [
    "Restaurants",
    "Hardware Store",
    "Stationary",
    "Bakery"
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TopBar(
        leading: SideMenuButton(),
        trailing: [
          IconButton(
            onPressed: null,
            icon: Icon(Icons.qr_code),
          ),
        ],
      ),
      drawer: SideMenuDrawer(
        menuItems: menuItems,
      ),
      drawerScrimColor: const Color.fromARGB(255, 152, 168, 184),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            OffersPage(categories: categories),
          ],
        ),
      ),
    );
  }
}
