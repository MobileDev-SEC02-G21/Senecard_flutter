import 'package:flutter/material.dart';
import 'package:senecard/views/pages/loginpages/Principallogin_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Find nearby stores',
      'description': 'Get all your loved foods in one place, you just place the order we do the rest',
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/senecard-aafad.appspot.com/o/stores_images%2FDise%C3%B1o%20sin%20t%C3%ADtulo.jpg?alt=media&token=4809b2b4-fb02-44b1-819f-39c3ad12549c', // URL de Firebase para la primera imagen
    },
    {
      'title': 'Get some special offers with our fidelity points!',
      'description': 'Get all your loved foods in one place, you just place the order we do the rest',
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/senecard-aafad.appspot.com/o/stores_images%2FDise%C3%B1o%20sin%20t%C3%ADtulo.jpg?alt=media&token=4809b2b4-fb02-44b1-819f-39c3ad12549c', // URL de Firebase para la segunda imagen
    },
    {
      'title': 'A Senecard just for you!',
      'description': 'A special QR for you to redeem your discounts!',
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/senecard-aafad.appspot.com/o/stores_images%2FDise%C3%B1o%20sin%20t%C3%ADtulo.jpg?alt=media&token=4809b2b4-fb02-44b1-819f-39c3ad12549c', // URL de Firebase para la tercera imagen
    },
  ];

  void _navigateToSigninSignupPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SigninSignupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        _pages[index]['imageUrl']!, // Carga la imagen desde la URL de Firebase
                        height: 180, // Ajusta la altura de la imagen
                        width: double.infinity, // Ajusta el ancho para ocupar todo el contenedor
                        fit: BoxFit.cover, // Ajusta el modo de encuadre de la imagen
                      ),
                      const SizedBox(height: 40),
                      Text(
                        _pages[index]['title']!,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _pages[index]['description']!,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
                  (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                height: 8,
                width: _currentPage == index ? 16 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.orange : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                    } else {
                      _navigateToSigninSignupPage();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Center(child: Text('NEXT')),
                ),
                TextButton(
                  onPressed: () {
                    _navigateToSigninSignupPage();
                  },
                  child: const Text('Skip'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
