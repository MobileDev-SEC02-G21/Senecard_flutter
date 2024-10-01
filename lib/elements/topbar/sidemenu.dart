import 'package:flutter/material.dart';

class SideMenuButton extends StatelessWidget {
  const SideMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
      child: const Text(""),
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
      backgroundColor: const Color.fromARGB(255, 240, 245, 250),
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
                  icon: const Icon(Icons.arrow_back_ios_new_sharp,),
                ),
                const Center(
                  child: Text(
                    'Options',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...menuItems.map((item) => ListTile(
                title: Center(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(158, 158, 158, 0.5),
                            spreadRadius: 3,
                            blurRadius: 8,
                            offset: Offset(1, 3),
                          )
                        ]),
                    child: Text(item.title),
                  ),
                ),
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
