class CategoriaLugarModelo {
  // Campos que vienen en la RESPUESTA del servidor (opcionales para la SOLICITUD de creación)
  final int? id; // 'id' es nulo al crear, pero viene en la respuesta
  final DateTime? creadoEn; // 'creadoEn' es nulo al crear, pero viene en la respuesta

  // La lista de lugares: se mantiene como List<dynamic>
  final List<dynamic>? lugares; // 'lugares' es nulo/vacío al crear, pero viene en la respuesta

  // Estos campos se envían en la SOLICITUD para crear una categoría,
  // y también se incluyen en la respuesta del servidor.
  final String nombre;
  final String? urlImagen; // 'urlImagen' puede ser null

  CategoriaLugarModelo({
    this.id,
    required this.nombre,
    this.urlImagen, // Puede ser nulo
    this.creadoEn,
    this.lugares,
  });

  // Factory constructor para deserializar desde un mapa JSON (respuesta del servidor)
  factory CategoriaLugarModelo.fromJson(Map<String, dynamic> json) {
    return CategoriaLugarModelo(
      id: json['id'] as int?,
      nombre: json['nombre'] as String,
      urlImagen: json['urlImagen'] as String?, // Se parsea como String o null
      // Parseamos 'creadoEn' de String a DateTime, manejando null
      creadoEn: json['creadoEn'] != null
          ? DateTime.parse(json['creadoEn'] as String)
          : null,
      // Se parsea 'lugares' como List<dynamic> o null si no existe
      lugares: json['lugares'] as List<dynamic>?,
    );
  }

  // Método para serializar a un mapa JSON (para enviar al servidor)
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      // Incluimos urlImagen solo si no es nulo, o siempre si tu API lo espera
      'urlImagen': urlImagen,
      // id, creadoEn, y lugares no se suelen enviar al crear o actualizar,
      // ya que son manejados por el servidor o son solo para lectura.
    };
  }
}