// lib/ui/reservacion/create_reservacion.dart

import 'package:app_capachica/modelo/ReservacionModelo.dart';
import 'package:flutter/material.dart';
import 'package:app_capachica/apis/reservacion_api.dart'; // Import your ReservacionApi
import 'package:intl/intl.dart'; // For date formatting, add to pubspec.yaml: intl: ^0.18.1

class CreateReservacionScreen extends StatefulWidget {
  const CreateReservacionScreen({super.key});

  @override
  State<CreateReservacionScreen> createState() => _CreateReservacionScreenState();
}

class _CreateReservacionScreenState extends State<CreateReservacionScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final TextEditingController _nombreClientController = TextEditingController();
  final TextEditingController _fechaReservaController = TextEditingController();
  final TextEditingController _horaReservaController = TextEditingController();
  final TextEditingController _numeroPersonasController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  late ReservacionApi _reservacionApi;
  bool _isCreating = false; // To show loading state during creation

  @override
  void initState() {
    super.initState();
    _reservacionApi = ReservacionApi.create(); // Initialize the API
  }

  @override
  void dispose() {
    _nombreClientController.dispose();
    _fechaReservaController.dispose();
    _horaReservaController.dispose();
    _numeroPersonasController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // Helper for showing SnackBar messages
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  // Function to pick a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      // Format the date as "DD/MM/YYYY" which your API expects
      setState(() {
        _fechaReservaController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Function to pick a time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      // Format the time as "HH:MM" (24-hour format)
      setState(() {
        _horaReservaController.text = picked.format(context); // Format uses system locale (e.g., 20:07)
      });
    }
  }

  // Function to handle reservation creation
  Future<void> _createReservation() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form is not valid
    }

    setState(() {
      _isCreating = true;
    });

    final newReservation = ReservacionModelo(
      nombreClient: _nombreClientController.text.trim(),
      fechaReserva: _fechaReservaController.text,
      horaReserva: _horaReservaController.text,
      numeroPersonas: _numeroPersonasController.text.trim(), // Ensure trim for consistent data
      telefono: _telefonoController.text.trim(),
    );

    try {
      final createdReservation = await _reservacionApi.createReservacion(newReservation);
      _showSnackBar('Reserva creada con éxito: ID ${createdReservation.id}');
      // Optionally, clear form fields after successful creation
      _nombreClientController.clear();
      _fechaReservaController.clear();
      _horaReservaController.clear();
      _numeroPersonasController.clear();
      _telefonoController.clear();
      // Optionally, navigate back or to a confirmation screen
      // Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error al crear la reserva: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hacer Nueva Reserva'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView( // Allow scrolling if content overflows
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Nombre del Cliente
              TextFormField(
                controller: _nombreClientController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Cliente',
                  hintText: 'Ej. Juan Pérez',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el nombre del cliente.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Fecha de la Reserva
              TextFormField(
                controller: _fechaReservaController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de la Reserva',
                  hintText: 'DD/MM/YYYY',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true, // Make it read-only so it can only be picked
                onTap: () => _selectDate(context), // Open date picker on tap
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona la fecha de la reserva.';
                  }
                  // Basic regex for DD/MM/YYYY format validation
                  if (!RegExp(r'^\d{2}\/\d{2}\/\d{4}$').hasMatch(value)) {
                    return 'Formato de fecha inválido (DD/MM/YYYY).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Hora de la Reserva
              TextFormField(
                controller: _horaReservaController,
                decoration: const InputDecoration(
                  labelText: 'Hora de la Reserva',
                  hintText: 'HH:MM',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                readOnly: true, // Make it read-only so it can only be picked
                onTap: () => _selectTime(context), // Open time picker on tap
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona la hora de la reserva.';
                  }
                  // Basic regex for HH:MM format validation (24-hour)
                  if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
                    return 'Formato de hora inválido (HH:MM).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Número de Personas
              TextFormField(
                controller: _numeroPersonasController,
                decoration: const InputDecoration(
                  labelText: 'Número de Personas',
                  hintText: 'Ej. 5',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number, // Only numeric input
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el número de personas.';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Debe ser un número válido mayor que 0.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Teléfono
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  hintText: 'Ej. 987654321',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone, // Phone number keyboard
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un número de teléfono.';
                  }
                  // Basic validation for 9-digit phone number
                  if (!RegExp(r'^\d{9}$').hasMatch(value)) {
                    return 'El teléfono debe ser de 9 dígitos.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botón de Crear Reserva
              _isCreating
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                onPressed: _createReservation,
                icon: const Icon(Icons.add_box),
                label: const Text('Crear Reserva', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}