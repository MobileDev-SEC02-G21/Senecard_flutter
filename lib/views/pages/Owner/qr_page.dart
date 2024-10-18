import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:senecard/view_models/owner/qr_viewmodel.dart'; // Importa el ViewModel
import 'qr_response_page.dart'; // Importa la página de respuesta del QR

class QrScanPage extends StatefulWidget {
  final String storeId; // Recibe el ID de la tienda

  const QrScanPage({super.key, required this.storeId});

  @override
  QrScanPageState createState() => QrScanPageState();
}

class QrScanPageState extends State<QrScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrCodeResult;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        qrCodeResult = scanData.code;  // Guarda el código escaneado (userId)
      });

      if (qrCodeResult != null) {
        // Obtén el ViewModel
        final qrViewModel = Provider.of<QrViewModel>(context, listen: false);
        try {
          // Llama a la función del ViewModel para obtener la información del QR, pasando el storeId y el userId (qrCodeResult)
          final qrInfo = await qrViewModel.getQrInfo(qrCodeResult!, widget.storeId);

          // Redirecciona automáticamente a QRResponsePage con los datos obtenidos
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QRResponsePage(
                customerName: qrInfo['name'],
                cardsRedeemed: qrInfo['points'],
                currentStamps: qrInfo['currentStamps'],
                maxStamps: qrInfo['maxPoints'],
                canRedeem: qrInfo['canRedeem'],
              ),
            ),
          );
        } catch (e) {
          print('Error obteniendo la información del QR: $e');
        }
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
                  color: Colors.white, // Texto blanco
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
