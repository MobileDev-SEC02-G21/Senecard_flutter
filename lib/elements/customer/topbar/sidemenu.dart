import 'package:flutter/material.dart';

class SideMenuButton extends StatelessWidget {
  const SideMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
      child: const Text(''),
    );
  }
}

class SideMenuDrawer extends StatelessWidget {
  final List<MenuItem> menuItems;
  const SideMenuDrawer({super.key, required this.menuItems});
  @override
  Widget build(BuildContext context) {
    void onTap() {
      Navigator.pop(context);
    }

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onTap,
                icon: const Icon(Icons.arrow_back_ios_new_sharp),
              ),
              const Text(
                'Options',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )),
          ...menuItems.map((item) => ListTile(
                title: Text(item.title),
                onTap: onTap,
              ))
        ],
      ),
    );
  }
}

class MenuItem {
  final String title;
  MenuItem({required this.title});
}
