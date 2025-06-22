import 'package:app_capachica/modelo/LugarModelo.dart';
import 'package:flutter/material.dart';
import 'package:app_capachica/apis/lugar_api.dart'; // Importamos la API de Lugar

class MainLugarScreen extends StatefulWidget {
  const MainLugarScreen({super.key});

  @override
  State<MainLugarScreen> createState() => _MainLugarScreenState();
}

class _MainLugarScreenState extends State<MainLugarScreen> {
  late LugarApi _lugarApi; // Instancia de nuestra API de Lugar
  List<LugarModelo> _lugares = []; // Lista para almacenar los lugares
  bool _isLoading = true; // Para controlar el estado de carga
  String? _errorMessage; // Para almacenar mensajes de error

  @override
  void initState() {
    super.initState();
    _lugarApi = LugarApi.create(); // Creamos la instancia de la API de Lugar
    _fetchLugares(); // Llamamos a la función para obtener los lugares al iniciar la vista
  }

  // Método para obtener todos los lugares desde la API
  Future<void> _fetchLugares() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Limpiar cualquier error anterior
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
        title: const Text('Descubre Lugares'), // Título más atractivo
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0, // Elimina la sombra para un look moderno
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
            Icon(Icons.location_off, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'No hay lugares disponibles en este momento.',
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
          childAspectRatio: 0.7, // Ajusta la relación de aspecto para que quepa más info
        ),
        itemCount: _lugares.length,
        itemBuilder: (context, index) {
          final lugar = _lugares[index];
          return GestureDetector( // Toda la tarjeta será clickable
            onTap: () {
              _showSnackBar('Abriendo detalles de "${lugar.nombre}"');
              // Aquí podrías navegar a una pantalla de detalles del lugar (a crear)
              // Navigator.push(context, MaterialPageRoute(builder: (context) => LugarDetalleScreen(lugar: lugar)));
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              clipBehavior: Clip.antiAlias, // Recorta el contenido para respetar los bordes
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de la imagen (Placeholder por ahora, si tu modelo no tiene URL de imagen)
                  Expanded(
                    child: Container(
                      color: Colors.teal.shade50, // Fondo para el placeholder
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.image, // Ícono de imagen como placeholder
                        size: 70,
                        color: Colors.teal.shade200,
                      ),
                      // Si tu LugarModelo tiene 'urlImagen', descomenta y adapta esto:
                      // child: lugar.urlImagen != null && lugar.urlImagen!.isNotEmpty
                      //     ? Image.network(
                      //         lugar.urlImagen!,
                      //         fit: BoxFit.cover,
                      //         width: double.infinity,
                      //         errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      //       )
                      //     : Icon(Icons.place, size: 60, color: Colors.grey),
                    ),
                  ),
                  // Contenido del lugar
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lugar.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '📍 ${lugar.direccion}',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (lugar.calificacionPromedio != null)
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              Text(
                                ' ${lugar.calificacionPromedio!.toStringAsFixed(1)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        Text(
                          'Categoría: ${lugar.categoria.nombre}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        // La descripción puede ser muy larga para una tarjeta de catálogo,
                        // pero puedes mostrar una parte si es crucial:
                        if (lugar.descripcion != null && lugar.descripcion!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              lugar.descripcion!,
                              maxLines: 2, // Limita la descripción a 2 líneas
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                            ),
                          ),
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