import 'package:app_capachica/modelo/CategoriaLugarModelo.dart';
import 'package:flutter/material.dart';
import 'package:app_capachica/apis/categoria_api.dart';

class AdminCategoriaFormScreen extends StatefulWidget {
  final CategoriaLugarModelo? categoria;

  const AdminCategoriaFormScreen({Key? key, this.categoria}) : super(key: key);

  @override
  _AdminCategoriaFormScreenState createState() => _AdminCategoriaFormScreenState();
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

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  Future<void> _saveCategoria() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Por favor, corrige los errores del formulario.', isError: true);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final nuevaCategoria = CategoriaLugarModelo(
      id: widget.categoria?.id,
      nombre: _nombreController.text.trim(),
      urlImagen: _urlImagenController.text.trim().isEmpty ? null : _urlImagenController.text.trim(),
      lugares: widget.categoria?.lugares,
    );

    try {
      if (widget.categoria == null) {
        await _categoriaApi.createCategoria(nuevaCategoria);
        _showSnackBar('Categoría creada con éxito.');
      } else {
        await _categoriaApi.updateCategoria(nuevaCategoria.id!, nuevaCategoria);
        _showSnackBar('Categoría actualizada con éxito.');
      }
      if (mounted) {
        Navigator.pop(context, true);
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
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
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
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category, color: Colors.blueAccent),
                  focusedBorder: OutlineInputBorder(
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
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image, color: Colors.blueAccent),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 32),
              _isSaving
                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent)))
                  : ElevatedButton.icon(
                onPressed: _saveCategoria,
                icon: Icon(widget.categoria == null ? Icons.add : Icons.save, color: Colors.white),
                label: Text(widget.categoria == null ? 'Crear Categoría' : 'Guardar Cambios',
                    style: const TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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