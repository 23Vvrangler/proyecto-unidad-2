import 'package:app_capachica/modelo/ReservacionModelo.dart';
import 'package:app_capachica/utils/UrlApi.dart';        // Tu clase con la URL base de la API
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:retrofit/retrofit.dart';

// Esta línea es crucial para que Retrofit genere el código necesario.
// Asegúrate de que 'reservacion_api.g.dart' exista después de ejecutar:
// 'flutter pub run build_runner build' o 'flutter pub run build_runner watch'.
part 'reservacion_api.g.dart'; // Este archivo será generado automáticamente

@RestApi(baseUrl: UrlApi.urlApix) // Usa tu URL base definida en UrlApi.dart
abstract class ReservacionApi {
  // El factory constructor es necesario para que Retrofit genere la implementación.
  factory ReservacionApi(Dio dio, {String baseUrl}) = _ReservacionApi;

  // Método estático para crear una instancia de ReservacionApi con Dio configurado.
  static ReservacionApi create() {
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

    return ReservacionApi(dio);
  }

  // --- Endpoints de la API para Reservacion ---


  @POST("/reservas") // Asumiendo este es el endpoint para crear reservaciones
  Future<ReservacionModelo> createReservacion(@Body() ReservacionModelo reservacion);

  @GET("/reservas/{id}") // Asumiendo este es el endpoint para obtener una reservación por ID
  Future<ReservacionModelo> getReservacionById(@Path("id") int id);

  @GET("/reservas") // Asumiendo este es el endpoint para obtener todas las reservaciones
  Future<List<ReservacionModelo>> getAllReservaciones();

  @PUT("/reservas/{id}") // Asumiendo este es el endpoint para actualizar una reservación por ID
  Future<ReservacionModelo> updateReservacion(@Path("id") int id, @Body() ReservacionModelo reservacion);

  @DELETE("/reservas/{id}") // Asumiendo este es el endpoint para eliminar una reservación por ID
  Future<void> deleteReservacion(@Path("id") int id);
}