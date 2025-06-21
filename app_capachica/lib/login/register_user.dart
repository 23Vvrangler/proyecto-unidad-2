// lib/screens/login/register_user.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
// Importa tus nuevos componentes con los nombres actualizados
import 'package:app_capachica/components/text_form_field_widget.dart';
import 'package:app_capachica/components/button_widget.dart';
import 'package:app_capachica/components/app_bar_widget.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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

  void _performRegistration(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        print('Datos de registro:');
        print('Username: ${_usernameController.text}');
        print('Password: ${_passwordController.text}');
        print('Email: ${_emailController.text}');
        print('Fecha de Nacimiento: ${_dateOfBirthController.text}');

        Fluttertoast.showToast(
          msg: "Registro exitoso",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        Navigator.pop(context);
      });
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
                    // Usando TextFormFieldWidget
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
                    // Usando TextFormFieldWidget
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
                    // Usando TextFormFieldWidget
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
                    // Usando TextFormFieldWidget
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
                    // Usando TextFormFieldWidget
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
                    // Usando TextFormFieldWidget (para DatePicker)
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
                    // Usando TextFormFieldWidget
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
                    // Usando TextFormFieldWidget
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
                    // Usando ButtonWidget
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