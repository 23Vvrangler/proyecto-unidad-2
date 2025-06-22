import 'package:app_capachica/modelo/LugarModelo.dart';

import 'package:app_capachica/utils/UrlApi.dart';        // Tu clase con la URL base de la API
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:retrofit/retrofit.dart';

// Esta línea es crucial para que Retrofit genere el código necesario.
// Asegúrate de que 'lugar_api.g.dart' exista después de ejecutar:
// 'flutter pub run build_runner build' o 'flutter pub run build_runner watch'.
part 'lugar_api.g.dart'; // Este archivo será generado automáticamente

@RestApi(baseUrl: UrlApi.urlApix) // Usa tu URL base definida en UrlApi.dart
abstract class LugarApi {
  // El factory constructor es necesario para que Retrofit genere la implementación.
  factory LugarApi(Dio dio, {String baseUrl}) = _LugarApi;

  // Método estático para crear una instancia de LugarApi con Dio configurado.
  static LugarApi create() {
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

    return LugarApi(dio);
  }

  // --- Endpoints de la API para Lugar ---

  /// Realiza una petición POST para crear un nuevo lugar.
  /// Espera un [LugarModelo] en el cuerpo y devuelve el [LugarModelo] creado.
  /// La implementación de `.toJson()` en [LugarModelo] se usará para el cuerpo del POST.
  @POST("/lugares") // Asumiendo este es el endpoint para crear lugares
  Future<LugarModelo> createLugar(@Body() LugarModelo lugar);

  /// Realiza una petición GET para obtener un lugar por su ID.
  /// Espera el [id] en la ruta y devuelve un [LugarModelo].
  /// La implementación de `.fromJson()` en [LugarModelo] se usará para la respuesta.
  @GET("/lugares/{id}") // Asumiendo este es el endpoint para obtener un lugar por ID
  Future<LugarModelo> getLugarById(@Path("id") int id);

  /// Realiza una petición GET para obtener todos los lugares.
  /// Devuelve una lista de [LugarModelo].
  /// La implementación de `.fromJson()` en [LugarModelo] se usará para cada elemento de la lista.
  @GET("/lugares") // Asumiendo este es el endpoint para obtener todos los lugares
  Future<List<LugarModelo>> getAllLugares();

  /// Realiza una petición PUT para actualizar un lugar existente por su ID.
  /// Espera el [id] en la ruta y un [LugarModelo] en el cuerpo con los datos actualizados.
  /// Devuelve el [LugarModelo] actualizado.
  /// La implementación de `.toJson()` se usará para el cuerpo del PUT.
  @PUT("/lugares/{id}") // Asumiendo este es el endpoint para actualizar un lugar por ID
  Future<LugarModelo> updateLugar(@Path("id") int id, @Body() LugarModelo lugar);

  /// Realiza una petición DELETE para eliminar un lugar por su ID.
  /// Espera el [id] en la ruta.
  /// Devuelve [Future<void>] si la operación es exitosa (ej. el servidor responde 204 No Content).
  @DELETE("/lugares/{id}") // Asumiendo este es el endpoint para eliminar un lugar por ID
  Future<void> deleteLugar(@Path("id") int id);
}