import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senecard/services/profile_storage_service.dart';
import 'package:senecard/services/qr_storage_service.dart';
import 'package:senecard/services/user_preferences_service.dart';
import 'package:senecard/utils/app_localizations.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';
import 'package:senecard/views/pages/loginpages/introLogin.dart';

class SideMenuDrawer extends StatelessWidget {
  final List<MenuItem> menuItems;
  const SideMenuDrawer({super.key, required this.menuItems});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final userId =
          Provider.of<MainPageViewmodel>(context, listen: false).userId;
      final qrStorageService = await QrStorageService.initialize();
      final profileStorageService = await ProfileStorageService.initialize();
      final userPreferencesService = await UserPreferencesService.initialize();

      await qrStorageService.clearStoredUserId();
      await profileStorageService.clearProfile(userId);

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const IntroScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error logging out. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    void onTap(String title) {
      print('SideMenu: onTap called with title: $title');
      Navigator.pop(context);

      switch (title) {
        case 'Home':
          Provider.of<MainPageViewmodel>(context, listen: false).startOver();
          break;
        case 'Loyalty Cards':
          Provider.of<MainPageViewmodel>(context, listen: false)
              .switchLoyaltyCardsScreen();
          break;
        case 'Profile':
          Provider.of<MainPageViewmodel>(context, listen: false)
              .switchProfileScreen();
          break;
        case 'Settings':
          Provider.of<MainPageViewmodel>(context, listen: false)
              .switchSettingsScreen();
          break;
        case 'Log Out':
          _handleLogout(context);
          break;
      }
    }

    final textColor = Theme.of(context).brightness == Brightness.dark 
        ? Colors.white 
        : Colors.black;

    final boxColor = Theme.of(context).brightness == Brightness.dark 
        ? const Color.fromARGB(255, 59, 59, 59) 
        : Colors.white;

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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_sharp),
                ),
                Center(
                  child: Text(
                    'Options',
                    style: TextStyle(
                      color: textColor,
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
                      color: boxColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(158, 158, 158, 0.5),
                          spreadRadius: 3,
                          blurRadius: 8,
                          offset: Offset(1, 3),
                        )
                      ],
                    ),
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