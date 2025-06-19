// lib/screens/lugar_main.dart
import 'package:flutter/material.dart';
import 'package:app_capac/modelo/LugaresModelo.dart'; // Importa tu modelo de Lugar
import 'package:app_capac/apis/lugares_api.dart'; // Importa tu API de Lugares
// import 'package:app_capac/screens/lugar_form_edit.dart'; // ¡Eliminado! No se usa más

class LugarMain extends StatefulWidget {
  @override
  _LugarMainState createState() => _LugarMainState();
}

class _LugarMainState extends State<LugarMain> {
  late LugaresApi _lugaresApi;
  List<LugaresModelo> _lugares = [];
  List<LugaresModelo> _lugaresFiltrados = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _lugaresApi = LugaresApi.create(); // Inicializa tu API de Lugares
    _fetchLugares();
  }

  Future<void> _fetchLugares() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final lugares = await _lugaresApi.getAllLugares();
      setState(() {
        _lugares = lugares;
        _lugaresFiltrados = lugares;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar lugares: $e';
      });
      print('Error al cargar lugares: $e'); // Para depuración
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filtrarLugares(String query) {
    setState(() {
      _lugaresFiltrados = _lugares
          .where((lugar) =>
      lugar.nombre.toLowerCase().contains(query.toLowerCase()) ||
          lugar.descripcion!.toLowerCase().contains(query.toLowerCase()) ||
          lugar.direccion!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

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

  // _navigateToCreateLugar eliminado

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Lugares'),
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
          _SearchBar(onChanged: _filtrarLugares),
          if (_successMessage != null || _errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildMessage(),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _LugarList(
                lugares: _lugaresFiltrados,
                onLugarUpdated: _fetchLugares, // Callback para refrescar la lista
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
          hintText: 'Buscar lugar por nombre, descripción o dirección...',
          prefixIcon: Icon(Icons.search, color: colorScheme.primary),
          // El estilo de borde ya viene de AppTheme.inputDecorationTheme
        ),
      ),
    );
  }
}

class _LugarList extends StatelessWidget {
  final List<LugaresModelo> lugares;
  final Function() onLugarUpdated;

  const _LugarList({required this.lugares, required this.onLugarUpdated});

  @override
  Widget build(BuildContext context) {
    if (lugares.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron lugares.',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: lugares.length,
      itemBuilder: (context, index) {
        final lugar = lugares[index];
        return _LugarListItem(
          lugar: lugar,
          onLugarUpdated: onLugarUpdated,
        );
      },
    );
  }
}

class _LugarListItem extends StatelessWidget {
  final LugaresModelo lugar;
  final Function() onLugarUpdated;

  const _LugarListItem({required this.lugar, required this.onLugarUpdated});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      // Card theming is handled by AppTheme
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.place, size: 40, color: colorScheme.primary), // Icono representativo
          title: Text(
            lugar.nombre,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (lugar.categoria != null && lugar.categoria!.isNotEmpty)
                Text(
                  'Categoría: ${lugar.categoria}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: colorScheme.secondary),
                ),
              if (lugar.descripcion != null && lugar.descripcion!.isNotEmpty)
                Text(
                  'Descripción: ${lugar.descripcion}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              if (lugar.direccion != null && lugar.direccion!.isNotEmpty)
                Text(
                  'Dirección: ${lugar.direccion}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              if (lugar.numeroTelefono != null && lugar.numeroTelefono!.isNotEmpty)
                Text(
                  'Teléfono: ${lugar.numeroTelefono}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              if (lugar.calificacionPromedio != null)
                Text(
                  'Calificación: ${lugar.calificacionPromedio?.toStringAsFixed(1) ?? 'N/A'}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: colorScheme.tertiary),
                ),
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
              //           builder: (context) => LugarFormEdit(
              //             lugar: lugar, // Pasa el lugar para edición
              //             onLugarUpdated: onLugarUpdated,
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
                          content: Text('¿Estás seguro de que quieres eliminar "${lugar.nombre}"?'),
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

                    if (confirmDelete == true && lugar.id != null) {
                      try {
                        await LugaresApi.create().deleteLugar(lugar.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lugar "${lugar.nombre}" eliminado con éxito.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        onLugarUpdated(); // Refrescar la lista
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al eliminar lugar: $e'),
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