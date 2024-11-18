import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senecard/services/search_history_service.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';
import 'package:senecard/view_models/customer/search_viewmodel.dart';
import 'package:senecard/views/elements/customer/searchbar/searchbar.dart';

import 'package:senecard/views/elements/shared/topbar.dart';
import 'package:senecard/views/pages/customer/ads_page.dart';
import 'package:senecard/views/pages/customer/offers_page.dart';
import 'package:senecard/views/pages/customer/profile_page.dart';
import 'package:senecard/views/pages/customer/qr_page.dart';
import 'package:senecard/views/pages/customer/store_page.dart';
import 'package:senecard/views/pages/customer/loyalty_cards_page.dart';

import '../../elements/customer/topbar/sidemenu.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<MenuItem> menuItems = [
      MenuItem(title: 'Home'),
      MenuItem(title: 'Profile'),
      MenuItem(title: 'Loyalty Cards'),
      MenuItem(title: 'Settings'),
      MenuItem(title: 'Log Out'),
    ];
    String title = "Hey User";
    String message = "Good Time of the day!";

    return Consumer<MainPageViewmodel>(
      builder: (context, viewModel, child) {
        if (!viewModel.isAuthenticated) {
          // Si no hay autenticación, redirigir al login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.handleAuthenticationLost(context);
          });
          return const Center(child: CircularProgressIndicator());
        }

        print(
            'MainPage: Building with screenWidget: ${viewModel.screenWidget}');
        Widget screen = const OffersPage();
        if (viewModel.screenWidget == 'qr-screen') {
          screen = const QrPage();
          title = "My QR Code";
          message = "Show this to get rewards";
        }
        if (viewModel.screenWidget == 'stores-screen') {
          screen = const StorePage();
          title = "Store List";
          message = "Get to know all our affiliated stores";
        }
        if (viewModel.screenWidget == 'ads-screen') {
          screen = const AdsPage();
          title = "Advertisement List";
          message = "Check out all the advertisements";
        }
        if (viewModel.screenWidget == 'loyalty-cards-screen') {
          print('MainPage: Rendering LoyaltyCardsPage');
          screen = const LoyaltyCardsPage();
          title = "My Loyalty Cards";
          message = "Check your rewards progress";
        }
        if (viewModel.screenWidget == 'offers-screen') {
          title = "Hey User";
          message = "Good Time of the day!";
        }
        if (viewModel.screenWidget == 'profile-screen') {
          screen = const ProfilePage();
          title = "Profile";
          message = "View and edit your information";
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
                        Color.fromARGB(255, 255, 122, 40))),
              ),
            ],
            backHome: viewModel.startOver,
            buttonMenu: viewModel.buttonMenu,
          ),
          drawer: SideMenuDrawer(
            menuItems: menuItems,
          ),
          drawerScrimColor: const Color.fromARGB(255, 152, 168, 184),
          body: Center(
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
