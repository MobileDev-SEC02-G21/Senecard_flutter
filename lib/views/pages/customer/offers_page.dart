import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senecard/view_models/customer/offers_page_viewmodel.dart';
import 'package:senecard/views/elements/customer/horizontaltextcustom.dart';
import 'package:senecard/views/elements/customer/verticalList/verticallist.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OffersPageViewModel(),
      child: Consumer<OffersPageViewModel>(
        builder: (context, viewModel, child) {
          print('Building OffersPage. Store count: ${viewModel.stores.length}');
          print('Advertisement count: ${viewModel.advertisements.length}');
          
          return SingleChildScrollView(
            child: Column(
              children: [
                const HorizontalTextCustom(
                  title: "Stores",
                  buttonText: "See All",
                  icon: Icons.arrow_forward_ios_rounded,
                ),
                viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.stores.isEmpty
                        ? const Center(child: Text('No stores available'))
                        : StoreList(
                            key: ValueKey(viewModel.stores.length),
                            displayItems: viewModel.stores,
                            shorter: true,
                          ),
                const SizedBox(height: 10),
                const HorizontalTextCustom(
                  title: "Advertisements",
                  buttonText: "See All",
                  icon: Icons.arrow_forward_ios_rounded,
                ),
                viewModel.advertisements.isEmpty
                    ? const Center(child: Text('No advertisements available'))
                    : StoreList(
                        key: ValueKey(viewModel.advertisements.length),
                        displayItems: viewModel.advertisements,
                        shorter: true,
                      ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
