// lib/login/login_user.dart

import 'package:app_capachica/apis/usuario_api.dart';
import 'package:app_capachica/login/register_user.dart';
import 'package:app_capachica/modelo/UsuarioModelo.dart';
import 'package:app_capachica/ui/main_screen.dart'; // Importa tu pantalla principal de usuario
import 'package:app_capachica/ui/admin/admin_main_screen.dart'; // ¡IMPORTAMOS LA PANTALLA PRINCIPAL DEL ADMIN!
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_capachica/components/text_form_field_widget.dart';

class LoginUserScreen extends StatefulWidget {
  const LoginUserScreen({super.key});

  @override
  State<LoginUserScreen> createState() => _LoginUserScreenState();
}

class _LoginUserScreenState extends State<LoginUserScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final UsuarioApi _usuarioApi = UsuarioApi.create(); // Instancia de tu API

  // Variable para controlar el estado de carga del botón de login
  bool _isLoading = false;

  Future<void> _performLogin() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showToast('Por favor, ingresa usuario y contraseña.');
      return;
    }

    setState(() {
      _isLoading = true; // Inicia el estado de carga
    });

    try {
      final LoginRequestModelo request = LoginRequestModelo(
        userName: username,
        password: password,
      );

      final LoginResponseModelo response = await _usuarioApi.login(request);

      if (response.token.isNotEmpty) { // Asumo que `response` nunca será null si el token no es vacío
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', response.id);
        await prefs.setString('token', response.token);
        await prefs.setString('userName', response.userName);
        await prefs.setString('userRole', response.role); // Guardamos el rol

        _showToast('Inicio de sesión exitoso!');

        // --- LÓGICA DE REDIRECCIÓN BASADA EN EL ROL ---
        if (response.role.toLowerCase() == 'admin') { // Asumiendo que el rol para admin es 'admin'
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminMainScreen()), // Redirige a la pantalla del admin
          );
        } else {
          // Asume que cualquier otro rol es un usuario normal
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()), // Redirige a la pantalla principal del usuario
          );
        }
        // --- FIN LÓGICA DE REDIRECCIÓN ---

      } else {
        _showToast('Credenciales incorrectas o respuesta inválida.');
      }
    } on DioException catch (e) {
      String errorMessage = 'Error de conexión. Inténtalo de nuevo.';
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        if (e.response?.statusCode == 401) {
          errorMessage = 'Usuario o contraseña incorrectos.';
        } else {
          errorMessage = 'Error del servidor: ${e.response?.statusCode}';
        }
      } else {
        print('Error sending request: $e');
        if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'La conexión ha tardado demasiado. Revisa tu red.';
        } else if (e.type == DioExceptionType.unknown) {
          errorMessage = 'No se pudo conectar al servidor. Verifica la URL y tu conexión a internet.';
        }
      }
      _showToast(errorMessage);
    } catch (e) {
      print('Unexpected error: $e');
      _showToast('Ocurrió un error inesperado.');
    } finally {
      setState(() {
        _isLoading = false; // Finaliza el estado de carga, independientemente del resultado
      });
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.1),
                  const Icon(
                    Icons.lock,
                    size: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bienvenido',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormFieldWidget(
                          controller: _usernameController,
                          hintText: 'Usuario',
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 20),
                        TextFormFieldWidget(
                          controller: _passwordController,
                          hintText: 'Contraseña',
                          icon: Icons.lock,
                          isPassword: true,
                        ),
                        const SizedBox(height: 30),
                        _isLoading
                            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent))
                            : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _performLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Iniciar Sesión',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            // REDIRIGE A LA PANTALLA DE REGISTRO
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterUserScreen()),
                            );
                          },
                          child: const Text(
                            '¿No tienes cuenta? Regístrate aquí',
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}