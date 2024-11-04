import 'package:flutter/material.dart';
import 'package:senecard/models/store.dart';

class StoreDetailViewModel extends ChangeNotifier {
  final Store store;
  bool _isStoreOpen = false;

  StoreDetailViewModel({required this.store}) {
    _checkStoreStatus();
  }

  bool get isStoreOpen => _isStoreOpen;

  void _checkStoreStatus() {
    final now = DateTime.now();
    String currentDay = _getCurrentDay(now.weekday);
    _isStoreOpen = _isOpen(now, currentDay);
    notifyListeners();
  }

  String _getCurrentDay(int weekday) {
    switch (weekday) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return 'monday';
    }
  }

  bool _isOpen(DateTime now, String currentDay) {
    if (!store.schedule.containsKey(currentDay)) return false;

    final List<dynamic> hours = store.schedule[currentDay];
    if (hours.length != 2) return false;

    final int openHour = hours[0];
    final int closeHour = hours[1];
    final int currentHour = now.hour;

    return currentHour >= openHour && currentHour < closeHour;
  }

  String formatSchedule(String day, List<dynamic> hours) {
    if (hours.length != 2) return '$day - Closed';
    return '$day - ${hours[0].toString().padLeft(2, '0')}:00 to ${hours[1].toString().padLeft(2, '0')}:00';
  }
}