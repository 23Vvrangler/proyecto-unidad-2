import 'package:flutter/material.dart';
import 'package:lb_app/apis/oferta_api.dart';
import 'package:lb_app/modelo/OfertaModelo.dart';

class OfertaFormEdit extends StatefulWidget {
  final OfertaModelo oferta;
  final Function() onOfertaUpdated;

  OfertaFormEdit({
    required this.oferta,
    required this.onOfertaUpdated,
  });

  @override
  _OfertaFormEditState createState() => _OfertaFormEditState();
}

class _OfertaFormEditState extends State<OfertaFormEdit> {
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _ubicacionController;
  late TextEditingController _duracionController;
  late String _tipoPracticante;
  late int _empresaIdSeleccionada;
  List<EmpresaDto> _empresas = [];
  EmpresaDto? _empresaSeleccionada;

  List<String> tiposDePracticante = ['Interno', 'Externo', 'AVANZADO'];

  @override
  void initState() {
    super.initState();

    // Inicializando los controladores con los valores actuales de la oferta
    _tituloController = TextEditingController(text: widget.oferta.titulo);
    _descripcionController = TextEditingController(text: widget.oferta.descripcion);
    _ubicacionController = TextEditingController(text: widget.oferta.ubicacion);
    _duracionController = TextEditingController(text: widget.oferta.duracion);

    // Inicializando los valores seleccionados
    _tipoPracticante = widget.oferta.tipoPracticante;
    _empresaIdSeleccionada = widget.oferta.empresaId;

    // Cargar las empresas desde la API
    _fetchEmpresas();
  }

  Future<void> _fetchEmpresas() async {
    try {
      final empresas = await OfertaApi.create().obtenerEmpresas(); // Asumiendo que esta API existe
      setState(() {
        _empresas = empresas;
        _empresaSeleccionada = _empresas.firstWhere((empresa) => empresa.id == _empresaIdSeleccionada, orElse: () => _empresas[0]);
      });
    } catch (e) {
      // Manejo de errores al cargar las empresas
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar las empresas: $e')));
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    final updatedOferta = OfertaModelo(
      id: widget.oferta.id,
      titulo: _tituloController.text,
      descripcion: _descripcionController.text,
      ubicacion: _ubicacionController.text,
      tipoPracticante: _tipoPracticante,
      duracion: _duracionController.text,
      empresaId: _empresaSeleccionada!.id,
      empresaDto: _empresaSeleccionada!,
    );

    try {
      await OfertaApi.create().editarOferta(updatedOferta);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Oferta actualizada con éxito')));
      widget.onOfertaUpdated();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar oferta: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Oferta'),
        backgroundColor: Color(0xFF375534),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Título', _tituloController),
              _buildTextField('Descripción', _descripcionController),
              _buildTextField('Ubicación', _ubicacionController),
              _buildTextField('Duración', _duracionController),
              
              // Dropdown para Tipo de Practicante
              DropdownButtonFormField<String>(
                value: _tipoPracticante,
                decoration: InputDecoration(
                  labelText: 'Tipo de Practicante',
                  border: OutlineInputBorder(),
                ),
                items: tiposDePracticante.map((tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (tipo) {
                  setState(() {
                    _tipoPracticante = tipo!;
                  });
                },
              ),
              
              // Dropdown para seleccionar la Empresa
              if (_empresas.isNotEmpty) 
                _buildDropdownEmpresa(),
              
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarCambios,
                child: Text('Guardar Cambios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF375534),
                  foregroundColor: Color(0xFFE3EED4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builder genérico para campos de texto
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
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
}