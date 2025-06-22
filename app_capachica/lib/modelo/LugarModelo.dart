import 'package:app_capachica/modelo/CategoriaLugarModelo.dart';

class LugarModelo {
  // Campos para la respuesta (vienen del servidor, opcionales para la solicitud inicial)
  final int? id; // El ID lo asigna el backend
  final DateTime? creadoEn;
  final DateTime? actualizadoEn;

  // Campos que se envían en la solicitud y se reciben en la respuesta
  final String nombre;
  final String? descripcion; // Puede ser opcional en la solicitud
  final String direccion;
  final String? numeroTelefono; // Puede ser opcional en la solicitud
  final double? calificacionPromedio; // Usamos double para valores con decimales

  // La categoría asociada a este lugar.
  // En la solicitud (POST), podrías enviar un CategoriaLugarModelo con solo 'id' y 'nombre'.
  // En la respuesta (GET), se espera un CategoriaLugarModelo completo.
  final CategoriaLugarModelo categoria;

  LugarModelo({
    this.id,
    required this.nombre,
    this.descripcion,
    required this.direccion,
    this.numeroTelefono,
    this.calificacionPromedio,
    this.creadoEn,
    this.actualizadoEn,
    required this.categoria,
  });

  // --- Método para crear una instancia desde un JSON (Map) ---
  // Se usa para deserializar la respuesta del servidor.
  factory LugarModelo.fromJson(Map<String, dynamic> json) {
    return LugarModelo(
      id: json['id'] as int?,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      direccion: json['direccion'] as String,
      numeroTelefono: json['numeroTelefono'] as String?,
      calificacionPromedio: (json['calificacionPromedio'] as num?)?.toDouble(), // 'num' para int o double, luego toDouble
      // Parsear fechas de String a DateTime, manejando null
      creadoEn: json['creadoEn'] != null
          ? DateTime.parse(json['creadoEn'] as String)
          : null,
      actualizadoEn: json['actualizadoEn'] != null
          ? DateTime.parse(json['actualizadoEn'] as String)
          : null,
      // Deserializar la categoría anidada usando su propio fromJson
      categoria: CategoriaLugarModelo.fromJson(json['categoria'] as Map<String, dynamic>),
    );
  }

  // --- Método para convertir la instancia a un JSON (Map) ---
  // Se usa para serializar la data y enviarla al servidor (ej. para un POST o PUT).
  Map<String, dynamic> toJson() {
    return {
      // 'id' no se suele enviar en el cuerpo de la petición al crear
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'numeroTelefono': numeroTelefono,
      'calificacionPromedio': calificacionPromedio,
      // 'creadoEn' y 'actualizadoEn' son manejados por el backend

      // Serializar la categoría anidada usando su propio toJson
      // Para la creación de un Lugar, a menudo solo se espera el ID de la categoría.
      // Sin embargo, si tu backend espera el objeto completo (con nombre), se enviará.
      'categoria': categoria.toJson(),
    };
  }
}