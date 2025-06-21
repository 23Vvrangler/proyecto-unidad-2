import 'package:app_capac/apis/categorias_api.dart';
import 'package:app_capac/modelo/CategoriaLugarModelo.dart';
import 'package:flutter/material.dart';

// import 'package:app_capac/screens/categoria_form_edit.dart'; // ¡Eliminado! No se usa más

class CategoriaMain extends StatefulWidget {
  const CategoriaMain({super.key});
  @override
  _CategoriaMainState createState() => _CategoriaMainState();
}

class _CategoriaMainState extends State<CategoriaMain> {
  late CategoriasApi _categoriasApi;
  List<CategoriaLugarModelo> _categorias = [];
  List<CategoriaLugarModelo> _categoriasFiltradas = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _categoriasApi = CategoriasApi.create(); // Inicializa tu API de categorías
    _cargarCategorias();
  }

  // Método para cargar las categorías desde la API
  Future<void> _cargarCategorias() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Limpia cualquier mensaje de error anterior
    });

    try {
      final data = await _categoriasApi.getAllCategorias();
      setState(() {
        _categorias = data;
        _categoriasFiltradas = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar categorías: $e'; // Muestra el error al usuario
      });
      print('Error al cargar categorías: $e'); // Imprime el error en la consola
    }
  }

  // Método para filtrar la lista de categorías según la búsqueda
  void _filtrarCategorias(String query) {
    setState(() {
      _categoriasFiltradas = _categorias
          .where((categoria) =>
          categoria.nombre.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Widget para mostrar mensajes de error/éxito
  Widget _buildMessage() {
    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).colorScheme.error),
        ),
        child: Text(
          _errorMessage!,
          style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Categorías de Lugares'),
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
          _SearchBar(onChanged: _filtrarCategorias),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildMessage(),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _CategoriaList(
                categorias: _categoriasFiltradas,
                onCategoriaUpdated: _cargarCategorias, // Callback para refrescar la lista
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
          hintText: 'Buscar categoría...',
          prefixIcon: Icon(Icons.search, color: colorScheme.primary),
          // Las propiedades de estilo de borde ya están definidas en AppTheme.inputDecorationTheme
        ),
      ),
    );
  }
}

class _CategoriaList extends StatelessWidget {
  final List<CategoriaLugarModelo> categorias;
  final Function() onCategoriaUpdated;

  const _CategoriaList({
    required this.categorias,
    required this.onCategoriaUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (categorias.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron categorías.',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: categorias.length,
      itemBuilder: (context, index) {
        final categoria = categorias[index];
        return _CategoriaListItem(
          categoria: categoria,
          onCategoriaUpdated: onCategoriaUpdated, // Pasamos el callback
        );
      },
    );
  }
}

class _CategoriaListItem extends StatelessWidget {
  final CategoriaLugarModelo categoria;
  final Function() onCategoriaUpdated;

  const _CategoriaListItem({
    required this.categoria,
    required this.onCategoriaUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      // Card theming is handled by AppTheme
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: categoria.urlImagen.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              categoria.urlImagen,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.broken_image,
                size: 60,
                color: colorScheme.error,
              ),
            ),
          )
              : Icon(Icons.category, size: 60, color: colorScheme.primary), // Icono por defecto
          title: Text(
            categoria.nombre,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ID: ${categoria.id ?? "N/A"}',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (categoria.creadoEn != null)
                Text(
                  'Creado: ${categoria.creadoEn!.toLocal().toString().split(' ')[0]}', // Formato simple de fecha
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón de Edición - ELIMINADO
              // Botón de Eliminar
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer, // Un color del tema para indicar acción de peligro
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.delete, color: colorScheme.onErrorContainer),
                  onPressed: () async {
                    // Implementar lógica de eliminación aquí
                    bool? confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirmar eliminación'),
                          content: Text('¿Estás seguro de que quieres eliminar la categoría "${categoria.nombre}"?'),
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

                    if (confirmDelete == true && categoria.id != null) {
                      try {
                        await CategoriasApi.create().deleteCategoria(categoria.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Categoría eliminada con éxito: ${categoria.nombre}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        onCategoriaUpdated(); // Refrescar la lista
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al eliminar categoría: $e'),
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