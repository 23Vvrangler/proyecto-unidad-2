// lib/ui/login_user.dart
import 'package:app_capachica/login/register_user.dart';
import 'package:app_capachica/modelo/UsuarioModelo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Componentes de UI
import 'package:app_capachica/components/text_form_field_widget.dart';
import 'package:app_capachica/components/button_widget.dart';
import 'package:app_capachica/components/app_bar_widget.dart';

// Vistas de la aplicación
import 'package:app_capachica/ui/main_screen.dart'; // Asegúrate que esta ruta es correcta (estaba en 'login/' antes)

// Importaciones de la API y modelos
import 'package:app_capachica/apis/usuario_api.dart'; // Importa tu cliente de API

class LoginUserScreen extends StatefulWidget {
  const LoginUserScreen({super.key});

  @override
  State<LoginUserScreen> createState() => _LoginUserScreenState();
}

class _LoginUserScreenState extends State<LoginUserScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Instancia de la API
  late final UsuarioApi _usuarioApi; // Usamos 'late final' para inicializarla en initState

  @override
  void initState() {
    super.initState();
    _usuarioApi = UsuarioApi.create(); // Crea la instancia de tu cliente API aquí
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _performLogin(BuildContext context) async { // Hacemos la función asíncrona
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final username = _usernameController.text;
      final password = _passwordController.text;

      // Crea el objeto de petición de login
      final loginRequest = LoginRequestModelo(
        userName: username,
        password: password,
      );

      try {
        // Llama a la API para intentar iniciar sesión
        final LoginResponseModelo response = await _usuarioApi.login(loginRequest);

        // Si la llamada es exitosa, se recibirá un LoginResponseModelo
        if (mounted) {
          Fluttertoast.showToast(
            msg: "Inicio de sesión exitoso: ${response.userName}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          // Redirección a la vista principal
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } catch (e) {
        // Manejo de errores de la API
        String errorMessage = "Error al iniciar sesión. Inténtalo de nuevo.";
        if (e is DioException) { // Usa DioException para manejar errores específicos de Dio
          if (e.response != null) {
            // Si hay una respuesta del backend, intenta extraer el mensaje de error
            // Asume que tu backend envía un JSON como {"message": "credenciales inválidas"}
            errorMessage = e.response!.data['message'] as String? ?? "Credenciales incorrectas.";
          } else {
            // Errores de red o conexión
            errorMessage = "Error de conexión: No se pudo conectar al servidor.";
          }
        }
        if (mounted) {
          Fluttertoast.showToast(
            msg: errorMessage,
            toastLength: Toast.LENGTH_LONG, // Muestra el mensaje por más tiempo
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: const AppBarWidget(title: 'Iniciar Sesión', showBackButton: false),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            shadowColor: Colors.blue[900]?.withOpacity(0.7),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_pin_circle,
                      size: 110,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Bienvenido de nuevo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormFieldWidget(
                      controller: _usernameController,
                      hintText: 'Nombre de Usuario',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa tu nombre de usuario';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormFieldWidget(
                      controller: _passwordController,
                      hintText: 'Contraseña',
                      icon: Icons.lock,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa tu contraseña';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    ButtonWidget(
                      text: 'Iniciar Sesión',
                      onPressed: () => _performLogin(context),
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 30),
                    TextButton(
                      onPressed: () {
                        // Asegúrate de que RegisterUserScreen esté en lib/ui/
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterUserScreen()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue[700],
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        '¿No tienes cuenta? Regístrate aquí',
                        style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Fluttertoast.showToast(msg: "Restablecer contraseña (Lógica Pendiente)");
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue[500],
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(fontSize: 15, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}