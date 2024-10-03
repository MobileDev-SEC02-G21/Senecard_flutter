import 'package:flutter/material.dart';


class MainPageViewmodel extends ChangeNotifier {
  final String _userId = "1Lp1RRd1uo11fgfIsFMU";
  String _screenWidget = 'offers-screen';
  bool _searchBarVisible = true;
  Icon _icon = const Icon(Icons.menu);
  bool _buttonMenu = true;

  String get userId => _userId;
  String get screenWidget => _screenWidget;
  bool get searchBarVisible => _searchBarVisible;
  Icon get icon => _icon;
  bool get buttonMenu => _buttonMenu;

  void startOver() {
    _screenWidget = 'offers-screen';
    _searchBarVisible = true;
    _icon = const Icon(Icons.menu);
    _buttonMenu = true;
    notifyListeners();
  }

  void switchQRScreen() {
    _screenWidget = 'qr-screen';
    _searchBarVisible = false;
    _icon = const Icon(Icons.arrow_back_ios_new);
    _buttonMenu = false;
    notifyListeners();
  }
}

