import 'package:app_capachica/modelo/CategoriaLugarModelo.dart';
import 'package:flutter/material.dart';
import 'package:app_capachica/apis/categoria_api.dart'; // Importamos la API

class MainCategoriaScreen extends StatefulWidget {
  const MainCategoriaScreen({super.key});

  @override
  State<MainCategoriaScreen> createState() => _MainCategoriaScreenState();
}

class _MainCategoriaScreenState extends State<MainCategoriaScreen> {
  late CategoriaApi _categoriaApi; // Instancia de nuestra API
  List<CategoriaLugarModelo> _categorias = []; // Lista para almacenar las categorías
  bool _isLoading = true; // Para controlar el estado de carga
  String? _errorMessage; // Para almacenar mensajes de error

  @override
  void initState() {
    super.initState();
    _categoriaApi = CategoriaApi.create(); // Creamos la instancia de la API
    _fetchCategorias(); // Llamamos a la función para obtener las categorías al iniciar la vista
  }

  // Método para obtener todas las categorías desde la API
  Future<void> _fetchCategorias() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Limpiar cualquier error anterior
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

  // Helper para mostrar SnackBar
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
        title: const Text('Explorar Categorías'), // Título más conciso para un catálogo
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0, // Sin sombra para un look más plano
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
                onPressed: _fetchCategorias,
                child: const Text('Reintentar'),
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
            Icon(Icons.category, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'No hay categorías disponibles.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : GridView.builder( // ¡Cambiamos a GridView.builder!
        padding: const EdgeInsets.all(12.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columnas por fila
          crossAxisSpacing: 12.0, // Espacio horizontal entre tarjetas
          mainAxisSpacing: 12.0, // Espacio vertical entre tarjetas
          childAspectRatio: 0.85, // Relación de aspecto de los ítems (ancho/alto)
        ),
        itemCount: _categorias.length,
        itemBuilder: (context, index) {
          final categoria = _categorias[index];
          return GestureDetector( // Hacemos toda la tarjeta interactiva
            onTap: () {
              _showSnackBar('Mostrando lugares en ${categoria.nombre}');
              // Aquí podrías navegar a una pantalla de Lugares filtrados por esta categoría
              // Navigator.push(context, MaterialPageRoute(builder: (context) => LugarListScreen(categoria: categoria)));
            },
            child: Card(
              elevation: 4, // Más sombra para destacar las tarjetas
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0), // Bordes más redondeados
              ),
              clipBehavior: Clip.antiAlias, // Para que la imagen respete los bordes
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Área de la imagen (condicional si urlImagen es null)
                  Expanded(
                    child: categoria.urlImagen != null && categoria.urlImagen!.isNotEmpty
                        ? Image.network(
                      categoria.urlImagen!,
                      fit: BoxFit.cover, // Cubrir el espacio disponible
                      width: double.infinity, // Ancho completo
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback si la imagen no carga
                        return Container(
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        );
                      },
                    )
                        : Container( // Contenedor de fallback si no hay imagen
                      color: Colors.blueGrey[100], // Fondo suave
                      alignment: Alignment.center,
                      child: const Icon(Icons.category, size: 60, color: Colors.blueGrey),
                    ),
                  ),
                  // Área del texto
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoria.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1, // Una sola línea para el nombre
                          overflow: TextOverflow.ellipsis, // Puntos suspensivos si el nombre es largo
                        ),
                        const SizedBox(height: 4),
                        if (categoria.lugares != null) // Mostrar cantidad de lugares si existe
                          Text(
                            '${categoria.lugares!.length} Lugares',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        // Puedes añadir más detalles aquí si los tienes y son relevantes para el usuario
                        // Ej: ID (si quieres mostrarlo al usuario, aunque es más admin)
                        // Text('ID: ${categoria.id ?? 'N/A'}', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}