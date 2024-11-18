import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senecard/view_models/customer/ads_page_viewmodel.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';
import 'package:senecard/views/elements/customer/verticalList/verticallist.dart';

class AdsPage extends StatelessWidget {
  const AdsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainPageViewmodel>(
      builder: (context, mainViewModel, child) {
        if (mainViewModel.isLoading && mainViewModel.stores.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ChangeNotifierProvider(
          create: (_) => AdsPageViewmodel(
            stores: mainViewModel.stores,
            ads: mainViewModel.advertisements,
          ),
          child: Consumer<AdsPageViewmodel>(
            builder: (context, adsViewModel, _) {
              final adsElements = adsViewModel.getAdvertisements();
              final categories = adsViewModel.getCategories();

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text(
                        "Categories",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      categories,
                      const SizedBox(height: 10),
                      const Text(
                        "Advertisements",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      adsElements.isEmpty
                          ? const Center(child: Text('No ads available'))
                          : StoreList(
                              displayItems: adsElements,
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