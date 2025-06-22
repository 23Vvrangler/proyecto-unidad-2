// lib/ui/admin/lugar/admin_lugar_list_screen.dart

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

  /// Fetches all places from the API.
  Future<void> _fetchLugares() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous error messages
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

  /// Deletes a place by its ID after user confirmation.
  Future<void> _deleteLugar(int id) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('¿Estás seguro de que quieres eliminar este lugar? Esta acción es irreversible.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.blueAccent)),
            ),
            FilledButton( // Using FilledButton for the delete button
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700, // Red color for delete
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        _isLoading = true; // Show a spinner or block UI while deleting
      });
      try {
        await _lugarApi.deleteLugar(id);
        _showSnackBar('Lugar eliminado con éxito.');
        _fetchLugares(); // Refresh the list after deletion
      } catch (e) {
        _showSnackBar('Error al eliminar el lugar: ${e.toString()}', isError: true);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Shows a SnackBar message to the user.
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
        title: const Text('Administrar Lugares'), // More descriptive title
        centerTitle: true,
        backgroundColor: Colors.teal, // Consistent AppBar color for places
        foregroundColor: Colors.white, // Text color for AppBar title and icons
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLugares,
            tooltip: 'Recargar lugares',
            color: Colors.white, // Explicitly white for consistency
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.teal)))
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
              ElevatedButton.icon( // Using ElevatedButton.icon for "Reintentar"
                onPressed: _fetchLugares,
                icon: const Icon(Icons.replay, color: Colors.white),
                label: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
            SizedBox(height: 20),
            // Optionally add a button to create the first place
            // ElevatedButton.icon(
            //   onPressed: () async {
            //     final result = await Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const AdminLugarFormScreen()),
            //     );
            //     if (result == true) {
            //       _fetchLugares();
            //     }
            //   },
            //   icon: const Icon(Icons.add, color: Colors.white),
            //   label: const Text('Crear primer lugar', style: TextStyle(color: Colors.white)),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.teal,
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            //   ),
            // ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _lugares.length,
        itemBuilder: (context, index) {
          final lugar = _lugares[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10), // Uniform margin
            elevation: 4, // Slightly increased elevation for better visual
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // More rounded corners
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              leading: const CircleAvatar( // Display a default icon for now
                radius: 30, // Standard size for leading avatar
                backgroundColor: Colors.teal, // Match teal theme
                child: Icon(Icons.place, color: Colors.white, size: 35),
              ),
              title: Text(
                lugar.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87), // Bigger and darker
              ),
              // Displaying category name and ID in the subtitle
              subtitle: Text(
                'Categoría: ${lugar.categoria.nombre}\nID: ${lugar.id ?? 'N/A'}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700), // Subtle color and size
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange), // Edit icon color
                    tooltip: 'Editar lugar',
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminLugarFormScreen(
                            lugar: lugar, // Pass the place to edit
                          ),
                        ),
                      );
                      if (result == true) {
                        _fetchLugares(); // Refresh if edited
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red), // Delete icon color
                    tooltip: 'Eliminar lugar',
                    onPressed: () => _deleteLugar(lugar.id!),
                  ),
                ],
              ),
              onTap: () async {
                // Optional: Navigate to a detail view or open the form for editing on ListTile tap
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminLugarFormScreen(
                      lugar: lugar,
                    ),
                  ),
                );
                if (result == true) {
                  _fetchLugares();
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminLugarFormScreen(), // Screen to create new place
            ),
          );
          if (result == true) {
            _fetchLugares(); // Refresh if a new place was created
          }
        },
        backgroundColor: Colors.teal, // Consistent FAB color
        foregroundColor: Colors.white, // Icon color for FAB
        child: const Icon(Icons.add),
      ),
    );
  }
}