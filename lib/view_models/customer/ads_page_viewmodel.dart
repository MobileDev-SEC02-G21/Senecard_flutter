import 'package:flutter/material.dart';
import 'package:senecard/models/advertisement.dart';
import 'package:senecard/models/store.dart';
import 'package:senecard/views/elements/customer/horizontalits.dart';
import 'package:senecard/views/elements/customer/verticalList/advertisementElement.dart';

class AdsPageViewmodel extends ChangeNotifier {
  final List<Store> stores;
  final List<Advertisement> ads;
  String? _selectedCategory;
  AdsPageViewmodel({required this.stores, required this.ads});

  List<AdvertisementElement> getAdvertisements() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    var filteredAds = List<Advertisement>.from(ads);

    // Aplicar filtro de categoría si existe
    if (_selectedCategory != null) {
      final storesInCategory = stores
          .where((store) => 
              store.category.toLowerCase() == _selectedCategory!.toLowerCase())
          .map((store) => store.id)
          .toSet();
      
      filteredAds = filteredAds
          .where((ad) => storesInCategory.contains(ad.storeId))
          .toList();
    }

    return filteredAds
        .asMap()
        .entries
        .map((entry) {
          final ad = entry.value;
          final store = stores.where((store) => store.id == ad.storeId).firstOrNull;

          if (store == null) {
            return null;
          }

          return AdvertisementElement(
            key: ValueKey('advert_${ad.id}_${entry.key}_${timestamp}'),
            image: ad.image,
            startDate: ad.startDate,
            storeId: ad.storeId,
            title: ad.title,
            available: ad.available,
            endDate: ad.endDate,
            storeSchedule: store.schedule,
          );
        })
        .where((element) => element != null)
        .cast<AdvertisementElement>()
        .toList();
  }

  Widget getCategories(List<Store> stores) {
    var categories = stores.map((store) => store.category).toSet().toList();
    return HorizontalScrollableList(categories: categories);
  }

  List<Store> filterAdsByCategory(String category) {
    return stores
        .where(
            (store) => store.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
}