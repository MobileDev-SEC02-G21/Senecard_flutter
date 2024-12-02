import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senecard/services/notifications_service.dart';
import 'package:senecard/services/search_history_service.dart';
import 'package:senecard/services/user_preferences_service.dart';
import 'package:senecard/utils/app_localizations.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';
import 'package:senecard/view_models/customer/search_viewmodel.dart';
import 'package:senecard/view_models/customer/settings_viewmodel.dart';
import 'package:senecard/views/elements/customer/searchbar/searchbar.dart';
import 'package:senecard/views/elements/customer/topbar/sidemenu.dart';
import 'package:senecard/views/elements/shared/topbar.dart';
import 'package:senecard/views/pages/customer/ads_page.dart';
import 'package:senecard/views/pages/customer/offers_page.dart';
import 'package:senecard/views/pages/customer/profile_page.dart';
import 'package:senecard/views/pages/customer/qr_page.dart';
import 'package:senecard/views/pages/customer/store_page.dart';
import 'package:senecard/views/pages/customer/loyalty_cards_page.dart';
import 'package:senecard/views/pages/customer/settings_page.dart';


class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    List<MenuItem> menuItems = [
      MenuItem(title: 'Home'),
      MenuItem(title: 'Profile'),
      MenuItem(title: 'Loyalty Cards'),
      MenuItem(title: 'Settings'),
      MenuItem(title: 'Log Out'),
    ];

    return Consumer<MainPageViewmodel>(
      builder: (context, viewModel, child) {
        if (!viewModel.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.handleAuthenticationLost(context);
          });
          return const Center(child: CircularProgressIndicator());
        }

        String title = "Hey User";
        String message = "Good Time of the day!";
        Widget screen = const OffersPage();

        switch (viewModel.screenWidget) {
          case 'qr-screen':
            screen = const QrPage();
            title = "My QR Code";
            message = "Show this to get rewards";
            break;
          case 'stores-screen':
            screen = const StorePage();
            title = "Store List";
            message = "Get to know all our affiliated stores";
            break;
          case 'ads-screen':
            screen = const AdsPage();
            title = "Advertisement List";
            message = "Check out all the advertisements";
            break;
          case 'loyalty-cards-screen':
            screen = const LoyaltyCardsPage();
            title = "My Loyalty Cards";
            message = "Check your rewards progress";
            break;
          case 'profile-screen':
            screen = const ProfilePage();
            title = "Profile";
            message = "View and edit your information";
            break;
          case 'settings-screen':
            screen = FutureBuilder<UserPreferencesService>(
              future: UserPreferencesService.initialize(),
              builder: (context, prefsSnapshot) {
                if (!prefsSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return FutureBuilder<NotificationsService>(
                  future: NotificationsService.initialize(prefsSnapshot.data!),
                  builder: (context, notifSnapshot) {
                    if (!notifSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ChangeNotifierProvider(
                      create: (_) => SettingsViewModel(
                        userRole:
                            'uniandesMember', // Obtener del servicio de autenticación
                        preferencesService: prefsSnapshot.data!,
                        notificationsService: notifSnapshot.data!,
                      ),
                      child: const SettingsPage(),
                    );
                  },
                );
              },
            );
            title = l10n.settings;
            message = "";
            break;
          default:
            title = "Hey User";
            message = "Good Time of the day!";
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: TopBar(
            icon: viewModel.icon,
            title: title,
            message: message,
            trailing: [
              IconButton(
                onPressed: viewModel.switchQRScreen,
                icon: const Icon(Icons.qr_code),
                color: Colors.white,
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Color.fromARGB(255, 255, 122, 40),
                  ),
                ),
              ),
            ],
            backHome: viewModel.startOver,
            buttonMenu: viewModel.buttonMenu,
          ),
          drawer: SideMenuDrawer(menuItems: menuItems),
          drawerScrimColor: const Color.fromARGB(255, 152, 168, 184),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                if (viewModel.searchBarVisible)
                  FutureBuilder<SearchHistoryService>(
                    future: SearchHistoryService.initialize(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ChangeNotifierProvider(
                          create: (_) => SearchViewModel(
                            stores: viewModel.stores,
                            ads: viewModel.advertisements,
                            searchHistoryService: snapshot.data!,
                          ),
                          child: const SearchBarCustom(),
                        );
                      }
                      return const SizedBox(height: 48);
                    },
                  ),
                const SizedBox(height: 10),
                Expanded(child: screen),
              ],
            ),
          ),
        );
      },
    );
  }
}
