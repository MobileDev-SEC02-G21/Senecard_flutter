// lib/views/pages/customer/qr_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  late QrPageViewModel _viewModel;
  final GlobalKey _qrKey = GlobalKey();
  DateTime? _startRenderTime;

  @override
  void initState() {
    super.initState();
    _startRenderTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<MainPageViewmodel>(context, listen: false).userId;
      _viewModel = QrPageViewModel(userId: userId);
      setState(() {});
    });
  }

  void _measureRenderTime() {
    if (_startRenderTime == null) return;
    
    final endRenderTime = DateTime.now();
    final renderTimeMs = endRenderTime.difference(_startRenderTime!).inMilliseconds;
    _viewModel.logQRRenderTime(renderTimeMs);
    _startRenderTime = null;
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color.fromARGB(255, 255, 122, 40),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            errorMessage.contains('internet') 
                ? Icons.wifi_off
                : Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _startRenderTime = DateTime.now();
                _viewModel.refreshQR();
              });
            },
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

  Widget _buildQRCode(String qrData) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureRenderTime());

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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Si el viewModel no está inicializado, mostrar loading
    if (!mounted || !this._viewModel.isInitialized) {
      return _buildLoadingState();
    }

    // Si hay un error, mostrar el estado de error
    if (_viewModel.hasError) {
      return _buildErrorState(_viewModel.errorMessage);
    }

    // Si está cargando, mostrar loading
    if (_viewModel.isLoading) {
      return _buildLoadingState();
    }

    // Mostrar el código QR
    final qrData = _viewModel.storedUserId ?? _viewModel.userId;
    print('Generating QR code with data: $qrData'); // Debug log
    return _buildQRCode(qrData);
  }

  @override
  void dispose() {
    super.dispose();
  }
}