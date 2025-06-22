// lib/ui/admin/categoria/admin_categoria_form_screen.dart

import 'package:app_capachica/modelo/CategoriaLugarModelo.dart';
import 'package:flutter/material.dart';
import 'package:app_capachica/apis/categoria_api.dart';

class AdminCategoriaFormScreen extends StatefulWidget {
  final CategoriaLugarModelo? categoria; // Será null para crear, tendrá valor para editar

  const AdminCategoriaFormScreen({super.key, this.categoria});

  @override
  State<AdminCategoriaFormScreen> createState() => _AdminCategoriaFormScreenState();
}

class _AdminCategoriaFormScreenState extends State<AdminCategoriaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _urlImagenController = TextEditingController();

  late CategoriaApi _categoriaApi;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _categoriaApi = CategoriaApi.create();
    if (widget.categoria != null) {
      // Si estamos editando, precarga los datos
      _nombreController.text = widget.categoria!.nombre;
      _urlImagenController.text = widget.categoria!.urlImagen ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _urlImagenController.dispose();
    super.dispose();
  }

  /// Muestra un SnackBar con un mensaje al usuario.
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  /// Valida el formulario y guarda (crea o actualiza) la categoría.
  Future<void> _saveCategoria() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Por favor, corrige los errores del formulario.', isError: true);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final nuevaCategoria = CategoriaLugarModelo(
      id: widget.categoria?.id, // Si es edición, se mantiene el ID
      nombre: _nombreController.text.trim(),
      // Si la URL de imagen está vacía, se guarda como null
      urlImagen: _urlImagenController.text.trim().isEmpty ? null : _urlImagenController.text.trim(),
      lugares: widget.categoria?.lugares, // Mantener la lista de lugares si existe (útil si la API lo maneja)
    );

    try {
      if (widget.categoria == null) {
        // Crear nueva categoría
        await _categoriaApi.createCategoria(nuevaCategoria);
        _showSnackBar('Categoría creada con éxito.');
      } else {
        // Actualizar categoría existente
        await _categoriaApi.updateCategoria(nuevaCategoria.id!, nuevaCategoria);
        _showSnackBar('Categoría actualizada con éxito.');
      }
      if (mounted) {
        Navigator.pop(context, true); // Devuelve 'true' para indicar que hubo un cambio.
      }
    } catch (e) {
      _showSnackBar('Error al guardar la categoría: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoria == null ? 'Crear Categoría' : 'Editar Categoría'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // Color consistente para el AppBar de categorías.
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Categoría',
                  hintText: 'Ej. Restaurantes',
                  border: OutlineInputBorder(), // Estilo de borde establecido.
                  prefixIcon: Icon(Icons.category, color: Colors.blueAccent), // Color del icono.
                  focusedBorder: OutlineInputBorder( // Estilo de borde cuando está enfocado.
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el nombre de la categoría.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlImagenController,
                decoration: const InputDecoration(
                  labelText: 'URL de la Imagen (opcional)',
                  hintText: 'Ej. https://ejemplo.com/imagen.jpg',
                  border: OutlineInputBorder(), // Estilo de borde establecido.
                  prefixIcon: Icon(Icons.image, color: Colors.blueAccent), // Color del icono.
                  focusedBorder: OutlineInputBorder( // Estilo de borde cuando está enfocado.
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.url, // Teclado específico para URLs.
              ),
              const SizedBox(height: 32),
              _isSaving
                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent)))
                  : ElevatedButton.icon(
                onPressed: _saveCategoria,
                icon: Icon(widget.categoria == null ? Icons.add : Icons.save),
                label: Text(widget.categoria == null ? 'Crear Categoría' : 'Guardar Cambios',
                    style: const TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blueAccent, // Color de botón consistente.
                  foregroundColor: Colors.white, // Color de texto del botón.
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Bordes redondeados.
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}