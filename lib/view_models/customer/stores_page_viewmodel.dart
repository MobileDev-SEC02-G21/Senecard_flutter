import 'package:flutter/material.dart';
import 'package:senecard/models/store.dart';
import 'package:senecard/views/elements/customer/horizontalits.dart';
import 'package:senecard/views/elements/customer/verticalList/storeElement.dart';

class StoresPageViewmodel extends ChangeNotifier {
  final List<Store> stores;
  String? _selectedCategory;
  List<Store> _filteredStores = [];
  bool _isRefreshing = false;

  StoresPageViewmodel({required this.stores}) {
    _initializeStores();
  }

  String? get selectedCategory => _selectedCategory;

  void _initializeStores() {
    _filteredStores = List.from(stores);
  }

  void setSelectedCategory(String category) {
    if (_isRefreshing) return;
    
    _isRefreshing = true;
    _selectedCategory = category.isEmpty ? null : category;
    _filteredStores = _selectedCategory != null
        ? stores.where((store) =>
            store.category.toLowerCase() == _selectedCategory!.toLowerCase())
        .toList()
        : List.from(stores);
    
    _isRefreshing = false;
    notifyListeners();
  }

  List<StoreElement> getStores() {
    return _filteredStores.map((store) => StoreElement(
      key: ValueKey('store_${store.id}'),
      storeId: store.id,
      storeName: store.name,
      rating: store.rating,
      schedule: store.schedule,
      image: store.image,
    )).toList();
  }

  Widget getCategories() {
    var categories = stores.map((store) => store.category).toSet().toList();
    return HorizontalScrollableList(
      categories: categories,
      selectedCategory: _selectedCategory,
      onCategorySelected: setSelectedCategory,
    );
  }
}