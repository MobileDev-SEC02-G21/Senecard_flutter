import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senecard/services/qr_storage_service.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';
import 'package:senecard/views/pages/loginpages/introLogin.dart';

class SideMenuDrawer extends StatelessWidget {
  final List<MenuItem> menuItems;
  const SideMenuDrawer({super.key, required this.menuItems});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final qrStorageService = await QrStorageService.initialize();
      await qrStorageService.clearStoredUserId();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const IntroScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error logging out. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void onTap(String title) {
      print('SideMenu: onTap called with title: $title');
      Navigator.pop(context);

      switch (title) {
        case 'Home':
          print('SideMenu: Switching to home screen');
          Provider.of<MainPageViewmodel>(context, listen: false).startOver();
          break;
        case 'Loyalty Cards':
          print('SideMenu: Switching to loyalty cards screen');
          Provider.of<MainPageViewmodel>(context, listen: false)
              .switchLoyaltyCardsScreen();
          break;
        case 'Profile':
          Provider.of<MainPageViewmodel>(context, listen: false)
              .switchProfileScreen();
          break;
        case 'Log Out':
          _handleLogout(context);
          break;
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
                    Navigator.pop(context);
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
                onTap: () => onTap(item.title),
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
