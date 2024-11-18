import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';
import 'package:senecard/view_models/customer/stores_page_viewmodel.dart';
import 'package:senecard/views/elements/customer/verticalList/verticallist.dart';

class StorePage extends StatelessWidget {
  const StorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainPageViewmodel>(
      builder: (context, mainViewModel, child) {
        if (mainViewModel.isLoading && mainViewModel.stores.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ChangeNotifierProvider(
          create: (_) => StoresPageViewmodel(stores: mainViewModel.stores),
          child: Consumer<StoresPageViewmodel>(
            builder: (context, storesViewModel, _) {
              final storeElements = storesViewModel.getStores();
              final categories = storesViewModel.getCategories();

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Categories",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      categories,
                      const SizedBox(height: 10),
                      const Text(
                        "Stores",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      storeElements.isEmpty
                          ? const Center(child: Text('No stores available'))
                          : StoreList(
                              displayItems: storeElements,
                              shorter: false,
                            ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}