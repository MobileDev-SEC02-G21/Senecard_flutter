import 'package:flutter/material.dart';

class QrDeclinedResponse extends StatelessWidget {
  const QrDeclinedResponse({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Regresar a la página anterior
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Cuadro gris con el mensaje de transacción rechazada
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Container(
                padding: const EdgeInsets.all(15.0),
                width: double.infinity, // Hace que el ancho sea tan grande como la página
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'DECLINED TRANSACTION',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Campo estático: CUSTOMER NAME
            buildLabelAndField('CUSTOMER NAME', 'Javier Rivas'),
            const SizedBox(height: 20),
            // Campo estático: EMAIL
            buildLabelAndField('EMAIL', 'helloa@halallab.co'),
            const SizedBox(height: 20),
            // Campo estático: PURCHASE
            buildLabelAndField('PURCHASE', 'Burrito: 1 meat'),
            const SizedBox(height: 40),
            // Imagen del logo (coloca aquí el logo que prefieras)
            const Column(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 80,
                ),
                SizedBox(height: 10),
                Text(
                  'Senecard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Botón de "Return to Main Page"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: ElevatedButton(
                onPressed: () {
                  // Aquí puedes manejar la navegación
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50), // Ancho completo
                ),
                child: const Text(
                  'TRY AGAIN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Botón de "Try Again"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: ElevatedButton(
                onPressed: () {
                  // Aquí puedes manejar la acción de "Try Again"
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50), // Ancho completo
                ),
                child: const Text(
                  'RETURN TO MAIN PAGE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Espaciado debajo del botón
          ],
        ),
      ),
    );
  }

  // Helper para construir cada sección de campo de información
  Widget buildLabelAndField(String label, String value) {
    return Column(
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
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
