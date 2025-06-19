import 'package:flutter/material.dart';
import 'package:lb_app/modelo/EstudianteModelo.dart';
import 'package:lb_app/apis/estudiante_api.dart';
import 'package:lb_app/ui/estudiante/estudiante_form_edit.dart';

class EstudianteMain extends StatefulWidget {
  @override
  _EstudianteMainState createState() => _EstudianteMainState();
}

class _EstudianteMainState extends State<EstudianteMain> {
  late EstudianteApi apiService;
  List<EstudianteModelo> estudiantes = [];
  List<EstudianteModelo> estudiantesFiltrados = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    apiService = EstudianteApi.create();
    cargarEstudiantes();
  }

  // Método para cargar los estudiantes desde la API
  Future<void> cargarEstudiantes() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await apiService.listarEstudiantes();
      setState(() {
        estudiantes = data;
        estudiantesFiltrados = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error al cargar estudiantes: $e');
    }
  }

  // Método para filtrar la lista de estudiantes según la búsqueda
  void filtrarEstudiantes(String query) {
    setState(() {
      estudiantesFiltrados = estudiantes
          .where((estudiante) =>
              estudiante.nombre.toLowerCase().contains(query.toLowerCase()) ||
              estudiante.apellidoPaterno.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de Estudiantes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF375534), // Usando el primer color
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F2A1D)), // Usando el primer color
              ),
            )
          : Column(
              children: [
                _SearchBar(onChanged: filtrarEstudiantes),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _EstudianteList(
                      estudiantes: estudiantesFiltrados,
                      onEstudianteUpdated: cargarEstudiantes, // Callback para refrescar la lista
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final Function(String) onChanged;

  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Buscar estudiante...',
          prefixIcon: Icon(Icons.search, color: Color(0xFF375534)), // Usando el segundo color
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF375534)), // Usando el segundo color
          ),
        ),
      ),
    );
  }
}

class _EstudianteList extends StatelessWidget {
  final List<EstudianteModelo> estudiantes;
  final Function() onEstudianteUpdated;

  const _EstudianteList({
    required this.estudiantes,
    required this.onEstudianteUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: estudiantes.length,
      itemBuilder: (context, index) {
        final estudiante = estudiantes[index];
        return _EstudianteListItem(
          estudiante: estudiante,
          onEstudianteUpdated: onEstudianteUpdated, // Pasamos el callback
        );
      },
    );
  }
}

class _EstudianteListItem extends StatelessWidget {
  final EstudianteModelo estudiante;
  final Function() onEstudianteUpdated;

  const _EstudianteListItem({
    required this.estudiante,
    required this.onEstudianteUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            '${estudiante.nombre} ${estudiante.apellidoPaterno} ${estudiante.apellidoMaterno}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF375534), // Usando el segundo color
            ),
          ),
          subtitle: Text(
            'Horas Pract.: ${estudiante.horasCompletadas}',
            style: TextStyle(color: Color(0xFF375534)), // Usando el tercer color
          ),
          trailing: Container(
            decoration: BoxDecoration(
              color: Color(0xFF375534), // Usando el segundo color
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.edit, color: Color(0xFFE3EED4)), // Usando el último color
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EstudianteFormEdit(
                      estudiante: estudiante,
                      onEstudianteUpdated: onEstudianteUpdated, // Pasamos el callback
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}