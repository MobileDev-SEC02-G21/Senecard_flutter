import 'package:flutter/material.dart';
import 'package:senecard/elements/customer/topbar/sidemenu.dart';
import 'package:senecard/elements/customer/topbar/topbar.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TopBar(
        leading: SideMenuButton(),
      ),
      drawer: SideMenuDrawer(menuItems: menuItems,),
      drawerScrimColor: Theme.of(context).scaffoldBackgroundColor,
      body: const Center(
        child: Text('Hello world.'),
      ),
    );
  }
}

class SideMenuBotton {
}
