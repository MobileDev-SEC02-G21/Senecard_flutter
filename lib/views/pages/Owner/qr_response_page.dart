import 'package:flutter/material.dart';

class QRResponsePage extends StatelessWidget {
  final String customerName;  // Nombre del cliente
  final int cardsRedeemed;  // Tarjetas canjeadas
  final int currentStamps;  // Sellos actuales
  final int maxStamps;  // Máximo de sellos posibles
  final bool canRedeem;  // Indica si se puede canjear la tarjeta

  const QRResponsePage({
    Key? key,
    required this.customerName,
    required this.cardsRedeemed,
    required this.currentStamps,
    required this.maxStamps,
    required this.canRedeem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),  // Fondo gris claro
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () {
            Navigator.pop(context);  // Acción para regresar a la página anterior
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
                padding: const EdgeInsets.all(10.0),  // Padding de 10
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Customer: $customerName',
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
                padding: const EdgeInsets.all(10.0),  // Padding de 10
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LOYALTY CARDS REDEEMED',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$cardsRedeemed',
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
                      '$currentStamps/$maxStamps',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Botón para hacer un sello (habilitado y naranja si canRedeem es false)
              ElevatedButton(
                onPressed: currentStamps < maxStamps ? () {
                  // Acción para hacer un sello
                } : null,  // Habilitado si currentStamps < maxStamps
                style: ElevatedButton.styleFrom(
                  backgroundColor: canRedeem ? Colors.grey[300] : Colors.orange,  // Si canRedeem es false, color naranja
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
                currentStamps >= maxStamps ? 'IS AVAILABLE TO REDEEM A LOYALTY CARD' : 'NOT AVAILABLE TO REDEEM A LOYALTY CARD',
                style: TextStyle(
                  color: currentStamps >= maxStamps ? Colors.green : Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Botón para canjear tarjeta de lealtad (habilitado cuando currentStamps == maxStamps)
              ElevatedButton(
                onPressed: currentStamps >= maxStamps ? () {
                  // Acción para canjear la tarjeta de lealtad
                } : null,  // Habilitado cuando currentStamps == maxStamps
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentStamps >= maxStamps ? Colors.green : Colors.grey[300],  // Verde si puede canjear
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
