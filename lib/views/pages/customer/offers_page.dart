import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';
import 'package:senecard/view_models/customer/offers_page_viewmodel.dart';
import 'package:senecard/views/elements/customer/horizontaltextcustom.dart';
import 'package:senecard/views/elements/customer/verticalList/verticallist.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainPageViewmodel>(
      builder: (context, mainViewModel, child) {
        if (mainViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final offersViewModel = OffersPageViewModel(
          stores: mainViewModel.stores,
          advertisements: mainViewModel.advertisements,
          refreshCallback: mainViewModel.refreshData,
        );

        final storeElements = offersViewModel.getTopStores();
        final adElements = offersViewModel.getTopAdvertisements();

        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            child: Column(
              children: [
                HorizontalTextCustom(
                  title: "Stores",
                  buttonText: "See All",
                  icon: Icons.arrow_forward_ios_rounded,
                  onPressed: mainViewModel.switchStoresScreen,
                ),
                storeElements.isEmpty
                    ? Center(
                        child: Text(
                          'No stores available',
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      )
                    : StoreList(
                        key: ValueKey('stores_${storeElements.length}'),
                        displayItems: storeElements,
                        shorter: true,
                      ),
                const SizedBox(height: 10),
                HorizontalTextCustom(
                  title: "Advertisements",
                  buttonText: "See All",
                  icon: Icons.arrow_forward_ios_rounded,
                  onPressed: mainViewModel.switchAdvertisementScreen,
                ),
                adElements.isEmpty
                    ? Center(
                        child: Text(
                          'No advertisements available',
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      )
                    : StoreList(
                        key: ValueKey('ads_${adElements.length}'),
                        displayItems: adElements,
                        shorter: true,
                      ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
