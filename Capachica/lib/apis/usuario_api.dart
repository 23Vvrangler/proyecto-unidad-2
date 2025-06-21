
import 'package:app_capac/modelo/UsuarioModelo.dart';
import 'package:app_capac/util/UrlApi.dart';
import 'package:dio/dio.dart';

import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:retrofit/retrofit.dart';

// Esta línea es CRUCIAL para que Retrofit genere el código necesario.
// Asegúrate de que 'usuario_api.g.dart' exista después de ejecutar
// 'flutter pub run build_runner build' o 'flutter pub run build_runner watch'.
part 'usuario_api.g.dart';

@RestApi(baseUrl: UrlApi.urlApix)
abstract class UsuarioApi {
  factory UsuarioApi(Dio dio, {String baseUrl}) = _UsuarioApi;

  static UsuarioApi create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: UrlApi.urlApix,
        connectTimeout: const Duration(milliseconds: 30000),
        receiveTimeout: const Duration(milliseconds: 30000),
      ),
    );

    // Añade el interceptor PrettyDioLogger para ver los logs detallados de la petición y la respuesta.
    // Esto es CLAVE para la depuración del problema actual de no ver la respuesta.
    dio.interceptors.add(PrettyDioLogger(
        requestHeader: true, // Muestra los encabezados de la petición
        requestBody: true,   // Muestra el cuerpo de la petición
        responseHeader: true,// Muestra los encabezados de la respuesta
        responseBody: true,  // Muestra el cuerpo de la respuesta
        error: true,         // Muestra los errores
        compact: false,      // Formatea el JSON para una mejor lectura
        maxWidth: 90         // Limita el ancho de la línea de logs
    ));

    return UsuarioApi(dio);
  }


  @POST("/auth/login")
  Future<RespLoginModelo> login(@Body() LoginUsuarioModelo usuario);



  @POST("/auth/create")
  Future<UsuarioModeloCompleto> registerUsuario(@Body() UsuarioModeloCompleto usuario);


}