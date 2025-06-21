// lib/ui/main_screen.dart
import 'package:flutter/material.dart';
import 'package:app_capachica/components/app_bar_widget.dart';
import 'package:app_capachica/drawer/main_drawer.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

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
              Icon(
                Icons.check_circle_outline,
                size: 120,
                color: Colors.green[700],
              ),
              const SizedBox(height: 30),
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
                  // Corrected line 69: using .shade600
                  color: Colors.blue.shade600, // <--- CHANGED THIS LINE
                ),
              ),
              Icon(
                Icons.swipe_right,
                size: 40,
                // Corrected line: using .shade600
                color: Colors.blue.shade600, // <--- CHANGED THIS LINE (for consistency)
              ),
              // ----------------------------------------------------
            ],
          ),
        ),
      ),
    );
  }
}