import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';
import 'package:senecard/view_models/customer/qr_page_viewmodel.dart';

class QrPage extends StatefulWidget {
  const QrPage({super.key});

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  late final QrPageViewModel _viewModel;
  final GlobalKey _qrKey = GlobalKey();
  DateTime? _startRenderTime;

  @override
  void initState() {
    super.initState();
    _startRenderTime = DateTime.now();
    _initializeViewModel();
  }

  void _initializeViewModel() {
    final userId = Provider.of<MainPageViewmodel>(context, listen: false).userId;
    print('Initializing QrPage with userId: $userId');
    _viewModel = QrPageViewModel(userId: userId);
    setState(() {});
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color.fromARGB(255, 255, 122, 40),
          ),
          SizedBox(height: 16),
          Text('Generating QR Code...'),
        ],
      ),
    );
  }

  Widget _buildQRCode(String qrData) {
    if (_startRenderTime != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final endRenderTime = DateTime.now();
        final renderTimeMs = endRenderTime.difference(_startRenderTime!).inMilliseconds;
        _viewModel.logQRRenderTime(renderTimeMs);
        _startRenderTime = null;
      });
    }

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
              data: qrData,
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        if (!_viewModel.isInitialized || _viewModel.isLoading) {
          return _buildLoadingState();
        }

        if (_viewModel.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _viewModel.errorMessage,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _viewModel.refreshQR(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final qrData = _viewModel.storedUserId ?? _viewModel.userId;
        print('Rendering QR code with data: $qrData');
        return _buildQRCode(qrData);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}