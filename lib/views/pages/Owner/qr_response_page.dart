import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:senecard/views/pages/Owner/owner_page.dart';
import '../../../view_models/owner/qr_viewmodel.dart';  // Importa OwnerPage

class QRResponsePage extends StatefulWidget {
  final String customerName; // Nombre del cliente
  final int cardsRedeemed; // Tarjetas canjeadas
  final int currentStamps; // Sellos actuales
  final int maxStamps; // Máximo de sellos posibles
  final bool canRedeem; // Indica si se puede canjear la tarjeta
  final String userId; // Id del usuario
  final String storeId; // Id de la tienda

  const QRResponsePage({
    Key? key,
    required this.customerName,
    required this.cardsRedeemed,
    required this.currentStamps,
    required this.maxStamps,
    required this.canRedeem,
    required this.userId,
    required this.storeId,
  }) : super(key: key);

  @override
  State<QRResponsePage> createState() => _QRResponsePageState();
}

class _QRResponsePageState extends State<QRResponsePage> {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    // Escuchar cambios en el estado de la conectividad
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        // Si no hay conexión, redirigir a la pantalla de OwnerPage
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
  void dispose() {
    // Cancelar la suscripción al estado de conectividad
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OwnerPage(storeId: widget.storeId),
              ),
            );
          },
        ),
        title: const Text(
          'QR page response',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              // Caja del nombre del cliente con padding
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Customer: ${widget.customerName}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Columna con tarjetas canjeadas y sellos actuales con padding
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LOYALTY CARDS REDEEMED',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${widget.cardsRedeemed}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'CURRENT STAMPS AWARDED',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${widget.currentStamps}/${widget.maxStamps}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Botón para hacer un sello
              ElevatedButton(
                onPressed: widget.currentStamps < widget.maxStamps
                    ? () async {
                  final qrViewModel = Provider.of<QrViewModel>(context, listen: false);
                  await qrViewModel.makeStamp(widget.userId, widget.storeId);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OwnerPage(storeId: widget.storeId),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.canRedeem ? Colors.grey[300] : Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'MAKE STAMP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Texto sobre la posibilidad de canjear la tarjeta
              Text(
                widget.currentStamps >= widget.maxStamps
                    ? 'IS AVAILABLE TO REDEEM A LOYALTY CARD'
                    : 'NOT AVAILABLE TO REDEEM A LOYALTY CARD',
                style: TextStyle(
                  color: widget.currentStamps >= widget.maxStamps ? Colors.green : Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Botón para canjear tarjeta de lealtad
              ElevatedButton(
                onPressed: widget.currentStamps >= widget.maxStamps
                    ? () async {
                  final qrViewModel = Provider.of<QrViewModel>(context, listen: false);
                  await qrViewModel.redeemLoyaltyCard(widget.userId, widget.storeId);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OwnerPage(storeId: widget.storeId),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.currentStamps >= widget.maxStamps ? Colors.green : Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'REDEEM LOYALTY CARD',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
