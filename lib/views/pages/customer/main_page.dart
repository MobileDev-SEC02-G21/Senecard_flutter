import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';
import 'package:senecard/views/elements/customer/searchbar/searchbar.dart';
import 'package:senecard/views/elements/shared/sidemenu.dart';
import 'package:senecard/views/elements/shared/topbar.dart';
import 'package:senecard/views/pages/customer/offers_page.dart';
import 'package:senecard/views/pages/customer/qr_page.dart';

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
    return ChangeNotifierProvider(
      create: (_) => MainPageViewmodel(),
      child: Consumer<MainPageViewmodel>(
        builder: (context, viewModel, child) {
          Widget screen = const OffersPage();
          if (viewModel.screenWidget == 'qr-screen') {
            screen = const QrPage();
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: TopBar(
              icon: viewModel.icon,
              title: "Hey User",
              message: "Good Time of the day!",
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
                  if (viewModel.searchBarVisible) const SearchBarCustom(),
                  const SizedBox(height: 10),
                  Expanded(child: screen),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}