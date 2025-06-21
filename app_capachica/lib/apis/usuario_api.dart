// lib/apis/usuario_api.dart

import 'package:app_capachica/modelo/UsuarioModelo.dart';
import 'package:app_capachica/utils/UrlApi.dart';               // Tu clase con la URL base de la API
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:retrofit/retrofit.dart';

// Esta línea es CRUCIAL para que Retrofit genere el código necesario.
// Asegúrate de que 'usuario_api.g.dart' exista después de ejecutar:
// 'flutter pub run build_runner build' o 'flutter pub run build_runner watch'.
part 'usuario_api.g.dart'; // Este archivo será generado automáticamente

@RestApi(baseUrl: UrlApi.urlApix) // Usa tu URL base definida en UrlApi.dart
abstract class UsuarioApi {
  // El factory constructor es necesario para que Retrofit genere la implementación.
  factory UsuarioApi(Dio dio, {String baseUrl}) = _UsuarioApi;

  // Método estático para crear una instancia de UsuarioApi con Dio configurado.
  static UsuarioApi create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: UrlApi.urlApix,
        // Aumentamos los tiempos de espera a 60 segundos para dar más margen
        connectTimeout: const Duration(milliseconds: 60000), // 60 segundos para establecer la conexión
        receiveTimeout: const Duration(milliseconds: 60000), // 60 segundos para recibir la respuesta
        sendTimeout: const Duration(milliseconds: 60000), // Opcional: tiempo para enviar el request
      ),
    );

    // Añade el interceptor PrettyDioLogger para ver los logs detallados
    // de la petición y la respuesta en la consola durante la depuración.
    dio.interceptors.add(PrettyDioLogger(
        requestHeader: true, // Muestra los encabezados de la petición
        requestBody: true,   // Muestra el cuerpo de la petición (JSON enviado)
        responseHeader: true,// Muestra los encabezados de la respuesta
        responseBody: true,  // Muestra el cuerpo de la respuesta (JSON recibido)
        error: true,         // Muestra los errores de la petición
        compact: false,      // Formatea el JSON para una mejor lectura
        maxWidth: 90         // Limita el ancho de la línea de logs
    ));

    return UsuarioApi(dio);
  }

  // --- Endpoints de la API ---

  /// Realiza una petición POST para iniciar sesión.
  /// Espera un [LoginRequestModelo] en el cuerpo y devuelve un [LoginResponseModelo].
  @POST("/auth/login")
  Future<LoginResponseModelo> login(@Body() LoginRequestModelo usuario);


  /// Realiza una petición POST para registrar un nuevo usuario.
  /// Espera un [UsuarioCreacionModelo] en el cuerpo.
  /// Se asume que la respuesta también puede ser un [UsuarioCreacionModelo] o similar
  /// confirmando la creación. Si tu backend devuelve algo diferente (ej. solo un ID),
  /// deberías usar un modelo de respuesta específico.
  @POST("/auth/create")
  Future<UsuarioCreacionModelo> registerUsuario(@Body() UsuarioCreacionModelo usuario);

}