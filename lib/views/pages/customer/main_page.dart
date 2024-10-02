import 'package:flutter/material.dart';
import 'package:senecard/views/elements/shared/sidemenu.dart';
import 'package:senecard/views/elements/shared/topbar.dart';
import 'package:senecard/views/pages/customer/offers_page.dart';


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
      appBar: TopBar(
        icon: const Icon(Icons.menu),
        title: "Hey User",
        message: "Good Time of the day!",
        trailing: [
          IconButton(
            onPressed:(){},
            icon: const Icon(Icons.qr_code),
            color: Colors.white,
            style: const ButtonStyle(
                backgroundColor:
                    WidgetStatePropertyAll(Color.fromARGB(255, 255, 122, 40))),
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
