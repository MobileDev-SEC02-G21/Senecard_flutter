import 'package:flutter/material.dart';

class AdvertisementPage extends StatefulWidget {
  const AdvertisementPage({super.key});

  @override
  AdvertisementPageState createState() => AdvertisementPageState();
}

class AdvertisementPageState extends State<AdvertisementPage> {
  List<Map<String, String>> advertisements = [
    {
      'title': '20% OFF ALL BURRITOS',
      'image': 'assets/burrito.jpg',
    },
    {
      'title': '2X1 DRINKS',
      'image': 'assets/drinks.jpg',
    },
  ];

  // Función para agregar un nuevo anuncio
  void _addAdvertisement() {
    setState(() {
      advertisements.add({
        'title': 'New Advertisement', // Puedes personalizar este valor
        'image': 'assets/new_ad.jpg',  // Cambia a una imagen válida
      });
    });
  }

  // Función para eliminar un anuncio
  void _removeAdvertisement(int index) {
    setState(() {
      advertisements.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Regresar a la página anterior
          },
        ),
        title: const Text(
          'Advertisement',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _addAdvertisement, // Lógica para añadir un anuncio
            color: Colors.black,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'You Have These Advertisements Online:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Lista de anuncios
            Expanded(
              child: ListView.builder(
                itemCount: advertisements.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: AdvertisementCard(
                      title: advertisements[index]['title']!,
                      imagePath: advertisements[index]['image']!,
                      onDelete: () => _removeAdvertisement(index), // Eliminar anuncio
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdvertisementCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onDelete;

  const AdvertisementCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Imagen del anuncio
          Container(
            width: 120,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Texto del anuncio
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // Botón de eliminación
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
