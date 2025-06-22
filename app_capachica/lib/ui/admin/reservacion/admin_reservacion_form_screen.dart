// lib/ui/admin/reservacion/admin_reservacion_form_screen.dart

import 'package:app_capachica/modelo/ReservacionModelo.dart';
import 'package:flutter/material.dart';
import 'package:app_capachica/apis/reservacion_api.dart';
import 'package:intl/intl.dart'; // Para formatear fechas/horas

class AdminReservacionFormScreen extends StatefulWidget {
  final ReservacionModelo? reservacion; // Null for creating, with value for editing

  const AdminReservacionFormScreen({super.key, this.reservacion});

  @override
  State<AdminReservacionFormScreen> createState() => _AdminReservacionFormScreenState();
}

class _AdminReservacionFormScreenState extends State<AdminReservacionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreClientController = TextEditingController();
  final TextEditingController _fechaReservaController = TextEditingController();
  final TextEditingController _horaReservaController = TextEditingController();
  final TextEditingController _numeroPersonasController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  late ReservacionApi _reservacionApi;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _reservacionApi = ReservacionApi.create();
    if (widget.reservacion != null) {
      // If editing, preload the data into controllers
      _nombreClientController.text = widget.reservacion!.nombreClient;
      _fechaReservaController.text = widget.reservacion!.fechaReserva;
      _horaReservaController.text = widget.reservacion!.horaReserva;
      _numeroPersonasController.text = widget.reservacion!.numeroPersonas;
      _telefonoController.text = widget.reservacion!.telefono;
    }
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

  /// Shows a SnackBar message to the user.
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return; // Avoid showing SnackBar if the widget is not mounted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  /// Opens a date picker and updates the date text field.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), // Wider range for admin
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.indigo, // Color of the header
            colorScheme: const ColorScheme.light(primary: Colors.indigo), // Color of selected date
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fechaReservaController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  /// Opens a time picker and updates the time text field.
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.indigo, // Color of the header
            colorScheme: const ColorScheme.light(primary: Colors.indigo), // Color of selected time
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Format the TimeOfDay to a string like "HH:MM"
        _horaReservaController.text = picked.format(context);
      });
    }
  }

  /// Validates the form and saves (creates or updates) the reservation.
  Future<void> _saveReservacion() async {
    if (!_formKey.currentState!.validate()) {
      // If the form is not valid, show a SnackBar and stop.
      _showSnackBar('Por favor, corrige los errores del formulario.', isError: true);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final nuevaReservacion = ReservacionModelo(
      id: widget.reservacion?.id, // Will be null for new, existing ID for update
      nombreClient: _nombreClientController.text.trim(),
      fechaReserva: _fechaReservaController.text,
      horaReserva: _horaReservaController.text,
      numeroPersonas: _numeroPersonasController.text.trim(),
      telefono: _telefonoController.text.trim(),
    );

    try {
      if (widget.reservacion == null) {
        // Create new reservation
        await _reservacionApi.createReservacion(nuevaReservacion);
        _showSnackBar('Reservación creada con éxito.');
      } else {
        // Update existing reservation
        await _reservacionApi.updateReservacion(nuevaReservacion.id!, nuevaReservacion);
        _showSnackBar('Reservación actualizada con éxito.');
      }
      if (mounted) {
        Navigator.pop(context, true); // Pop with 'true' to indicate a change occurred
      }
    } catch (e) {
      _showSnackBar('Error al guardar la reservación: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reservacion == null ? 'Crear Reservación' : 'Editar Reservación'),
        centerTitle: true,
        backgroundColor: Colors.indigo, // Consistent AppBar color
        foregroundColor: Colors.white, // Text and icon color for AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nombreClientController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Cliente',
                  hintText: 'Ej. Juan Pérez',
                  border: OutlineInputBorder(), // Established style
                  prefixIcon: Icon(Icons.person, color: Colors.indigo), // Icon color
                  focusedBorder: OutlineInputBorder( // Focused border style
                    borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el nombre del cliente.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fechaReservaController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de la Reserva',
                  hintText: 'DD/MM/YYYY',
                  border: OutlineInputBorder(), // Established style
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.indigo), // Icon color
                  focusedBorder: OutlineInputBorder( // Focused border style
                    borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  ),
                ),
                readOnly: true, // Make it read-only so date picker is used
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona la fecha de la reserva.';
                  }
                  // Basic regex for DD/MM/YYYY format
                  if (!RegExp(r'^\d{2}\/\d{2}\/\d{4}$').hasMatch(value)) {
                    return 'Formato de fecha inválido (DD/MM/YYYY).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _horaReservaController,
                decoration: const InputDecoration(
                  labelText: 'Hora de la Reserva',
                  hintText: 'HH:MM',
                  border: OutlineInputBorder(), // Established style
                  prefixIcon: Icon(Icons.access_time, color: Colors.indigo), // Icon color
                  focusedBorder: OutlineInputBorder( // Focused border style
                    borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  ),
                ),
                readOnly: true, // Make it read-only so time picker is used
                onTap: () => _selectTime(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona la hora de la reserva.';
                  }
                  // Basic regex for HH:MM format
                  if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
                    return 'Formato de hora inválido (HH:MM).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numeroPersonasController,
                decoration: const InputDecoration(
                  labelText: 'Número de Personas',
                  hintText: 'Ej. 5',
                  border: OutlineInputBorder(), // Established style
                  prefixIcon: Icon(Icons.people, color: Colors.indigo), // Icon color
                  focusedBorder: OutlineInputBorder( // Focused border style
                    borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.number, // Restrict to numbers
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el número de personas.';
                  }
                  // Validate if it's a positive integer
                  final int? parsedValue = int.tryParse(value);
                  if (parsedValue == null || parsedValue <= 0) {
                    return 'Debe ser un número válido mayor que 0.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  hintText: 'Ej. 987654321',
                  border: OutlineInputBorder(), // Established style
                  prefixIcon: Icon(Icons.phone, color: Colors.indigo), // Icon color
                  focusedBorder: OutlineInputBorder( // Focused border style
                    borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.phone, // Restrict to phone numbers
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un número de teléfono.';
                  }
                  // Basic regex for 9 digits
                  if (!RegExp(r'^\d{9}$').hasMatch(value)) {
                    return 'El teléfono debe ser de 9 dígitos.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _isSaving // Show CircularProgressIndicator while saving
                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo)))
                  : ElevatedButton.icon(
                onPressed: _saveReservacion,
                icon: Icon(widget.reservacion == null ? Icons.add : Icons.save),
                label: Text(widget.reservacion == null ? 'Crear Reservación' : 'Guardar Cambios',
                    style: const TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.indigo, // Consistent button color
                  foregroundColor: Colors.white, // Text color for button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
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