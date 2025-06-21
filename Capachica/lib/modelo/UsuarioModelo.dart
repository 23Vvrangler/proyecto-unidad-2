import 'package:json_annotation/json_annotation.dart';

// IMPORTANT: This 'part' directive is crucial for json_serializable to work.
// It tells build_runner to generate code in 'usuario_modelo.g.dart'
// for all @JsonSerializable classes within this file.
// part 'usuario_modelo.g.dart'; // Uncomment if using json_serializable

/// Modelo para la solicitud de autenticación (inicio de sesión)
/// Este modelo se usa específicamente para enviar userName y password al endpoint de login.
@JsonSerializable() // Keep if using json_serializable
class LoginUsuarioModelo {
  LoginUsuarioModelo({
    required this.userName,
    required this.password,
  });

  final String userName;
  final String password;

  // Constructor manual fromJson (needed if not using json_serializable)
  factory LoginUsuarioModelo.fromJson(Map<String, dynamic> json) {
    return LoginUsuarioModelo(
      userName: json['userName'] ?? '',
      password: json['password'] ?? '',
    );
  }

  // Método manual toJson (needed if not using json_serializable)
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'password': password,
    };
  }
}

/// Modelo para la respuesta de autenticación del login (endpoint /auth/login)
/// Confirmed by your provided login response JSON: contains token, userName, role.
@JsonSerializable() // Keep if using json_serializable
class RespLoginModelo {
  RespLoginModelo({
    required this.token,
    required this.userName,
    required this.role,
  });

  final String token;
  final String userName; // Not null based on response
  final String role;     // Not null based on response

  // Manual fromJson constructor
  factory RespLoginModelo.fromJson(Map<String, dynamic> json) {
    return RespLoginModelo(
      token: json['token'] ?? '',
      userName: json['userName'] ?? '',
      role: json['role'] ?? '',
    );
  }

  // Manual toJson method
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'userName': userName,
      'role': role,
    };
  }
}

/// Modelo para la respuesta de validación del token (endpoint /auth/validate)
/// This should align with RespLoginModelo for consistency.
@JsonSerializable() // Keep if using json_serializable
class RespValidationModelo {
  RespValidationModelo({
    required this.token,
    required this.userName,
    required this.role,
  });

  final String token;
  final String userName;
  final String role;

  // Manual fromJson constructor
  factory RespValidationModelo.fromJson(Map<String, dynamic> json) {
    return RespValidationModelo(
      token: json['token'] ?? '',
      userName: json['userName'] ?? '',
      role: json['role'] ?? '',
    );
  }

  // Manual toJson method
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'userName': userName,
      'role': role,
    };
  }
}

/// Modelo completo para la entidad de usuario (AuthUser en Spring Boot).
/// CORREGIDO Y CONFIRMADO POR LA DATA DE /auth/create.
@JsonSerializable() // Keep if using json_serializable
class UsuarioModeloCompleto {
  UsuarioModeloCompleto({
    this.id, // ID es opcional en la REQUEST (para crear), pero viene en la RESPONSE
    required this.userName,
    this.password, // La contraseña puede no enviarse al actualizar o venir hasheada en response
    required this.email,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth, // Nullable DateTime
    this.phoneNumber, // Nullable String
    this.address,     // Nullable String
    this.profilePictureUrl, // Nullable String
    this.createdAt,   // Nullable DateTime (para request puede ser null, para response viene)
    this.updatedAt,   // Nullable DateTime (para request puede ser null, para response viene)
    this.isEnabled,   // Nullable bool
    this.isAccountLocked, // Nullable bool
    required this.role,
  });

  final int? id; // Nullable para la REQUEST de creación, requerido para la RESPONSE
  final String userName;
  final String? password; // Puede ser null para seguridad o si no se está actualizando
  final String email;
  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final String? address;
  final String? profilePictureUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isEnabled;
  final bool? isAccountLocked;
  final UserRole role; // Use the UserRole enum

  // Manual fromJson constructor: Para deserializar la RESPUESTA
  factory UsuarioModeloCompleto.fromJson(Map<String, dynamic> json) {
    return UsuarioModeloCompleto(
      id: json['id'] as int?, // Puede venir como null o no existir si se usa para otras cosas
      userName: json['userName'] as String,
      password: json['password'] as String?, // La contraseña puede ser hasheada o null
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isEnabled: json['isEnabled'] as bool?,
      isAccountLocked: json['isAccountLocked'] as bool?,
      role: UserRole.values.firstWhere(
            (e) => e.toString().split('.').last == (json['role'] as String).toUpperCase(),
        orElse: () => UserRole.USER, // Default to USER if role is not found
      ),
    );
  }

  // Manual toJson method: Para serializar la REQUEST
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'userName': userName,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.toString().split('.').last, // Convert enum to String (e.g., "USER")
    };

    // Añade campos opcionales o que solo se envían bajo ciertas condiciones
    if (id != null) data['id'] = id; // Si se está actualizando un usuario existente
    if (password != null) data['password'] = password; // Solo si se quiere enviar/actualizar la contraseña
    if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth!.toIso8601String().split('T')[0]; // YYYY-MM-DD
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (address != null) data['address'] = address;
    if (profilePictureUrl != null) data['profilePictureUrl'] = profilePictureUrl;
    // createdAt y updatedAt no suelen enviarse en la request, solo en la response
    // if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String().split('.')[0];
    // if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String().split('.')[0];
    if (isEnabled != null) data['isEnabled'] = isEnabled;
    if (isAccountLocked != null) data['isAccountLocked'] = isAccountLocked;

    return data;
  }
}

// Definición de la enumeración para los roles de usuario.
enum UserRole {
  ADMIN,
  USER,
  // Asegúrate de que estos nombres coincidan con los strings que tu backend envía (ej. "ADMIN", "USER").
}