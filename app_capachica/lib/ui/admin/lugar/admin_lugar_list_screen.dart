import 'package:app_capachica/modelo/LugarModelo.dart';
import 'package:flutter/material.dart';
import 'package:app_capachica/apis/lugar_api.dart';
import 'package:app_capachica/ui/admin/lugar/admin_lugar_form_screen.dart'; // Para crear/editar

class AdminLugarListScreen extends StatefulWidget {
  const AdminLugarListScreen({super.key});

  @override
  State<AdminLugarListScreen> createState() => _AdminLugarListScreenState();
}

class _AdminLugarListScreenState extends State<AdminLugarListScreen> {
  late LugarApi _lugarApi;
  List<LugarModelo> _lugares = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _lugarApi = LugarApi.create();
    _fetchLugares();
  }

  Future<void> _fetchLugares() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final List<LugarModelo> fetchedLugares = await _lugarApi.getAllLugares();
      setState(() {
        _lugares = fetchedLugares;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los lugares: ${e.toString()}';
      });
      _showSnackBar('Error: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteLugar(int id) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar este lugar?'),
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
        await _lugarApi.deleteLugar(id);
        _showSnackBar('Lugar eliminado con éxito.');
        _fetchLugares(); // Refresca la lista
      } catch (e) {
        _showSnackBar('Error al eliminar el lugar: ${e.toString()}', isError: true);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
        title: const Text('Admin Lugares'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLugares,
            tooltip: 'Recargar lugares',
          ),
        ],
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
                onPressed: _fetchLugares,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      )
          : _lugares.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'No hay lugares registrados.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _lugares.length,
        itemBuilder: (context, index) {
          final lugar = _lugares[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              leading: const CircleAvatar(
                  backgroundColor: Colors.tealAccent,
                  child: Icon(Icons.place, color: Colors.white)),
              title: Text(
                lugar.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Categoría: ${lugar.categoria.nombre}\nID: ${lugar.id ?? 'N/A'}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminLugarFormScreen(
                            lugar: lugar, // Pasar el lugar a editar
                          ),
                        ),
                      );
                      if (result == true) {
                        _fetchLugares(); // Refrescar si se editó
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteLugar(lugar.id!),
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
              builder: (context) => const AdminLugarFormScreen(), // Pantalla para crear nueva
            ),
          );
          if (result == true) {
            _fetchLugares(); // Refrescar si se creó una nueva
          }
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}