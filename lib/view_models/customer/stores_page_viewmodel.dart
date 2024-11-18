import 'package:flutter/material.dart';
import 'package:senecard/models/store.dart';
import 'package:senecard/views/elements/customer/horizontalits.dart';
import 'package:senecard/views/elements/customer/verticalList/storeElement.dart';

class StoresPageViewmodel extends ChangeNotifier {
  final List<Store> stores;
  StoresPageViewmodel({required this.stores});
  String? _selectedCategory;

  String? get selectedCategory => _selectedCategory;

  void setSelectedCategory(String category) {
    _selectedCategory = category.isEmpty ? null : category;
    notifyListeners();
  }

  List<StoreElement> getStores() {
    var filteredStores = _selectedCategory != null
        ? stores.where((store) =>
            store.category.toLowerCase() == _selectedCategory!.toLowerCase())
        : stores;

    return filteredStores
        .toList()
        .asMap()
        .entries
        .map((entry) => StoreElement(
              key: ValueKey('store_${entry.value.id}_${entry.key}'),
              storeId: entry.value.id,
              storeName: entry.value.name,
              rating: entry.value.rating,
              schedule: entry.value.schedule,
              image: entry.value.image,
            ))
        .toList();
  }

  Widget getCategories() {
    var categories = stores.map((store) => store.category).toSet().toList();
    return HorizontalScrollableList(
      categories: categories,
      selectedCategory: _selectedCategory,
      onCategorySelected: setSelectedCategory,
    );
  }

  List<Store> filterStoresByCategory(String category) {
    return stores
        .where(
            (store) => store.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
}
