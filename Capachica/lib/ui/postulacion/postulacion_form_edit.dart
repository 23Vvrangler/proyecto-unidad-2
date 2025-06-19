import 'package:flutter/material.dart';
import 'package:lb_app/modelo/PostulacionModelo.dart';
import 'package:lb_app/apis/postulacion_api.dart';

class PostulacionFormEdit extends StatefulWidget {
  final PostulacionModelo postulacion;
  final Function() onPostulacionUpdated; // Callback para refrescar la lista

  PostulacionFormEdit(
      {required this.postulacion, required this.onPostulacionUpdated});

  @override
  _PostulacionFormEditState createState() => _PostulacionFormEditState();
}

class _PostulacionFormEditState extends State<PostulacionFormEdit> {
  late TextEditingController _fechaController;
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _ubicacionController;
  late TextEditingController _tipoPracticanteController;
  late TextEditingController _duracionController;

  late PostulacionApi apiService;
  String? _estadoSeleccionado;

  @override
  void initState() {
    super.initState();
    apiService = PostulacionApi.create();

    _estadoSeleccionado = widget.postulacion.estadoPostulacion;
    _fechaController =
        TextEditingController(text: widget.postulacion.fechaPostulacion);
    _tituloController =
        TextEditingController(text: widget.postulacion.ofertaDto.titulo);
    _descripcionController =
        TextEditingController(text: widget.postulacion.ofertaDto.descripcion);
    _ubicacionController =
        TextEditingController(text: widget.postulacion.ofertaDto.ubicacion);
    _tipoPracticanteController = TextEditingController(
        text: widget.postulacion.ofertaDto.tipoPracticante);
    _duracionController =
        TextEditingController(text: widget.postulacion.ofertaDto.duracion);
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _tituloController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    _tipoPracticanteController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    final updatedPostulacion = PostulacionModelo(
      id: widget.postulacion.id,
      estadoPostulacion:
          _estadoSeleccionado ?? widget.postulacion.estadoPostulacion,
      fechaPostulacion: _fechaController.text,
      estudianteId: widget.postulacion.estudianteId,
      estudianteDto: widget.postulacion.estudianteDto,
      ofertaId: widget.postulacion.ofertaId,
      ofertaDto: OfertaDto(
        id: widget.postulacion.ofertaDto.id,
        titulo: _tituloController.text,
        descripcion: _descripcionController.text,
        ubicacion: _ubicacionController.text,
        tipoPracticante: _tipoPracticanteController.text,
        duracion: _duracionController.text,
      ),
    );

    try {
      await apiService.editarPostulacion(updatedPostulacion);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Postulación actualizada con éxito')));
      widget
          .onPostulacionUpdated(); // Llamamos al callback para refrescar la lista
      Navigator.pop(context); // Volver a la pantalla principal
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar postulación: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Postulación'),
        backgroundColor: Color(0xFF375534), // Color de la AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEstadoDropdown(),
              _buildTextField('Fecha de Postulación', _fechaController,
                  enabled: false),
              _buildTextField('Título de la Oferta', _tituloController,
                  enabled: false),
              _buildTextField(
                  'Descripción de la Oferta', _descripcionController,
                  enabled: false),
              _buildTextField('Ubicación', _ubicacionController,
                  enabled: false),
              _buildTextField('Tipo de Practicante', _tipoPracticanteController,
                  enabled: false),
              _buildTextField('Duración de la Práctica', _duracionController,
                  enabled: false),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarCambios,
                child: Text('Guardar Cambios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color(0xFF375534), // Color de fondo del botón
                  foregroundColor:
                      Color(0xFFE3EED4), // Color del texto en el botón
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _estadoSeleccionado,
        decoration: InputDecoration(
          labelText: 'Estado de Postulación',
          labelStyle:
              TextStyle(color: Color(0xFF6B9071)), // Color de la etiqueta
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Color(0xFF375534),
                width: 2), // Color de borde al seleccionar
          ),
        ),
        items: ['ACEPTADO', 'RECHAZADO', 'PENDIENTE'].map((estado) {
          return DropdownMenuItem<String>(
            value: estado,
            child: Text(
              estado,
              style: TextStyle(color: Color(0xFF0F2A1D)), // Color del texto
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _estadoSeleccionado = newValue;
          });
        },
      ),
    );
  }

  // Método para crear un campo de texto genérico
  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled, // Define si el campo es editable o no
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Color(0xFF375534)), // Color del texto de la etiqueta
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF375534)), // Color del borde
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Color(
                    0xFF6B9071)), // Color del borde cuando el campo tiene foco
          ),
        ),
      ),
    );
  }
}
