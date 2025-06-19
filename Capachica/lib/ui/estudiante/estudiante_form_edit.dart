import 'package:flutter/material.dart';
import 'package:lb_app/modelo/EstudianteModelo.dart';
import 'package:lb_app/apis/estudiante_api.dart';

class EstudianteFormEdit extends StatefulWidget {
  final EstudianteModelo estudiante;
  final Function() onEstudianteUpdated;

  EstudianteFormEdit({
    required this.estudiante,
    required this.onEstudianteUpdated,
  });

  @override
  _EstudianteFormEditState createState() => _EstudianteFormEditState();
}

class _EstudianteFormEditState extends State<EstudianteFormEdit> {
  // Controladores para los campos de texto
  late TextEditingController _nombreController;
  late TextEditingController _apellidoPaternoController;
  late TextEditingController _apellidoMaternoController;
  late TextEditingController _dniController;
  late TextEditingController _carreraController;
  late TextEditingController _universidadController;
  late TextEditingController _habilidadesController;
  late TextEditingController _horasCompletadasController;

  late EstudianteApi apiService;

  @override
  void initState() {
    super.initState();
    apiService = EstudianteApi.create();

    // Inicializar los controladores con los valores actuales del estudiante
    _nombreController = TextEditingController(text: widget.estudiante.nombre);
    _apellidoPaternoController =
        TextEditingController(text: widget.estudiante.apellidoPaterno);
    _apellidoMaternoController =
        TextEditingController(text: widget.estudiante.apellidoMaterno);
    _dniController =
        TextEditingController(text: widget.estudiante.dni.toString());
    _carreraController = TextEditingController(text: widget.estudiante.carrera);
    _universidadController =
        TextEditingController(text: widget.estudiante.universidad);
    _habilidadesController =
        TextEditingController(text: widget.estudiante.habilidades);
    _horasCompletadasController =
        TextEditingController(text: widget.estudiante.horasCompletadas);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _dniController.dispose();
    _carreraController.dispose();
    _habilidadesController.dispose();
    _horasCompletadasController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    final updatedEstudiante = EstudianteModelo(
      id: widget.estudiante.id,
      nombre: widget.estudiante.nombre,
      apellidoPaterno: widget.estudiante.apellidoPaterno,
      apellidoMaterno: widget.estudiante.apellidoMaterno,
      dni: widget.estudiante.dni,
      carrera: widget.estudiante.carrera,
      universidad: widget.estudiante.universidad,
      habilidades: widget.estudiante.habilidades,
      horasCompletadas: _horasCompletadasController.text,
      authUserId: widget.estudiante.authUserId,
      authUserDto: widget.estudiante.authUserDto,
    );

    try {
      await apiService.editarEstudiante(updatedEstudiante);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estudiante actualizado con éxito')),
      );
      widget
          .onEstudianteUpdated(); // Llamamos al callback para actualizar la lista
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar estudiante: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Estudiante'),
        backgroundColor: Color(0xFF375534), // Color de fondo del AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Nombre', _nombreController, enabled: false),
              _buildTextField('Apellido Paterno', _apellidoPaternoController,
                  enabled: false),
              _buildTextField('Apellido Materno', _apellidoMaternoController,
                  enabled: false),
              _buildTextField('DNI', _dniController,
                  keyboardType: TextInputType.number, enabled: false),
              _buildTextField('Carrera', _carreraController, enabled: false),
              _buildTextField('Universidad', _universidadController,
                  enabled: false),
              _buildTextField('Habilidades', _habilidadesController,
                  enabled: false),
              _buildTextField('Horas Completadas',
                  _horasCompletadasController), // Este campo está habilitado
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarCambios,
                child: Text('Guardar Cambios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color(0xFF375534), // Fondo del botón con el segundo color
                  foregroundColor:
                      Color(0xFFE3EED4), // Color del texto del botón
                ),
              ),
            ],
          ),
        ),
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
