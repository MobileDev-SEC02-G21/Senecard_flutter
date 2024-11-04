import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senecard/models/store.dart';
import 'package:senecard/view_models/customer/store_detail_viewmodel.dart';

class StoreDetailPage extends StatelessWidget {
  final Store store;

  const StoreDetailPage({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoreDetailViewModel(store: store),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 122, 40),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title
                  const Text(
                    'Store Detail',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Store Image
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(store.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Store Name
                  Text(
                    store.name,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.grey,
                    ),
                  ),
                  
                  // Category
                  Text(
                    store.category,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 255, 122, 40),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Rating Section
                  const Text(
                    'Rating',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    store.rating.toString(),
                    style: const TextStyle(
                      fontSize: 36,
                      color: Colors.grey,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Address Section
                  const Text(
                    'Address',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    store.address,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Schedule Section
                  const Text(
                    'Schedule',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<StoreDetailViewModel>(
                    builder: (context, viewModel, child) {
                      return Column(
                        children: [
                          _buildScheduleItem(viewModel, 'Monday', store.schedule['monday']),
                          _buildScheduleItem(viewModel, 'Tuesday', store.schedule['tuesday']),
                          _buildScheduleItem(viewModel, 'Wednesday', store.schedule['wednesday']),
                          _buildScheduleItem(viewModel, 'Thursday', store.schedule['thursday']),
                          _buildScheduleItem(viewModel, 'Friday', store.schedule['friday']),
                          _buildScheduleItem(viewModel, 'Saturday', store.schedule['saturday']),
                          _buildScheduleItem(viewModel, 'Sunday', store.schedule['sunday']),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleItem(StoreDetailViewModel viewModel, String day, List<dynamic>? hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        viewModel.formatSchedule(day, hours ?? []),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}