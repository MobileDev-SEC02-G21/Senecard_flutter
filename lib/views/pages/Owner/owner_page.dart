import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa Provider
import 'package:senecard/view_models/owner_page_vm.dart'; // Importa el ViewModel
import 'package:senecard/views/elements/shared/sidemenu.dart';
import 'package:senecard/views/elements/shared/topbar.dart';

class OwnerPage extends StatefulWidget {
  const OwnerPage({super.key});

  @override
  State<OwnerPage> createState() {
    return _OwnerPageState();
  }
}

class _OwnerPageState extends State<OwnerPage> {
  List<MenuItem> menuItems = [
    MenuItem(title: 'Profile'),
    MenuItem(title: 'My Ads'),
    MenuItem(title: 'Settings'),
    MenuItem(title: 'Log Out'),
  ];

  @override
  void initState() {
    super.initState();
    // Llama a `fetchCustomersScannedToday` en el ViewModel con el `storeId` adecuado.
    final String storeId = 'yourStoreId';  // Reemplaza `yourStoreId` con el ID de la tienda correspondiente
    Provider.of<OwnerPageViewModel>(context, listen: false).fetchCustomersScannedToday(storeId);
  }

  @override
  Widget build(BuildContext context) {
    final ownerPageViewModel = Provider.of<OwnerPageViewModel>(context); // Accede al ViewModel

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TopBar(
        backHome: (){},
        icon: const Icon(Icons.menu),
        title: "Welcome Back",
        message: "Let's Check Your Progress",
        trailing: [
          IconButton(
            onPressed: () {
              // Acción para el botón QR
            },
            icon: const Icon(Icons.qr_code),
            color: Colors.white,
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 255, 122, 40)),
            ),
          ),
        ],
      ),
      drawer: SideMenuDrawer(
        menuItems: menuItems,
      ),
      drawerScrimColor: const Color.fromARGB(255, 152, 168, 184),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50), // Aumenta considerablemente el espaciado
            const Text(
              'Welcome Back To Senecard!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40), // Aumenta el espaciado entre elementos
            const Text(
              'You’ve had',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // Semicírculo con fondo blanco
            Stack(
              alignment: Alignment.center,
              children: [
                // Fondo blanco inferior
                Positioned(
                  top: 100, // Colocado debajo del semicírculo
                  child: Container(
                    width: 200,
                    height: 100, // Altura del fondo blanco
                    color: Colors.white,
                  ),
                ),
                // Semicírculo negro
                Container(
                  width: 200,
                  height: 100, // Altura del semicírculo
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(100), // Semicírculo
                    ),
                  ),
                ),
                // Mostrar el número de clientes escaneados desde el ViewModel
                Positioned(
                  top: 25,
                  child: Column(
                    children: [
                      Text(
                        '${ownerPageViewModel.customersScannedToday}',  // Mostrar el número de clientes escaneados
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Texto debajo del semicírculo pero arriba del fondo blanco
            const Text(
              'Customers scanned today\nKeep up the good work!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 60), // Espaciado considerable
            const Text(
              'Current Business average Rating',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30), // Espaciado considerable
            // Sección de estrellas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  index < 4 ? Icons.star : Icons.star_half,
                  color: Colors.orange,
                  size: 32,
                );
              }),
            ),
            const SizedBox(height: 60), // Aumenta el espacio entre las estrellas y el botón
            // Botón naranja
            ElevatedButton(
              onPressed: () {
                // Acción cuando se presiona el botón
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Color de fondo del botón
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'YOU HAVE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '3 ADVERTISEMENTS ACTIVE',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
