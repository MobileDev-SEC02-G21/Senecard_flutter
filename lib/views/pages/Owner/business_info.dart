import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senecard/view_models/owner/business_viewmodel.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'edit_business.dart';

class BusinessInfoPage extends StatefulWidget {
  final String storeId;

  const BusinessInfoPage({super.key, required this.storeId});

  @override
  _BusinessInfoPageState createState() => _BusinessInfoPageState();
}

class _BusinessInfoPageState extends State<BusinessInfoPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final businessInfoViewModel = Provider.of<BusinessInfoViewModel>(context, listen: false);
      businessInfoViewModel.fetchStoreData(widget.storeId);
    });
  }

  Future<void> _checkConnectivityAndNavigateToEdit() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(storeId: widget.storeId),
        ),
      );
    } else {
      _showNoConnectivityDialog();
    }
  }

  void _showNoConnectivityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("No Connectivity"),
          content: const Text("You need to be online to edit your profile."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final businessInfoViewModel = Provider.of<BusinessInfoViewModel>(context);

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
          'Business Info',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _checkConnectivityAndNavigateToEdit,
            child: const Text(
              'EDIT',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: businessInfoViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.orange[100],
                  child: const Icon(
                    Icons.store,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessInfoViewModel.storeName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      businessInfoViewModel.category,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    icon: Icons.person,
                    label: 'FULL NAME',
                    value: businessInfoViewModel.ownerName,
                  ),
                  const SizedBox(height: 15),
                  _buildInfoRow(
                    icon: Icons.email,
                    label: 'EMAIL',
                    value: businessInfoViewModel.ownerEmail,
                  ),
                  const SizedBox(height: 15),
                  _buildInfoRow(
                    icon: Icons.location_on,
                    label: 'ADDRESS',
                    value: businessInfoViewModel.storeAddress,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.black),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}