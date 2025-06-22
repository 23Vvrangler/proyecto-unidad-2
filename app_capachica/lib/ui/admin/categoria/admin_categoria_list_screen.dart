// lib/ui/admin/categoria/admin_categoria_list_screen.dart

import 'package:app_capachica/modelo/CategoriaLugarModelo.dart';
import 'package:flutter/material.dart';
import 'package:app_capachica/apis/categoria_api.dart';
import 'package:app_capachica/ui/admin/categoria/admin_categoria_form_screen.dart'; // Para crear/editar

class AdminCategoriaListScreen extends StatefulWidget {
  const AdminCategoriaListScreen({super.key});

  @override
  State<AdminCategoriaListScreen> createState() => _AdminCategoriaListScreenState();
}

class _AdminCategoriaListScreenState extends State<AdminCategoriaListScreen> {
  late CategoriaApi _categoriaApi;
  List<CategoriaLugarModelo> _categorias = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _categoriaApi = CategoriaApi.create();
    _fetchCategorias();
  }

  /// Fetches all categories from the API.
  Future<void> _fetchCategorias() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous error messages
    });
    try {
      final List<CategoriaLugarModelo> fetchedCategorias = await _categoriaApi.getAllCategorias();
      setState(() {
        _categorias = fetchedCategorias;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar las categorías: ${e.toString()}';
      });
      _showSnackBar('Error: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Deletes a category by its ID after user confirmation.
  Future<void> _deleteCategoria(int id) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('¿Estás seguro de que quieres eliminar esta categoría? Esta acción es irreversible.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.blueAccent)),
            ),
            FilledButton( // Usando FilledButton para el botón de eliminación
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700, // Color rojo para eliminar
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
        await _categoriaApi.deleteCategoria(id);
        _showSnackBar('Categoría eliminada con éxito.');
        _fetchCategorias(); // Refresh the list after deletion
      } catch (e) {
        _showSnackBar('Error al eliminar la categoría: ${e.toString()}', isError: true);
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
        title: const Text('Admin Categorías'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // Consistent AppBar color for categories
        foregroundColor: Colors.white, // Text color for AppBar title and icons
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCategorias,
            tooltip: 'Recargar categorías',
            color: Colors.white, // Explicitly white for consistency
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent)))
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
                onPressed: _fetchCategorias,
                icon: const Icon(Icons.replay, color: Colors.white),
                label: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          : _categorias.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'No hay categorías registradas.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Optionally add a button to create the first category
            // ElevatedButton.icon(
            //   onPressed: () async {
            //     final result = await Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const AdminCategoriaFormScreen()),
            //     );
            //     if (result == true) {
            //       _fetchCategorias();
            //     }
            //   },
            //   icon: const Icon(Icons.add, color: Colors.white),
            //   label: const Text('Crear primera categoría', style: TextStyle(color: Colors.white)),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.blueAccent,
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            //   ),
            // ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _categorias.length,
        itemBuilder: (context, index) {
          final categoria = _categorias[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
            elevation: 3, // Slightly increased elevation for better visual
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // More rounded corners
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              leading: categoria.urlImagen != null && categoria.urlImagen!.isNotEmpty
                  ? ClipRRect( // Clip the image to a circle
                borderRadius: BorderRadius.circular(25), // Half of width/height for perfect circle
                child: Image.network(
                  categoria.urlImagen!,
                  width: 50, // Standard size for leading image
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to a default icon if image fails to load
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.blueGrey,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.broken_image, color: Colors.white, size: 30),
                    );
                  },
                ),
              )
                  : const CircleAvatar( // Default icon if no image URL
                backgroundColor: Colors.blueGrey,
                child: Icon(Icons.category, color: Colors.white, size: 30),
              ),
              title: Text(
                categoria.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text('ID: ${categoria.id ?? 'N/A'}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange), // Edit icon color
                    tooltip: 'Editar categoría',
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminCategoriaFormScreen(
                            categoria: categoria, // Pass the category to edit
                          ),
                        ),
                      );
                      if (result == true) {
                        _fetchCategorias(); // Refresh if edited
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red), // Delete icon color
                    tooltip: 'Eliminar categoría',
                    onPressed: () => _deleteCategoria(categoria.id!),
                  ),
                ],
              ),
              onTap: () async {
                // Opcional: Navegar a una vista de detalle o abrir el formulario para editar al tocar el ListTile
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminCategoriaFormScreen(
                      categoria: categoria,
                    ),
                  ),
                );
                if (result == true) {
                  _fetchCategorias();
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
              builder: (context) => const AdminCategoriaFormScreen(), // Screen to create new category
            ),
          );
          if (result == true) {
            _fetchCategorias(); // Refresh if a new category was created
          }
        },
        backgroundColor: Colors.blueAccent, // Consistent FAB color
        foregroundColor: Colors.white, // Icon color for FAB
        child: const Icon(Icons.add),
      ),
    );
  }
}