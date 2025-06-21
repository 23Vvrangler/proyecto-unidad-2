// main.dart
import 'package:app_capachica/login/login_user.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capachica APP',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Esto aplicará una paleta de azules por defecto
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Montserrat', // Puedes cambiar la fuente si lo deseas
      ),
      home: const LoginUserScreen(), // Inicia la aplicación con la pantalla de Login
    );
  }
}