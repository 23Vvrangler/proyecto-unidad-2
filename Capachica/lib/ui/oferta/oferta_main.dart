import 'package:flutter/material.dart';
import 'package:lb_app/apis/oferta_api.dart';
import 'package:lb_app/modelo/OfertaModelo.dart';
import 'package:lb_app/ui/oferta/oferta_form_create.dart';
import 'package:lb_app/ui/oferta/oferta_form_edit.dart';

class OfertaMain extends StatefulWidget {
  @override
  _OfertaMainState createState() => _OfertaMainState();
}

class _OfertaMainState extends State<OfertaMain> {
  late OfertaApi _ofertaApi;
  List<OfertaModelo> _ofertas = [];
  List<OfertaModelo> _ofertasFiltradas = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _ofertaApi = OfertaApi.create();
    _fetchOfertas();
  }

  Future<void> _fetchOfertas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ofertas = await _ofertaApi.listarOferta();
      setState(() {
        _ofertas = ofertas;
        _ofertasFiltradas = ofertas;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar ofertas: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filtrarOfertas(String query) {
    setState(() {
      _ofertasFiltradas = _ofertas
          .where((oferta) =>
              oferta.titulo.toLowerCase().contains(query.toLowerCase()) ||
              oferta.descripcion.toLowerCase().contains(query.toLowerCase()))
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

  void _navigateToCreateOferta() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfertaFormCreate(
          onOfertaCreated: _fetchOfertas,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Ofertas'),
        centerTitle: true,
        backgroundColor: Color(0xFF375534),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F2A1D)),
              ),
            )
          : Column(
              children: [
                _SearchBar(onChanged: _filtrarOfertas),
                if (_successMessage != null || _errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildMessage(),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _OfertaList(
                      ofertas: _ofertasFiltradas,
                      onOfertaUpdated: _fetchOfertas,
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateOferta,
        backgroundColor: Color(0xFF375534),
        child: Icon(Icons.add, color: Colors.white),
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
          hintText: 'Buscar oferta...',
          prefixIcon: Icon(Icons.search, color: Color(0xFF375534)),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF375534)),
          ),
        ),
      ),
    );
  }
}

class _OfertaList extends StatelessWidget {
  final List<OfertaModelo> ofertas;
  final Function() onOfertaUpdated;

  const _OfertaList({required this.ofertas, required this.onOfertaUpdated});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: ofertas.length,
      itemBuilder: (context, index) {
        final oferta = ofertas[index];
        return _OfertaListItem(
          oferta: oferta,
          onOfertaUpdated: onOfertaUpdated,
        );
      },
    );
  }
}

class _OfertaListItem extends StatelessWidget {
  final OfertaModelo oferta;
  final Function() onOfertaUpdated;

  const _OfertaListItem({required this.oferta, required this.onOfertaUpdated});

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
            oferta.titulo,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Descripción: ${oferta.descripcion}',
                  style: TextStyle(color: Colors.grey[700])),
              Text('Ubicación: ${oferta.ubicacion}',
                  style: TextStyle(color: Colors.grey[700])),
              Text('Duración: ${oferta.duracion}',
                  style: TextStyle(color: Colors.grey[700])),
            ],
          ),
          trailing: Container(
            decoration: BoxDecoration(
              color: Color(0xFF375534),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                // Aquí podrías navegar a un formulario para editar la oferta
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => OfertaFormEdit(
                      oferta: oferta,
                      onOfertaUpdated: onOfertaUpdated,
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