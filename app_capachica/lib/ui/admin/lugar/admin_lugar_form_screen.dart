// lib/ui/admin/lugar/admin_lugar_form_screen.dart

import 'package:app_capachica/modelo/CategoriaLugarModelo.dart';
import 'package:app_capachica/modelo/LugarModelo.dart';
import 'package:flutter/material.dart';
import 'package:app_capachica/apis/lugar_api.dart';
import 'package:app_capachica/apis/categoria_api.dart';

class AdminLugarFormScreen extends StatefulWidget {
  final LugarModelo? lugar; // Null para crear, con valor para editar

  const AdminLugarFormScreen({super.key, this.lugar});

  @override
  State<AdminLugarFormScreen> createState() => _AdminLugarFormScreenState();
}

class _AdminLugarFormScreenState extends State<AdminLugarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _calificacionController = TextEditingController();

  late LugarApi _lugarApi;
  late CategoriaApi _categoriaApi;
  bool _isSaving = false;
  bool _isLoadingCategories = true;
  List<CategoriaLugarModelo> _categorias = [];
  CategoriaLugarModelo? _selectedCategory; // Para el Dropdown

  @override
  void initState() {
    super.initState();
    _lugarApi = LugarApi.create();
    _categoriaApi = CategoriaApi.create();
    _fetchCategorias(); // Cargar categorías al inicio

    if (widget.lugar != null) {
      _nombreController.text = widget.lugar!.nombre;
      _direccionController.text = widget.lugar!.direccion;
      _descripcionController.text = widget.lugar!.descripcion ?? '';
      _calificacionController.text = widget.lugar!.calificacionPromedio?.toString() ?? '';
      // _selectedCategory se asignará dentro de _fetchCategorias
      // para asegurar que la categoría del lugar exista en la lista cargada.
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _descripcionController.dispose();
    _calificacionController.dispose();
    super.dispose();
  }

  /// Fetches all categories from the API and sets the selected category for editing/creating.
  Future<void> _fetchCategorias() async {
    setState(() {
      _isLoadingCategories = true;
    });
    try {
      _categorias = await _categoriaApi.getAllCategorias();

      if (widget.lugar != null) {
        // --- INICIO DE LA CORRECCIÓN FINAL ---
        // Intentamos encontrar la categoría del lugar existente.
        // Usamos try-catch porque firstWhere sin orElse lanza un StateError si no encuentra.
        CategoriaLugarModelo? foundCategory;
        try {
          foundCategory = _categorias.firstWhere(
                (cat) => cat.id == widget.lugar!.categoria.id,
          );
        } on StateError {
          // Si la categoría no se encuentra (StateError), foundCategory permanece null.
          _showSnackBar('La categoría del lugar a editar no fue encontrada en la lista actual.', isError: true);
        }

        // Si se encontró, la asignamos.
        if (foundCategory != null) {
          _selectedCategory = foundCategory;
        } else {
          // Si no se encontró o no hay categorías, seleccionamos la primera si existe, o null.
          if (_categorias.isNotEmpty) {
            _selectedCategory = _categorias.first;
            // Solo mostramos un mensaje adicional si estamos editando y cambiamos la categoría original.
            if (widget.lugar != null) {
              _showSnackBar('Seleccionando la primera categoría disponible.', isError: true);
            }
          } else {
            _selectedCategory = null; // No hay categorías disponibles.
            _showSnackBar('No hay categorías disponibles para seleccionar.', isError: true);
          }
        }
        // --- FIN DE LA CORRECCIÓN FINAL ---
      } else if (_categorias.isNotEmpty) {
        // Para nuevas creaciones, si hay categorías, selecciona la primera por defecto.
        _selectedCategory = _categorias.first;
      } else {
        // Si no hay categorías para una nueva creación.
        _selectedCategory = null;
        _showSnackBar('No hay categorías disponibles para crear un nuevo lugar.', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error al cargar categorías: ${e.toString()}', isError: true);
      _selectedCategory = null; // Asegura que selectedCategory sea null en caso de error.
    } finally {
      setState(() {
        _isLoadingCategories = false;
      });
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

  /// Validates the form and saves (creates or updates) the place.
  Future<void> _saveLugar() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Por favor, corrige los errores del formulario.', isError: true);
      return;
    }
    if (_selectedCategory == null) {
      _showSnackBar('Por favor, selecciona una categoría.', isError: true);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final nuevaCalificacion = double.tryParse(_calificacionController.text.trim());

    final nuevoLugar = LugarModelo(
      id: widget.lugar?.id,
      nombre: _nombreController.text.trim(),
      direccion: _direccionController.text.trim(),
      descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
      calificacionPromedio: nuevaCalificacion,
      categoria: _selectedCategory!, // Aseguramos que no es null porque lo validamos antes.
    );

    try {
      if (widget.lugar == null) {
        // Crear nuevo lugar
        await _lugarApi.createLugar(nuevoLugar);
        _showSnackBar('Lugar creado con éxito.');
      } else {
        // Actualizar lugar existente
        await _lugarApi.updateLugar(nuevoLugar.id!, nuevoLugar);
        _showSnackBar('Lugar actualizado con éxito.');
      }
      if (mounted) {
        Navigator.pop(context, true); // Pop con 'true' para indicar que hubo un cambio.
      }
    } catch (e) {
      _showSnackBar('Error al guardar el lugar: ${e.toString()}', isError: true);
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
        title: Text(widget.lugar == null ? 'Crear Lugar' : 'Editar Lugar'),
        centerTitle: true,
        backgroundColor: Colors.teal, // Color consistente para el AppBar de lugares.
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
                  labelText: 'Nombre del Lugar',
                  hintText: 'Ej. Restaurante El Sol',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business, color: Colors.teal),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 2.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el nombre del lugar.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  hintText: 'Ej. Calle Falsa 123',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on, color: Colors.teal),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 2.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa la dirección.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  hintText: 'Un lugar acogedor con excelente comida.',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description, color: Colors.teal),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 2.0),
                  ),
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _calificacionController,
                decoration: const InputDecoration(
                  labelText: 'Calificación Promedio (opcional)',
                  hintText: 'Ej. 4.5',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.star, color: Colors.teal),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final double? calificacion = double.tryParse(value);
                    if (calificacion == null || calificacion < 0 || calificacion > 5) {
                      return 'Debe ser un número entre 0 y 5.';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _isLoadingCategories
                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.teal)))
                  : DropdownButtonFormField<CategoriaLugarModelo>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category, color: Colors.teal),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 2.0),
                  ),
                ),
                items: _categorias.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Text(categoria.nombre),
                  );
                }).toList(),
                onChanged: (CategoriaLugarModelo? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecciona una categoría.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _isSaving
                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.teal)))
                  : ElevatedButton.icon(
                onPressed: _saveLugar,
                icon: Icon(widget.lugar == null ? Icons.add : Icons.save),
                label: Text(widget.lugar == null ? 'Crear Lugar' : 'Guardar Cambios',
                    style: const TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
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