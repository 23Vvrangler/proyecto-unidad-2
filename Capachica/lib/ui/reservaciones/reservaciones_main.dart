// lib/screens/reservacion_main.dart
import 'package:flutter/material.dart';
import 'package:app_capac/modelo/ReservacionModelo.dart'; // Importa tu modelo de Reservación
import 'package:app_capac/apis/reservacion_api.dart'; // Importa tu API de Reservación
// import 'package:app_capac/screens/reservacion_form_edit.dart'; // ¡Eliminado! No se usa más

class ReservacionMain extends StatefulWidget {
  @override
  _ReservacionMainState createState() => _ReservacionMainState();
}

class _ReservacionMainState extends State<ReservacionMain> {
  late ReservacionApi _reservacionApi;
  List<ReservacionModelo> _reservaciones = [];
  List<ReservacionModelo> _reservacionesFiltradas = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _reservacionApi = ReservacionApi.create(); // Inicializa tu API de Reservación
    _fetchReservaciones();
  }

  // Método para cargar las reservaciones desde la API
  Future<void> _fetchReservaciones() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null; // Limpia mensajes anteriores
    });

    try {
      final reservaciones = await _reservacionApi.getAllReservas();
      setState(() {
        _reservaciones = reservaciones;
        _reservacionesFiltradas = reservaciones;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar reservaciones: $e';
      });
      print('Error al cargar reservaciones: $e'); // Para depuración
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Método para filtrar la lista de reservaciones según la búsqueda
  void _filtrarReservaciones(String query) {
    setState(() {
      _reservacionesFiltradas = _reservaciones
          .where((reserva) =>
      reserva.nombreClient.toLowerCase().contains(query.toLowerCase()) ||
          reserva.telefono.toLowerCase().contains(query.toLowerCase()) ||
          reserva.fechaReserva.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Widget para mostrar mensajes de error/éxito
  Widget _buildMessage() {
    final colorScheme = Theme.of(context).colorScheme;
    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.error),
        ),
        child: Text(
          _errorMessage!,
          style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_successMessage != null) {
      return Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.tertiary),
        ),
        child: Text(
          _successMessage!,
          style: TextStyle(color: colorScheme.onTertiaryContainer, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Container();
  }

  // _navigateToCreateReserva eliminado

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Reservaciones'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
      )
          : Column(
        children: [
          _SearchBar(onChanged: _filtrarReservaciones),
          if (_successMessage != null || _errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildMessage(),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _ReservacionList(
                reservaciones: _reservacionesFiltradas,
                onReservacionUpdated: _fetchReservaciones, // Callback para refrescar la lista
              ),
            ),
          ),
        ],
      ),
      // FloatingActionButton eliminado
    );
  }
}

class _SearchBar extends StatelessWidget {
  final Function(String) onChanged;

  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Buscar por cliente, fecha o teléfono...',
          prefixIcon: Icon(Icons.search, color: colorScheme.primary),
          // El estilo de borde ya viene de AppTheme.inputDecorationTheme
        ),
      ),
    );
  }
}

class _ReservacionList extends StatelessWidget {
  final List<ReservacionModelo> reservaciones;
  final Function() onReservacionUpdated;

  const _ReservacionList({required this.reservaciones, required this.onReservacionUpdated});

  @override
  Widget build(BuildContext context) {
    if (reservaciones.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron reservaciones.',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: reservaciones.length,
      itemBuilder: (context, index) {
        final reservacion = reservaciones[index];
        return _ReservacionListItem(
          reservacion: reservacion,
          onReservacionUpdated: onReservacionUpdated,
        );
      },
    );
  }
}

class _ReservacionListItem extends StatelessWidget {
  final ReservacionModelo reservacion;
  final Function() onReservacionUpdated;

  const _ReservacionListItem({
    required this.reservacion,
    required this.onReservacionUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      // Card theming is handled by AppTheme
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.calendar_month, size: 40, color: colorScheme.primary), // Icono representativo
          title: Text(
            reservacion.nombreClient,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fecha: ${reservacion.fechaReserva}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant)),
              Text('Hora: ${reservacion.horaReserva}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant)),
              Text('Personas: ${reservacion.numeroPersonas}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant)),
              Text('Teléfono: ${reservacion.telefono}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant)),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón de Edición ELIMINADO
              // Container(
              //   decoration: BoxDecoration(
              //     color: colorScheme.primaryContainer,
              //     shape: BoxShape.circle,
              //   ),
              //   child: IconButton(
              //     icon: Icon(Icons.edit, color: colorScheme.onPrimaryContainer),
              //     onPressed: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => ReservacionFormEdit(
              //             reservacion: reservacion, // Pasa la reserva para edición
              //             onReservacionUpdated: onReservacionUpdated,
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),
              // SizedBox(width: 8), // Remueve este si el de edición es el único botón restante
              // Botón de Eliminar
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.delete, color: colorScheme.onErrorContainer),
                  onPressed: () async {
                    bool? confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirmar eliminación'),
                          content: Text('¿Estás seguro de que quieres eliminar la reserva de "${reservacion.nombreClient}"?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancelar'),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                            TextButton(
                              child: Text('Eliminar', style: TextStyle(color: colorScheme.error)),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmDelete == true && reservacion.id != null) {
                      try {
                        await ReservacionApi.create().deleteReserva(reservacion.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Reserva de "${reservacion.nombreClient}" eliminada con éxito.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        onReservacionUpdated(); // Refrescar la lista
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al eliminar reserva: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}