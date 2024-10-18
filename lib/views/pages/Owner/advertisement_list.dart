import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senecard/view_models/owner/advertisement_viewmodel.dart';
import 'create_advertisement.dart';

class AdvertisementPage extends StatefulWidget {
  final String storeId;

  const AdvertisementPage({super.key, required this.storeId});

  @override
  AdvertisementPageState createState() => AdvertisementPageState();
}

class AdvertisementPageState extends State<AdvertisementPage> {

  void _removeAdvertisement(int index) {
    final advertisementViewModel = Provider.of<AdvertisementViewModel>(context, listen: false);
    advertisementViewModel.removeAdvertisement(index);
  }

  @override
  void initState() {
    super.initState();

    final advertisementViewModel = Provider.of<AdvertisementViewModel>(context, listen: false);
    advertisementViewModel.fetchAdvertisements(widget.storeId);
  }

  @override
  Widget build(BuildContext context) {
    final advertisementViewModel = Provider.of<AdvertisementViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Advertisement',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateAdvertisementPage(storeId: widget.storeId),
                ),
              );
            },
            color: Colors.black,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'You Have These Advertisements Online:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: advertisementViewModel.advertisements.length,
                itemBuilder: (context, index) {
                  final advertisement = advertisementViewModel.advertisements[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: AdvertisementCard(
                      title: advertisement.title,
                      imagePath: advertisement.image,
                      onDelete: () => _removeAdvertisement(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdvertisementCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onDelete;

  const AdvertisementCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [

          Container(
            width: 120,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
