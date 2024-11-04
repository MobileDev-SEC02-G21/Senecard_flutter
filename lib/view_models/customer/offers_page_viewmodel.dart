import 'dart:async';
import 'package:flutter/material.dart';
import 'package:senecard/models/advertisement.dart';
import 'package:senecard/models/store.dart';
import 'package:senecard/views/elements/customer/verticalList/advertisementElement.dart';
import 'package:senecard/views/elements/customer/verticalList/storeElement.dart';

class OffersPageViewModel extends ChangeNotifier {
  final List<Store> stores;
  final List<Advertisement> advertisements;
  final Function refreshCallback;

  OffersPageViewModel({
    required this.stores,
    required this.advertisements,
    required this.refreshCallback,
  });

  List<StoreElement> getTopStores({int limit = 3}) {
    return stores
        .take(limit)
        .toList()
        .asMap()
        .entries
        .map((entry) => StoreElement(
              key: ValueKey('store_${entry.value.id}_${entry.key}_offer'),
              storeId: entry.value.id,
              storeName: entry.value.name,
              rating: entry.value.rating,
              schedule: entry.value.schedule,
              image: entry.value.image,
            ))
        .toList();
  }

  List<AdvertisementElement> getTopAdvertisements({int limit = 3}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Primero filtramos los anuncios disponibles y verificamos que sus tiendas existan
    final validAds = advertisements.where((ad) {
      final storeExists = stores.any((store) => store.id == ad.storeId);
      return ad.available && storeExists;
    }).toList();

    // Luego tomamos los primeros 'limit' anuncios
    final limitedAds = validAds.take(limit).toList();

    return limitedAds.asMap().entries.map((entry) {
      final ad = entry.value;
      final store = stores.firstWhere((store) => store.id == ad.storeId);
      
      return AdvertisementElement(
        key: ValueKey('advert_${ad.id}_${entry.key}_${timestamp}'),
        id: ad.id,
        image: ad.image,
        available: ad.available,
        endDate: ad.endDate,
        startDate: ad.startDate,
        storeId: ad.storeId,
        title: ad.title,
        storeSchedule: store.schedule,
      );
    }).toList();
  }

  List<Store> sortStoresByRating({bool descending = true}) {
    final sortedStores = List<Store>.from(stores);
    sortedStores.sort((a, b) => 
      descending ? b.rating.compareTo(a.rating) : a.rating.compareTo(b.rating)
    );
    return sortedStores;
  }
  
  Future<void> refreshData() async {
    await refreshCallback();
  }
}