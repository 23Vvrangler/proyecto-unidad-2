import 'package:flutter/material.dart';
import 'package:lb_app/apis/oferta_api.dart';
import 'package:lb_app/modelo/OfertaModelo.dart';

class OfertaFormCreate extends StatefulWidget {
  final Function onOfertaCreated;

  const OfertaFormCreate({required this.onOfertaCreated, Key? key}) : super(key: key);

  @override
  _OfertaFormCreateState createState() => _OfertaFormCreateState();
}

class _OfertaFormCreateState extends State<OfertaFormCreate> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para los campos de texto
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _duracionController = TextEditingController();

  String? _tipoPracticante;
  EmpresaDto? _empresaSeleccionada;
  bool _isLoading = false;
  String? _errorMessage;
  List<EmpresaDto> _empresas = [];

  // Método para cargar las empresas desde la API
  Future<void> _cargarEmpresas() async {
    try {
      final api = OfertaApi.create();
      final empresas = await api.obtenerEmpresas();
      setState(() {
        _empresas = empresas;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar las empresas: $e';
      });
    }
  }

  // Método para guardar la oferta
  Future<void> _guardarOferta() async {
    if (!_formKey.currentState!.validate() || _tipoPracticante == null || _empresaSeleccionada == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final nuevaOferta = OfertaModelo(
      id: 0, // La API probablemente asignará un ID automáticamente
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      ubicacion: _ubicacionController.text.trim(),
      duracion: _duracionController.text.trim(),
      tipoPracticante: _tipoPracticante!,
      empresaId: _empresaSeleccionada!.id,
      empresaDto: _empresaSeleccionada!,
    );

    try {
      final api = OfertaApi.create();
      await api.guardarOferta(nuevaOferta);
      widget.onOfertaCreated(); // Notificar a la pantalla principal para actualizar la lista
      Navigator.pop(context); // Cierra el formulario
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al guardar la oferta: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarEmpresas(); // Cargar las empresas al inicio
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Nueva Oferta'),
        backgroundColor: Color(0xFF375534),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_errorMessage != null) _buildErrorMessage(),
              _buildTextFormField('Título', _tituloController),
              _buildTextFormField('Descripción', _descripcionController, maxLines: 4),
              _buildTextFormField('Ubicación', _ubicacionController),
              _buildTextFormField('Duración', _duracionController),
              _buildDropdownTipoPracticante(),
              _buildDropdownEmpresa(),
              const SizedBox(height: 24),
              _isLoading ? _buildLoadingIndicator() : _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir un campo de texto genérico
  Widget _buildTextFormField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  // Método para construir el campo Dropdown para el tipo de practicante
  Widget _buildDropdownTipoPracticante() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _tipoPracticante,
        decoration: InputDecoration(
          labelText: 'Tipo de Practicante',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: 'BASICO', child: Text('Básico')),
          DropdownMenuItem(value: 'INTERMEDIO', child: Text('Intermedio')),
          DropdownMenuItem(value: 'AVANZADO', child: Text('Avanzado')),
        ],
        onChanged: (value) {
          setState(() {
            _tipoPracticante = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Selecciona el tipo de practicante';
          }
          return null;
        },
      ),
    );
  }

  // Método para construir el campo Dropdown para la empresa
  Widget _buildDropdownEmpresa() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<EmpresaDto>(
        value: _empresaSeleccionada,
        decoration: InputDecoration(
          labelText: 'Seleccionar Empresa',
          border: OutlineInputBorder(),
        ),
        items: _empresas.map((empresa) {
          return DropdownMenuItem<EmpresaDto>(
            value: empresa,
            child: Text(empresa.nombre),
          );
        }).toList(),
        onChanged: (empresa) {
          setState(() {
            _empresaSeleccionada = empresa;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Selecciona una empresa';
          }
          return null;
        },
      ),
    );
  }

  // Método para mostrar el mensaje de error
  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        _errorMessage!,
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  // Método para mostrar el indicador de carga
  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF375534)),
      ),
    );
  }

  // Método para el botón de guardar
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _guardarOferta,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF375534),
      ),
      child: Text('Guardar Oferta'),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    _duracionController.dispose();
    super.dispose();
  }
}