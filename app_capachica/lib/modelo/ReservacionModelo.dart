class ReservacionModelo {
  // 'id' es generado por el backend y solo se espera en la respuesta.
  final int? id;
  final String nombreClient;
  // Usaremos String para fecha y hora si el backend espera ese formato exacto.
  // Si el backend es flexible, DateTime sería mejor para manejo interno.
  final String fechaReserva; // Formato "DD/MM/YYYY"
  final String horaReserva; // Formato "HH:MM"
  final String numeroPersonas; // Si el backend espera un String (ej. "5 "), lo mantenemos así.
  final String telefono;

  ReservacionModelo({
    this.id,
    required this.nombreClient,
    required this.fechaReserva,
    required this.horaReserva,
    required this.numeroPersonas,
    required this.telefono,
  });

  // --- Método para crear una instancia desde un JSON (Map) ---
  // Se usa para deserializar la respuesta del servidor.
  factory ReservacionModelo.fromJson(Map<String, dynamic> json) {
    return ReservacionModelo(
      id: json['id'] as int?,
      nombreClient: json['nombreClient'] as String,
      fechaReserva: json['fechaReserva'] as String,
      horaReserva: json['horaReserva'] as String,
      numeroPersonas: json['numeroPersonas'] as String,
      telefono: json['telefono'] as String,
    );
  }

  // --- Método para convertir la instancia a un JSON (Map) ---
  // Se usa para serializar la data y enviarla al servidor (ej. para un POST o PUT).
  Map<String, dynamic> toJson() {
    return {
      // 'id' no se suele enviar en el cuerpo de la petición al crear
      'nombreClient': nombreClient,
      'fechaReserva': fechaReserva,
      'horaReserva': horaReserva,
      'numeroPersonas': numeroPersonas,
      'telefono': telefono,
    };
  }

// Opcional: Métodos para convertir entre String y DateTime si lo necesitas
// Esto puede ser útil si quieres trabajar con DateTime internamente y convertir a String para la API.
// DateTime get fechaReservaAsDateTime {
//   final parts = fechaReserva.split('/');
//   return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
// }

// DateTime get horaReservaAsDateTime {
//   final parts = horaReserva.split(':');
//   // Combine con una fecha arbitraria para crear un DateTime completo si solo tienes la hora
//   return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
// }
}