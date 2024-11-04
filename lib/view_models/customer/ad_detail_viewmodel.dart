import 'package:flutter/material.dart';
import 'package:senecard/models/advertisement.dart';
import 'package:senecard/models/store.dart';

class AdvertisementDetailViewModel extends ChangeNotifier {
  final Advertisement advertisement;
  final Store store;

  AdvertisementDetailViewModel({
    required this.advertisement,
    required this.store,
  });

  String formatDate(String dateString) {
    if (dateString.length != 8) return dateString;
    
    String year = dateString.substring(0, 4);
    String month = dateString.substring(4, 6);
    String day = dateString.substring(6, 8);
    
    return '$year-$month-$day';
  }

  String get formattedStartDate => formatDate(advertisement.startDate);
  String? get formattedEndDate => advertisement.endDate != null 
      ? formatDate(advertisement.endDate!) 
      : null;
}