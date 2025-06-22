// lib/ui/admin/reservacion/admin_reservacion_list_screen.dart

import 'package:app_capachica/modelo/ReservacionModelo.dart';
import 'package:flutter/material.dart';
import 'package:app_capachica/apis/reservacion_api.dart';
import 'package:app_capachica/ui/admin/reservacion/admin_reservacion_form_screen.dart'; // Para crear/editar
import 'package:intl/intl.dart'; // Para formatear la fecha

class AdminReservacionListScreen extends StatefulWidget {
  const AdminReservacionListScreen({super.key});

  @override
  State<AdminReservacionListScreen> createState() => _AdminReservacionListScreenState();
}

class _AdminReservacionListScreenState extends State<AdminReservacionListScreen> {
  late ReservacionApi _reservacionApi;
  List<ReservacionModelo> _reservaciones = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _reservacionApi = ReservacionApi.create();
    _fetchReservaciones();
  }

  /// Fetches all reservations from the API.
  /// Handles loading states and error messages.
  Future<void> _fetchReservaciones() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // As admin, we load ALL reservations
      final List<ReservacionModelo> fetchedReservaciones = await _reservacionApi.getAllReservaciones();
      setState(() {
        _reservaciones = fetchedReservaciones;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar las reservaciones: ${e.toString()}';
      });
      _showSnackBar('Error: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Deletes a reservation by its ID after user confirmation.
  /// Refreshes the list on success.
  Future<void> _deleteReservacion(int id) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar esta reservación?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _reservacionApi.deleteReservacion(id);
        _showSnackBar('Reservación eliminada con éxito.');
        _fetchReservaciones(); // Refresh the list
      } catch (e) {
        _showSnackBar('Error al eliminar la reservación: ${e.toString()}', isError: true);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Reservaciones'),
        centerTitle: true,
        backgroundColor: Colors.indigo, // Consistent AppBar color for reservations
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchReservaciones,
            tooltip: 'Recargar reservaciones',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner
          : _errorMessage != null // Show error message if any
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchReservaciones,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      )
          : _reservaciones.isEmpty // Show message if no reservations are found
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'No hay reservaciones registradas.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _reservaciones.length,
        itemBuilder: (context, index) {
          final reservacion = _reservaciones[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              leading: const CircleAvatar(
                  backgroundColor: Colors.indigoAccent, // Consistent color for leading icon
                  child: Icon(Icons.calendar_month, color: Colors.white)),
              title: Text(
                reservacion.nombreClient, // Client's name as title
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fecha: ${reservacion.fechaReserva}'),
                  Text('Hora: ${reservacion.horaReserva}'),
                  Text('Personas: ${reservacion.numeroPersonas}'),
                  Text('Teléfono: ${reservacion.telefono}'),
                  Text('ID: ${reservacion.id ?? 'N/A'}'), // Display ID for debugging/info
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange), // Edit icon
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminReservacionFormScreen(
                            reservacion: reservacion, // Pass reservation to edit
                          ),
                        ),
                      );
                      if (result == true) {
                        _fetchReservaciones(); // Refresh if edited
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red), // Delete icon
                    onPressed: () => _deleteReservacion(reservacion.id!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminReservacionFormScreen(), // Navigate to create new reservation form
            ),
          );
          if (result == true) {
            _fetchReservaciones(); // Refresh if a new one was created
          }
        },
        backgroundColor: Colors.indigo, // Consistent FAB color
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}