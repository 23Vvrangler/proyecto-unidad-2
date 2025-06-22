// usuario_modelo.dart

/// Modelo para la creación de un nuevo usuario y para recibir los datos completos de un usuario existente.
class UsuarioCreacionModelo {
  final int? id; // Añadido el campo ID. Puede ser nulo si es una creación sin ID aún.
  // Lo hacemos nullable por si se usa para CREAR (donde el ID lo asigna el backend)
  // y para LEER (donde el ID ya existe).
  final String userName;
  final String password;
  final String email;
  final String firstName;
  final String lastName;
  final String dateOfBirth; // Podría ser DateTime si se maneja como objeto de fecha
  final String phoneNumber;
  final String address;
  final String? profilePictureUrl; // Puede ser nulo
  final String? createdAt; // Lo hice nullable por si el backend lo devuelve, pero en creacion no lo enviamos
  final String? updatedAt; // Lo hice nullable por si el backend lo devuelve, pero en creacion no lo enviamos
  final bool? isEnabled;       // Puede ser nulo, ya que el backend podría asignarlo
  final bool? isAccountLocked; // Puede ser nulo
  final String? role;          // Puede ser nulo

  UsuarioCreacionModelo({
    this.id, // Ahora es opcional en el constructor
    required this.userName,
    required this.password,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.address,
    this.profilePictureUrl,
    this.createdAt, // Ahora es opcional
    this.updatedAt, // Ahora es opcional
    this.isEnabled, // Ahora es opcional
    this.isAccountLocked, // Ahora es opcional
    this.role, // Ahora es opcional
  });

  // Factory constructor para crear una instancia desde un JSON (Map)
  factory UsuarioCreacionModelo.fromJson(Map<String, dynamic> json) {
    return UsuarioCreacionModelo(
      id: json['id'] as int?, // Parsear el ID como int o null
      userName: json['userName'] as String,
      password: json['password'] as String, // CUIDADO: Este campo no suele venir en GET de un usuario.
      // Si no lo quieres recibir, hazlo nullable y maneja la ausencia.
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      createdAt: json['createdAt'] as String?, // Parsear como String o null
      updatedAt: json['updatedAt'] as String?, // Parsear como String o null
      isEnabled: json['isEnabled'] as bool?, // Parsear como bool o null
      isAccountLocked: json['isAccountLocked'] as bool?, // Parsear como bool o null
      role: json['role'] as String?, // Parsear como String o null
    );
  }

  // Método para convertir la instancia a un JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // No se suele enviar el ID al backend al crear o actualizar
      'userName': userName,
      'password': password, // CUIDADO: No enviar la contraseña al actualizar si no es el endpoint de cambio de contraseña
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'address': address,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isEnabled': isEnabled,
      'isAccountLocked': isAccountLocked,
      'role': role,
    };
  }
}

/// Modelo para la data de la petición de inicio de sesión.
class LoginRequestModelo {
  final String userName;
  final String password;

  LoginRequestModelo({
    required this.userName,
    required this.password,
  });

  // Método para convertir la instancia a un JSON (Map) para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'password': password,
    };
  }
}

/// Modelo para la data de la respuesta de inicio de sesión.
class LoginResponseModelo {
  final int id;
  final String token;
  final String userName;
  final String role;

  LoginResponseModelo({
    required this.id,
    required this.token,
    required this.userName,
    required this.role,
  });

  // Factory constructor para crear una instancia desde un JSON (Map) recibido del backend
  factory LoginResponseModelo.fromJson(Map<String, dynamic> json) {
    return LoginResponseModelo(
      id: json['id'] as int,
      token: json['token'] as String,
      userName: json['userName'] as String,
      role: json['role'] as String,
    );
  }
}