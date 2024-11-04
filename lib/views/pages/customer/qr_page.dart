// qr_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';
import 'package:senecard/view_models/customer/qr_page_viewmodel.dart';

class QrPage extends StatelessWidget {
  const QrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QrPageViewModel(
        userId: Provider.of<MainPageViewmodel>(context, listen: false).userId,
      ),
      child: const QrPageContent(),
    );
  }
}

class QrPageContent extends StatefulWidget {
  const QrPageContent({super.key});

  @override
  State<QrPageContent> createState() => _QrPageContentState();
}

class _QrPageContentState extends State<QrPageContent> {
  final GlobalKey _qrKey = GlobalKey();
  DateTime? _startRenderTime;

  @override
  void initState() {
    super.initState();
    _startRenderTime = DateTime.now();
  }

  void _measureRenderTime(BuildContext context) {
    if (_startRenderTime == null) return;
    
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final endRenderTime = DateTime.now();
      final renderTimeMs = endRenderTime.difference(_startRenderTime!).inMilliseconds;
      
      final viewModel = Provider.of<QrPageViewModel>(context, listen: false);
      viewModel.logQRRenderTime(renderTimeMs);
      
      _startRenderTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QrPageViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 255, 122, 40),
            ),
          );
        }

        if (viewModel.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  viewModel.errorMessage.contains('internet') 
                      ? Icons.wifi_off
                      : Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  viewModel.errorMessage,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: viewModel.refreshQR,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 122, 40),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text("Try Again"),
                ),
              ],
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _measureRenderTime(context);
        });

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
                key: _qrKey,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 122, 40),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: QrImageView(
                  data: viewModel.storedUserId!,
                  version: QrVersions.auto,
                  size: 350.0,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF000000),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF000000),
                  ),
                  backgroundColor: Colors.white,
                  gapless: true,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}