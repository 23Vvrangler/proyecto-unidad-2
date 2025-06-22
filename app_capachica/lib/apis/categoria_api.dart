// Importamos el modelo de CategoriaLugar que acabamos de adaptar
import 'package:app_capachica/modelo/CategoriaLugarModelo.dart';
import 'package:app_capachica/utils/UrlApi.dart'; // Tu clase con la URL base de la API
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:retrofit/retrofit.dart';

// Esta línea es CRUCIAL para que Retrofit genere el código necesario para CategoriaApi.
// Asegúrate de que 'categoria_api.g.dart' exista después de ejecutar:
// 'flutter pub run build_runner build' o 'flutter pub run build_runner watch'.
part 'categoria_api.g.dart'; // Este archivo será generado automáticamente

@RestApi(baseUrl: UrlApi.urlApix) // Usa tu URL base definida en UrlApi.dart
abstract class CategoriaApi {
  // El factory constructor es necesario para que Retrofit genere la implementación.
  factory CategoriaApi(Dio dio, {String baseUrl}) = _CategoriaApi;

  // Método estático para crear una instancia de CategoriaApi con Dio configurado.
  static CategoriaApi create() {
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

    return CategoriaApi(dio);
  }

  // --- Endpoints de la API para CategoriaLugar ---

  /// Realiza una petición POST para crear una nueva categoría de lugar.
  /// Espera un [CategoriaLugarModelo] en el cuerpo y devuelve el [CategoriaLugarModelo] creado.
  /// La implementación de .toJson() en CategoriaLugarModelo se usará para el cuerpo del POST.
  @POST("/categorias-lugar") // Asumiendo este es el endpoint para crear categorías
  Future<CategoriaLugarModelo> createCategoria(@Body() CategoriaLugarModelo categoria);

  @PUT("/categorias-lugar/{id}") // Endpoint para actualizar una categoría por ID
  Future<CategoriaLugarModelo> updateCategoria(@Path("id") int id, @Body() CategoriaLugarModelo categoria);
  /// Realiza una petición GET para obtener una categoría de lugar por su ID.
  /// Espera el [id] en la ruta y devuelve un [CategoriaLugarModelo].
  /// La implementación de .fromJson() en CategoriaLugarModelo se usará para la respuesta.
  @GET("/categorias-lugar/{id}") // Asumiendo este es el endpoint para obtener una categoría por ID
  Future<CategoriaLugarModelo> getCategoriaById(@Path("id") int id);

  /// Realiza una petición GET para obtener todas las categorías de lugar.
  /// Devuelve una lista de [CategoriaLugarModelo].
  /// La implementación de .fromJson() en CategoriaLugarModelo se usará para cada elemento de la lista.
  @GET("/categorias-lugar") // Asumiendo este es el endpoint para obtener todas las categorías
  Future<List<CategoriaLugarModelo>> getAllCategorias();

  /// Realiza una petición DELETE para eliminar una categoría de lugar por su ID.
  /// Espera el [id] en la ruta.
  /// Devuelve Future<void> si la operación es exitosa (ej. el servidor responde 204 No Content).
  @DELETE("/categorias-lugar/{id}") // Asumiendo este es el endpoint para eliminar una categoría por ID
  Future<void> deleteCategoria(@Path("id") int id);
}