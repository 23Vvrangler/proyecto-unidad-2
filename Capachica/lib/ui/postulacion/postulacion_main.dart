import 'package:flutter/material.dart';
import 'package:lb_app/apis/postulacion_api.dart';
import 'package:lb_app/modelo/PostulacionModelo.dart';
import 'package:lb_app/modelo/NotificacionModelo.dart';
import 'package:lb_app/ui/postulacion/postulacion_form_edit.dart';

class PostulacionMain extends StatefulWidget {
  @override
  _PostulacionMainState createState() => _PostulacionMainState();
}

class _PostulacionMainState extends State<PostulacionMain> {
  late PostulacionApi _postulacionApi;
  List<PostulacionModelo> _postulaciones = [];
  List<PostulacionModelo> _postulacionesFiltradas = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _postulacionApi = PostulacionApi.create();
    _fetchPostulaciones();
  }

  Future<void> _fetchPostulaciones() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final postulaciones = await _postulacionApi.listarPostulaciones();
      setState(() {
        _postulaciones = postulaciones;
        _postulacionesFiltradas = postulaciones;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar postulaciones: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _enviarNotificacion(PostulacionModelo postulacion) async {
    final mensajeMap = {
      'PENDIENTE':
          'La postulación de ${postulacion.estudianteDto.nombre} ${postulacion.estudianteDto.apellidoPaterno} ${postulacion.estudianteDto.apellidoMaterno} está pendiente a la oferta ${postulacion.ofertaDto.titulo}.',
      'ACEPTADO':
          '¡Felicidades! La postulación de ${postulacion.estudianteDto.nombre} ${postulacion.estudianteDto.apellidoPaterno} ${postulacion.estudianteDto.apellidoMaterno} ha sido aceptada a la oferta  ${postulacion.ofertaDto.titulo}.',
      'RECHAZADO':
          'Lo sentimos, la postulación de ${postulacion.estudianteDto.nombre} ${postulacion.estudianteDto.apellidoPaterno} ${postulacion.estudianteDto.apellidoMaterno} ha sido rechazada a la oferta ${postulacion.ofertaDto.titulo}.',
    };

    final mensaje =
        mensajeMap[postulacion.estadoPostulacion] ?? 'Estado desconocido';

    final notificacion = NotificacionModelo(
      id: 0,
      mensaje: mensaje,
      fechaEnvio: DateTime.now(),
      estudianteId: postulacion.estudianteDto.id,
      estudianteDto: postulacion.estudianteDto,
    );

    try {
      await _postulacionApi.guardarNotificacion(notificacion);
      setState(() {
        _successMessage = 'Notificación enviada con éxito';
      });
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _successMessage = null;
        });
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al enviar notificación: $e';
      });
    }
  }

  void _filtrarPostulaciones(String query) {
    setState(() {
      _postulacionesFiltradas = _postulaciones
          .where((postulacion) =>
              postulacion.estudianteDto.nombre
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              postulacion.estudianteDto.apellidoPaterno
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget _buildMessage() {
    if (_errorMessage != null) {
      return Text(_errorMessage!, style: TextStyle(color: Colors.red));
    }
    if (_successMessage != null) {
      return Text(_successMessage!, style: TextStyle(color: Colors.green));
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Postulaciones'),
        centerTitle: true,
        backgroundColor: Color(0xFF375534), // Cambié el color aquí
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF0F2A1D), // Cambié el color de la barra de carga
                ),
              ),
            )
          : Column(
              children: [
                _SearchBar(onChanged: _filtrarPostulaciones),
                if (_successMessage != null || _errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildMessage(),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _PostulacionList(
                      postulaciones: _postulacionesFiltradas,
                      onPostulacionUpdated: _fetchPostulaciones,
                      onSendNotification: _enviarNotificacion,
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

class _PostulacionList extends StatelessWidget {
  final List<PostulacionModelo> postulaciones;
  final Function() onPostulacionUpdated;
  final Function(PostulacionModelo) onSendNotification;

  const _PostulacionList({
    required this.postulaciones,
    required this.onPostulacionUpdated,
    required this.onSendNotification,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: postulaciones.length,
      itemBuilder: (context, index) {
        final postulacion = postulaciones[index];
        return _PostulacionListItem(
          postulacion: postulacion,
          onPostulacionUpdated: onPostulacionUpdated,
          onSendNotification: onSendNotification,
        );
      },
    );
  }
}

class _PostulacionListItem extends StatelessWidget {
  final PostulacionModelo postulacion;
  final Function() onPostulacionUpdated;
  final Function(PostulacionModelo) onSendNotification;

  const _PostulacionListItem({
    required this.postulacion,
    required this.onPostulacionUpdated,
    required this.onSendNotification,
  });

  Color _getEstadoColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'ACEPTADO':
        return Colors.green; // Color verde para aceptado
      case 'RECHAZADO':
        return Colors.red; // Color claro para rechazado
      case 'PENDIENTE':
        return Colors.blue; // Color suave para pendiente
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            '${postulacion.estudianteDto.nombre} ${postulacion.estudianteDto.apellidoPaterno} ${postulacion.estudianteDto.apellidoMaterno}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Estado: ', style: TextStyle(color: Colors.grey[700])),
                  Text(
                    postulacion.estadoPostulacion,
                    style: TextStyle(
                      color: _getEstadoColor(postulacion.estadoPostulacion),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text('Oferta: ${postulacion.ofertaDto.titulo}',
                  style: TextStyle(color: Colors.grey[700])),
              Text('Fecha de postulación: ${postulacion.fechaPostulacion}',
                  style: TextStyle(color: Colors.grey[700])),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF375534), // Color verde medio para botones
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.notifications, color: Colors.white),
                  onPressed: () => onSendNotification(postulacion),
                ),
              ),
              SizedBox(width: 8), // Espacio entre botones
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF375534), // Color verde medio para botones
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostulacionFormEdit(
                          postulacion: postulacion,
                          onPostulacionUpdated: onPostulacionUpdated,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}