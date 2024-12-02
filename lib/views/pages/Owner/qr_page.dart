import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:senecard/view_models/owner/qr_viewmodel.dart';
import 'package:senecard/views/pages/Owner/owner_page.dart';
import 'qr_response_page.dart';

class QrScanPage extends StatefulWidget {
  final String storeId;

  const QrScanPage({super.key, required this.storeId});

  @override
  QrScanPageState createState() => QrScanPageState();
}

class QrScanPageState extends State<QrScanPage> with WidgetsBindingObserver {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrCodeResult;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OwnerPage(storeId: widget.storeId),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No internet connection. Returning to Owner Page.')),
        );
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller != null) {
      if (state == AppLifecycleState.paused) {
        controller!.pauseCamera();
      } else if (state == AppLifecycleState.resumed) {
        controller!.resumeCamera();
      }
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_isProcessing) return;
      _isProcessing = true;

      qrCodeResult = scanData.code;

      if (qrCodeResult != null) {
        final qrViewModel = Provider.of<QrViewModel>(context, listen: false);
        try {
          // Llama a la función del ViewModel para obtener la información del QR, pasando el storeId y el userId (qrCodeResult)
          final qrInfo = await qrViewModel.getQrInfo(qrCodeResult!, widget.storeId);

          if (!mounted) return;
          // Redirecciona automáticamente a QRResponsePage con los datos obtenidos, el userId y el storeId
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QRResponsePage(
                customerName: qrInfo['name'],
                cardsRedeemed: qrInfo['cardsRedeemed'],
                currentStamps: qrInfo['points'],
                maxStamps: qrInfo['maxPoints'],
                canRedeem: qrInfo['canRedeem'],
                userId: qrCodeResult!, // Pasamos el userId a la página de respuesta
                storeId: widget.storeId, // Pasamos el storeId a la página de respuesta
              ),
            ),
          );
        } catch (e) {
          print('Error obteniendo la información del QR: $e');
        } finally {
          _isProcessing = false;
        }
      } else {
        _isProcessing = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'PLEASE SCAN THE USER\'S QR CODE TO APPLY THE LOYALTY PROGRAM.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: SizedBox(
                height: 420,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.orange,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 250,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
