import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPage extends StatelessWidget {
  final String userId;
  const QrPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "This is your QR Code!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 122, 40),
                borderRadius: BorderRadius.circular(20),
              ),
              child: QrImageView(
                data: userId,
                version: QrVersions.auto,
                size: 350.0,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
    );
  }
}
