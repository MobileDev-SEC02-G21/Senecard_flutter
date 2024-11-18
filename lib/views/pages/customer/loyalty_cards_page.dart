import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:senecard/models/store.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LoyaltyCardsPage extends StatelessWidget {
  const LoyaltyCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainPageViewmodel>(
      builder: (context, viewModel, child) {
        print('Current userId: ${viewModel.userId}'); // Debug userId

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('loyaltyCards')
              .where('uniandesMemberId', isEqualTo: viewModel.userId)
              .where('isCurrent', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('Firestore error: ${snapshot.error}'); // Debug error
              return const Center(
                child: Text('Something went wrong'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final loyaltyCards = snapshot.data?.docs ?? [];
            
            // Debug loyalty cards data
            print('Found ${loyaltyCards.length} loyalty cards');
            for (var card in loyaltyCards) {
              print('Card data: ${card.data()}');
              print('Card ID: ${card.id}');
            }

            // También hagamos una consulta directa para verificar
            FirebaseFirestore.instance
                .collection('loyaltyCards')
                .get()
                .then((QuerySnapshot querySnapshot) {
                  print('Total documents in collection: ${querySnapshot.size}');
                  querySnapshot.docs.forEach((doc) {
                    print('Document ID: ${doc.id}');
                    print('Document data: ${doc.data()}');
                  });
                });

            if (loyaltyCards.isEmpty) {
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

            // Resto del código igual...
            return ListView.builder(
              itemCount: loyaltyCards.length,
              itemBuilder: (context, index) {
                final card = loyaltyCards[index];
                final storeId = card['storeId'] as String;
                final store = viewModel.stores.firstWhere(
                  (s) => s.id == storeId,
                  orElse: () => Store(
                    id: '',
                    name: 'Unknown Store',
                    address: '',
                    category: '',
                    rating: 0,
                    image: '',
                    businessOwnerId: '',
                    schedule: {},
                  ),
                );

                return LoyaltyCardItem(
                  store: store,
                  maxPoints: card['maxPoints'] as int,
                  currentPoints: card['points'] as int,
                );
              },
            );
          },
        );
      },
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
                image: DecorationImage(
                  image: NetworkImage(store.image),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(width: 16),
            Column(
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
              // Back Button
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
              
              // Store Image
              SizedBox(
                width: double.infinity,
                height: 200,
                child: CachedNetworkImage(
                  imageUrl: store.image,
                  fit: BoxFit.cover,
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
                    
                    Text(
                      'Stamps to get a prize: $maxPoints',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Stamps Grid
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