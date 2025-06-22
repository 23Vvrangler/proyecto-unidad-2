// lib/screens/login/register_user.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:app_capachica/components/text_form_field_widget.dart';
import 'package:app_capachica/components/button_widget.dart';
import 'package:app_capachica/components/app_bar_widget.dart';
import 'package:app_capachica/apis/usuario_api.dart';         // <--- Importar UsuarioApi
import 'package:app_capachica/modelo/UsuarioModelo.dart';    // <--- Importar UsuarioCreacionModelo
import 'package:dio/dio.dart'; // <--- Importar Dio para manejar DioException

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Instancia de tu API
  final UsuarioApi _usuarioApi = UsuarioApi.create(); // <--- Instancia de UsuarioApi

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
              onSurface: Colors.blueGrey[700]!,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // --- FUNCIÓN DE REGISTRO MODIFICADA ---
  Future<void> _performRegistration(BuildContext context) async { // Marcado como async
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final String username = _usernameController.text;
        final String password = _passwordController.text;
        final String email = _emailController.text;
        final String firstName = _firstNameController.text;
        final String lastName = _lastNameController.text;
        final String dateOfBirth = _dateOfBirthController.text;
        final String phoneNumber = _phoneNumberController.text;
        final String address = _addressController.text;

        // Crear el objeto UsuarioCreacionModelo
        final UsuarioCreacionModelo newUser = UsuarioCreacionModelo(
          userName: username,
          password: password,
          email: email,
          firstName: firstName,
          lastName: lastName,
          // Asegúrate de que tu backend espera un String o un DateTime para dateOfBirth
          // Si espera DateTime, podrías enviar _selectedDate.
          dateOfBirth: dateOfBirth, // Enviando como String en formato YYYY-MM-DD
          phoneNumber: phoneNumber,
          address: address,
          role: 'USER', // Asigna un rol por defecto, si aplica
        );

        // Llamar a la API de registro
        final UsuarioCreacionModelo registeredUser = await _usuarioApi.registerUsuario(newUser);

        // Si la llamada fue exitosa
        Fluttertoast.showToast(
          msg: "Registro exitoso para ${registeredUser.userName}!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // Puedes navegar a la pantalla de login o a la principal si el registro loguea automáticamente
        Navigator.pop(context); // Regresa a la pantalla anterior (login)

      } on DioException catch (e) {
        String errorMessage = 'Error al registrar usuario. Inténtalo de nuevo.';
        print('Error de Dio: ${e.response?.data}');
        if (e.response != null) {
          if (e.response?.statusCode == 400) {
            // Ejemplo de manejo de errores específicos del backend
            if (e.response?.data['message'] != null) {
              errorMessage = e.response?.data['message'];
            } else {
              errorMessage = 'Datos inválidos. Por favor, revisa tus entradas.';
            }
          } else if (e.response?.statusCode == 409) { // Por ejemplo, si el usuario ya existe
            errorMessage = 'El usuario o email ya están registrados.';
          } else {
            errorMessage = 'Error del servidor: ${e.response?.statusCode}';
          }
        } else {
          errorMessage = 'No se pudo conectar al servidor. Verifica tu conexión a internet.';
        }
        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } catch (e) {
        print('Error inesperado durante el registro: $e');
        Fluttertoast.showToast(
          msg: "Ocurrió un error inesperado al registrar.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; // Asegura que el estado de carga se desactive
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: const AppBarWidget(title: 'Registrar Usuario'),
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
                      Icons.person_add,
                      size: 110,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Crea tu cuenta',
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
                          return 'Ingresa un nombre de usuario';
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
                        if (value == null || value.isEmpty || value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormFieldWidget(
                      controller: _emailController,
                      hintText: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Ingresa un email válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormFieldWidget(
                      controller: _firstNameController,
                      hintText: 'Nombres',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tus nombres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormFieldWidget(
                      controller: _lastNameController,
                      hintText: 'Apellidos',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tus apellidos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormFieldWidget(
                      controller: _dateOfBirthController,
                      hintText: 'Fecha de Nacimiento (YYYY-MM-DD)',
                      icon: Icons.calendar_today,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecciona tu fecha de nacimiento';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormFieldWidget(
                      controller: _phoneNumberController,
                      hintText: 'Número de Teléfono',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu número de teléfono';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormFieldWidget(
                      controller: _addressController,
                      hintText: 'Dirección',
                      icon: Icons.home,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu dirección';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    ButtonWidget(
                      text: 'Registrar',
                      onPressed: () => _performRegistration(context),
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue[700],
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        '¿Ya tienes cuenta? Inicia Sesión',
                        style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),
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