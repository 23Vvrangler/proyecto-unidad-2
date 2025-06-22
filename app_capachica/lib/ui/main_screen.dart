import 'package:flutter/material.dart';
import 'package:app_capachica/components/app_bar_widget.dart';
import 'package:app_capachica/drawer/main_drawer.dart';
import 'dart:async'; // Necesario para usar Timer

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Lista de rutas de tus imágenes
  final List<String> _imageList = [
    'assets/images/image-1.png',
    'assets/images/image-2.png',
    'assets/images/image-3.png',
  ];

  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Configura el temporizador para cambiar de imagen cada 30 segundos
    _timer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
      if (_pageController.hasClients) { // Asegura que el controlador esté adjunto a un PageView
        if (_currentPage < _imageList.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0; // Vuelve a la primera imagen al llegar al final
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800), // Duración de la transición
          curve: Curves.easeInOut, // Curva de animación
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancela el temporizador cuando el widget se destruye
    _pageController.dispose(); // Libera los recursos del PageController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Vista Principal',
        showBackButton: false,
      ),
      drawer: const MainDrawer(),
      backgroundColor: Colors.blue[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- SLIDER DE IMÁGENES GRANDE Y CREATIVO CON CARDS ---
              SizedBox(
                height: 250, // Altura fija para tu slider
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _imageList.length,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentPage = index; // Actualiza la página actual cuando el usuario desliza manualmente
                    });
                  },
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0), // Pequeño margen entre cards
                      elevation: 8.0, // Elevación para dar un efecto de profundidad
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0), // Bordes redondeados para la card
                      ),
                      clipBehavior: Clip.antiAlias, // Recorta el contenido si excede los límites de la card
                      child: Image.asset(
                        _imageList[index],
                        fit: BoxFit.cover, // Para que la imagen cubra toda la card
                      ),
                    );
                  },
                ),
              ),
              // ----------------------------------------------------
              const SizedBox(height: 30), // Espacio entre el slider y el texto de bienvenida
              const Text(
                '¡Bienvenido a la App Capachica!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Has iniciado sesión correctamente. Esta es tu vista principal.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 50),
              // --- Mensaje e ícono para indicar cómo abrir el menú ---
              Text(
                'Desliza desde la izquierda para abrir el menú',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.blue.shade600,
                ),
              ),
              Icon(
                Icons.swipe_right,
                size: 40,
                color: Colors.blue.shade600,
              ),
              // ----------------------------------------------------
            ],
          ),
        ),
      ),
    );
  }
}