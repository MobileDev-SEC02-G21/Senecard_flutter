import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:senecard/models/store.dart';
import 'package:senecard/services/loyalty_cards_service.dart';
import 'package:senecard/view_models/customer/loyalty_cards_viewmodel.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LoyaltyCardsPage extends StatelessWidget {
  const LoyaltyCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainPageViewmodel>(
      builder: (context, mainViewModel, child) {
        return FutureBuilder<LoyaltyCardsService>(
          future: LoyaltyCardsService.initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Error initializing loyalty cards service'),
              );
            }

            return ChangeNotifierProvider(
              create: (_) => LoyaltyCardsViewModel(
                userId: mainViewModel.userId,
                stores: mainViewModel.stores,
                loyaltyCardsService: snapshot.data!,
              ),
              child: const LoyaltyCardsContent(),
            );
          },
        );
      },
    );
  }
}

class LoyaltyCardsContent extends StatelessWidget {
  const LoyaltyCardsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoyaltyCardsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (viewModel.hasError && viewModel.loyaltyCards.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error loading loyalty cards',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: viewModel.refresh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 122, 40),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!viewModel.isOnline) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.orange.shade100,
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Offline mode - Showing cached loyalty cards',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
              if (viewModel.loyaltyCards.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No cached loyalty cards available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: LoyaltyCardsList(viewModel: viewModel),
                ),
            ],
          );
        }

        if (viewModel.loyaltyCards.isEmpty) {
          return const Center(
            child: Text(
              'No loyalty cards available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          );
        }

        return LoyaltyCardsList(viewModel: viewModel);
      },
    );
  }
}

class LoyaltyCardsList extends StatelessWidget {
  final LoyaltyCardsViewModel viewModel;

  const LoyaltyCardsList({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView.builder(
        itemCount: viewModel.loyaltyCards.length,
        itemBuilder: (context, index) {
          final card = viewModel.loyaltyCards[index];
          final store = viewModel.getStoreForCard(card);

          return LoyaltyCardItem(
            store: store,
            maxPoints: card['maxPoints'] as int,
            currentPoints: card['points'] as int,
          );
        },
      ),
    );
  }
}

class LoyaltyCardItem extends StatelessWidget {
  final Store store;
  final int maxPoints;
  final int currentPoints;

  const LoyaltyCardItem({
    super.key,
    required this.store,
    required this.maxPoints,
    required this.currentPoints,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoyaltyCardDetailPage(
              store: store,
              maxPoints: maxPoints,
              currentPoints: currentPoints,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl: store.image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.store, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$currentPoints / $maxPoints stamps',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class LoyaltyCardDetailPage extends StatelessWidget {
  final Store store;
  final int maxPoints;
  final int currentPoints;

  const LoyaltyCardDetailPage({
    super.key,
    required this.store,
    required this.maxPoints,
    required this.currentPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 122, 40),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              SizedBox(
                width: double.infinity,
                height: 200,
                child: CachedNetworkImage(
                  imageUrl: store.image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Location: ${store.address}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress: $currentPoints / $maxPoints',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${((currentPoints / maxPoints) * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 255, 122, 40),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: maxPoints,
                      itemBuilder: (context, index) {
                        final bool isStamped = index < currentPoints;
                        return SvgPicture.asset(
                          isStamped 
                              ? 'assets/images/stamp_filled.svg'
                              : 'assets/images/stamp_empty.svg',
                          width: 40,
                          height: 40,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}