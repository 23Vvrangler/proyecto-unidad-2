// usuario_modelo.dart

/// Modelo para la creación de un nuevo usuario.
/// Se usa tanto para enviar la información al backend como para recibir la respuesta,
/// ya que la estructura es la misma.
class UsuarioCreacionModelo {
  final String userName;
  final String password;
  final String email;
  final String firstName;
  final String lastName;
  final String dateOfBirth; // Podría ser DateTime si se maneja como objeto de fecha
  final String phoneNumber;
  final String address;
  final String? profilePictureUrl; // Puede ser nulo
  final String createdAt; // Podría ser DateTime
  final String updatedAt; // Podría ser DateTime
  final bool isEnabled;
  final bool isAccountLocked;
  final String role;

  UsuarioCreacionModelo({
    required this.userName,
    required this.password,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.address,
    this.profilePictureUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isEnabled,
    required this.isAccountLocked,
    required this.role,
  });

  // Factory constructor para crear una instancia desde un JSON (Map)
  factory UsuarioCreacionModelo.fromJson(Map<String, dynamic> json) {
    return UsuarioCreacionModelo(
      userName: json['userName'] as String,
      password: json['password'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      isEnabled: json['isEnabled'] as bool,
      isAccountLocked: json['isAccountLocked'] as bool,
      role: json['role'] as String,
    );
  }

  // Método para convertir la instancia a un JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'password': password,
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
  final String token;
  final String userName;
  final String role;

  LoginResponseModelo({
    required this.token,
    required this.userName,
    required this.role,
  });

  // Factory constructor para crear una instancia desde un JSON (Map) recibido del backend
  factory LoginResponseModelo.fromJson(Map<String, dynamic> json) {
    return LoginResponseModelo(
      token: json['token'] as String,
      userName: json['userName'] as String,
      role: json['role'] as String,
    );
  }
}