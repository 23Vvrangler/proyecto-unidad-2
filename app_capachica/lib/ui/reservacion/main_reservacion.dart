// lib/ui/reservacion/main_reservacion.dart

import 'package:app_capachica/modelo/ReservacionModelo.dart';
import 'package:flutter/material.dart';
import 'package:app_capachica/apis/reservacion_api.dart'; // Importamos la API de Reservación
import 'package:shared_preferences/shared_preferences.dart'; // Para obtener datos del usuario logueado
import 'package:app_capachica/ui/reservacion/create_reservacion.dart'; // ¡Importamos la pantalla de creación!

class MainReservacionScreen extends StatefulWidget {
  const MainReservacionScreen({super.key});

  @override
  State<MainReservacionScreen> createState() => _MainReservacionScreenState();
}

class _MainReservacionScreenState extends State<MainReservacionScreen> {
  late ReservacionApi _reservacionApi;
  List<ReservacionModelo> _reservacionesFiltradas = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _loggedInUserName;

  @override
  void initState() {
    super.initState();
    _reservacionApi = ReservacionApi.create();
    _loadUserDataAndFetchReservations(); // Carga inicial
  }

  Future<void> _loadUserDataAndFetchReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _loggedInUserName = prefs.getString('userName');

      if (_loggedInUserName == null) {
        setState(() {
          _errorMessage = 'No hay usuario logueado. Inicia sesión para ver tus reservaciones.';
          _isLoading = false;
        });
        _showSnackBar('Por favor, inicia sesión.', isError: true);
        return;
      }

      final List<ReservacionModelo> allReservations = await _reservacionApi.getAllReservaciones();

      setState(() {
        _reservacionesFiltradas = allReservations.where((reservacion) {
          return reservacion.nombreClient.trim().toLowerCase() == _loggedInUserName!.trim().toLowerCase();
        }).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar tus reservaciones: ${e.toString()}';
      });
      _showSnackBar('Error: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
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
        title: const Text('Mis Reservaciones'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
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
                onPressed: _loadUserDataAndFetchReservations,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      )
          : _reservacionesFiltradas.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              _loggedInUserName != null
                  ? 'Aún no tienes reservaciones registradas a nombre de "${_loggedInUserName!}".'
                  : 'No se encontraron reservaciones para este usuario.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                // Navega a la pantalla de creación y espera el resultado
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateReservacionScreen()),
                );
                // Si la reserva se creó (o si regresó de alguna manera), refresca la lista
                if (result == true) { // Asumimos que `true` significa que se creó una reserva
                  _loadUserDataAndFetchReservations();
                }
              },
              icon: Icon(Icons.add_circle_outline),
              label: Text('Hacer una nueva reserva'),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _reservacionesFiltradas.length,
        itemBuilder: (context, index) {
          final reservacion = _reservacionesFiltradas[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: const CircleAvatar(
                  backgroundColor: Colors.indigoAccent,
                  child: Icon(Icons.calendar_month, color: Colors.white)
              ),
              title: Text(
                'Reservación de ${reservacion.nombreClient}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('📅 Fecha: ${reservacion.fechaReserva}'),
                  Text('⏰ Hora: ${reservacion.horaReserva}'),
                  Text('👥 Personas: ${reservacion.numeroPersonas.trim()}'),
                  Text('📞 Teléfono: ${reservacion.telefono}'),
                  if (reservacion.id != null)
                    Text('ID de Reserva: ${reservacion.id}'),
                ],
              ),
              onTap: () {
                _showSnackBar('Detalles de la reserva de ${reservacion.nombreClient}');
              },
            ),
          );
        },
      ),
      // FloatingActionButton para añadir una nueva reserva si ya hay reservas
      floatingActionButton: _reservacionesFiltradas.isNotEmpty || _isLoading == false && _errorMessage == null
          ? FloatingActionButton(
        onPressed: () async {
          // Navega a la pantalla de creación y espera el resultado
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateReservacionScreen()),
          );
          // Si la reserva se creó (o si regresó de alguna manera), refresca la lista
          if (result == true) { // Asumimos que `true` significa que se creó una reserva
            _loadUserDataAndFetchReservations();
          }
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null, // No muestra el FAB si hay error o aún cargando
    );
  }
}