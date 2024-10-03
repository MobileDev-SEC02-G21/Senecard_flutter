import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:senecard/view_models/customer/qr_page_viewmodel.dart';

class QrPage extends StatelessWidget {
  const QrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QrPageViewModel(),
      child: Consumer<QrPageViewModel>(
        builder: (context, viewModel, child) {
          viewModel.logQrRenderTime();
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
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 122, 40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: QrImageView(
                    data: viewModel.userId,
                    version: QrVersions.auto,
                    size: 350.0,
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
