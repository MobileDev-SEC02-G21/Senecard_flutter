import 'package:flutter/material.dart';
import 'package:senecard/views/elements/customer/searchbar/searchbar.dart';
import 'package:senecard/views/elements/customer/verticalList/advertisementElement.dart';
import 'package:senecard/views/elements/customer/verticalList/storeElement.dart';
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

  List<StoreElement> stores = [
    const StoreElement(storeName: "Prueba 1", rating: 5),
    const StoreElement(storeName: "Prueba 2", rating: 3),
    const StoreElement(storeName: "Prueba 3", rating: 2),
    const StoreElement(storeName: "Prueba 4", rating: 1),
    const StoreElement(storeName: "Prueba 5", rating: 4),
  ];

  List<AdvertisementElement> advertisementes = [
    const AdvertisementElement(image: "https://media.istockphoto.com/id/1270770086/photo/commercial-buildings-view-from-low-angle.jpg?s=612x612&w=0&k=20&c=auL9cSRdLJjujIhq7anW0wZi_j-1EzFpv6OhvSBMQQY="),
    const AdvertisementElement(image: "https://media.istockphoto.com/id/1270770086/photo/commercial-buildings-view-from-low-angle.jpg?s=612x612&w=0&k=20&c=auL9cSRdLJjujIhq7anW0wZi_j-1EzFpv6OhvSBMQQY="),
    const AdvertisementElement(image: "https://media.istockphoto.com/id/1270770086/photo/commercial-buildings-view-from-low-angle.jpg?s=612x612&w=0&k=20&c=auL9cSRdLJjujIhq7anW0wZi_j-1EzFpv6OhvSBMQQY="),
    const AdvertisementElement(image: "https://media.istockphoto.com/id/1270770086/photo/commercial-buildings-view-from-low-angle.jpg?s=612x612&w=0&k=20&c=auL9cSRdLJjujIhq7anW0wZi_j-1EzFpv6OhvSBMQQY="),
    const AdvertisementElement(image: "https://media.istockphoto.com/id/1270770086/photo/commercial-buildings-view-from-low-angle.jpg?s=612x612&w=0&k=20&c=auL9cSRdLJjujIhq7anW0wZi_j-1EzFpv6OhvSBMQQY="),   
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
            onPressed: () {},
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
            const SizedBox(
            height: 20,
          ),
            const SearchBarCustom(),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: OffersPage(
                stores: stores,
                advertisementes: advertisementes,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
