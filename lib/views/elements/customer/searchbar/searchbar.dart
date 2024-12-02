import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senecard/view_models/customer/search_viewmodel.dart';
import 'package:senecard/views/pages/customer/ads_detail_page.dart';
import 'package:senecard/views/pages/customer/store_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchBarCustom extends StatefulWidget {
  const SearchBarCustom({super.key});

  @override
  State<SearchBarCustom> createState() => _SearchBarCustomState();
}

class _SearchBarCustomState extends State<SearchBarCustom> {
  final SearchController _searchController = SearchController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleItemSelection(BuildContext context, SearchViewModel viewModel,
      dynamic item, SearchController controller) async {
    await viewModel.saveToHistory(controller.text);
    controller.clear();
    controller.closeView('');

    if (viewModel.isStore(item)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoreDetailPage(store: item),
        ),
      );
    } else {
      final store = viewModel.stores.firstWhere(
        (s) => s.id == item.storeId,
        orElse: () => throw Exception('Store not found'),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdvertisementDetailPage(
            advertisement: item,
            store: store,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: SearchAnchor(
            searchController: _searchController,
            viewElevation: 0,
            viewBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
            viewConstraints: const BoxConstraints(maxHeight: 400),
            builder: (BuildContext context, SearchController controller) {
              return SearchBar(
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : const Color.fromARGB(255, 240, 245, 250),
                ),
                elevation: const WidgetStatePropertyAll(0),
                controller: controller,
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16),
                ),
                onTap: () {
                  controller.openView();
                },
                onChanged: (_) {
                  controller.openView();
                },
                onSubmitted: (value) async {
                  if (value.trim().isNotEmpty) {
                    await viewModel.saveToHistory(value);
                    controller.clear();
                  }
                },
                leading: Icon(
                  Icons.search,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              );
            },
            suggestionsBuilder: (context, controller) async {
              await viewModel.searchOnly(controller.text);

              if (controller.text.isEmpty) {
                return [
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        children: viewModel.searchHistory
                            .map((query) => ListTile(
                                  leading: const Icon(Icons.history),
                                  title: Text(query),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () async {
                                      await viewModel.removeFromHistory(query);
                                      setState(
                                          () {}); // Actualiza solo este widget
                                    },
                                  ),
                                  onTap: () {
                                    controller.text = query;
                                    controller.selection =
                                        TextSelection.fromPosition(
                                            TextPosition(offset: query.length));
                                    viewModel.searchOnly(query);
                                  },
                                ))
                            .toList(),
                      );
                    },
                  )
                ];
              }

              return viewModel.searchResults.map((item) {
                final isStore = viewModel.isStore(item);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      viewModel.getItemImage(item),
                    ),
                  ),
                  title: Text(viewModel.getItemTitle(item)),
                  subtitle: Text(viewModel.getItemSubtitle(item)),
                  trailing: Icon(
                    isStore ? Icons.store : Icons.local_offer,
                    color: const Color.fromARGB(255, 255, 122, 40),
                  ),
                  onTap: () => _handleItemSelection(
                      context, viewModel, item, controller),
                );
              });
            },
          ),
        );
      },
    );
  }
}
