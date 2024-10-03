import 'package:flutter/material.dart';

class QrPageViewModel extends ChangeNotifier {
  String _userId = "";

  String get userId => _userId;

  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }
}