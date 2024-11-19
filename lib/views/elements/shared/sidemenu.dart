import 'package:flutter/material.dart';
import 'package:senecard/views/pages/Owner/business_info.dart'; // Asegúrate de que la ruta sea correcta
import 'package:senecard/views/pages/Owner/advertisement_list.dart'; // Asegúrate de que la ruta sea correcta
import 'package:senecard/views/pages/loginpages/introLogin.dart'; // Importa la pantalla de inicio de sesión

class SideMenuDrawer extends StatelessWidget {
  final List<MenuItem> menuItems;
  final String storeId; // Se agrega el storeId para pasarlo a las páginas necesarias

  const SideMenuDrawer({super.key, required this.menuItems, this.storeId = ''}); // storeId se inicializa con un valor por defecto

  @override
  Widget build(BuildContext context) {
    void onTap(String title) {
      Navigator.pop(context); // Cerrar el drawer

      // Navegación según el título del menú
      if (title == 'Profile' && storeId.isNotEmpty) {
        // Navegar a BusinessInfoPage solo si storeId no está vacío
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusinessInfoPage(storeId: storeId), // Pasamos el storeId
          ),
        );
      } else if (title == 'My Ads' && storeId.isNotEmpty) {
        // Navegar a AdvertisementPage solo si storeId no está vacío
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdvertisementPage(storeId: storeId), // Pasamos el storeId
          ),
        );
      } else if (title == 'Log Out') {
        // Navegar a la pantalla de inicio de sesión (IntroScreen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => IntroScreen(),
          ),
        );
      }
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
                  onPressed: () {
                    Navigator.pop(context); // Cerrar el drawer
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_sharp,
                  ),
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
            onTap: () => onTap(item.title), // Pasamos el título al onTap
          )),
        ],
      ),
    );
  }
}

class MenuItem {
  final String title;
  MenuItem({required this.title});
}
