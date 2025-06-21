// login/login_user.dart
import 'package:app_capac/apis/usuario_api.dart';
import 'package:app_capac/comp/Button.dart';
import 'package:app_capac/drawer/navigation_home_screen.dart';
import 'package:app_capac/drawuser/navegation_user_screen.dart';
import 'package:app_capac/modelo/UsuarioModelo.dart';
import 'package:app_capac/util/TokenUtil.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Clase de utilidad para URLs, no necesita ser instanciada.
// Contiene la URL base de tu API.
class UrlApi {
  static const String urlApix = "http://192.168.0.181:8080"; // Reemplaza con tu URL real
}


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerUser = TextEditingController();
  final TextEditingController _controllerPass = TextEditingController();
  bool passwordVisible = true;

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
  }

  // --- Métodos de autenticación y validación ---

  // Realiza la solicitud de login. Esperamos userName y role directamente aquí.
  // Este método llama a tu UsuarioApi.create().login().
  Future<RespLoginModelo?> performLoginRequest(String userName, String password) async {
    final api = UsuarioApi.create(); // Crea la instancia de Dio con PrettyDioLogger
    try {
      final loginRequest = LoginUsuarioModelo(userName: userName, password: password);
      print("Datos de login enviados: ${loginRequest.toJson()}");
      final respLogin = await api.login(loginRequest);
      // ESTA ES LA LÍNEA CRÍTICA: SI NO VES "Respuesta de login recibida" en tus logs,
      // EL PROBLEMA ES DE CONECTIVIDAD O DEL BACKEND, NO DE ESTE CÓDIGO.
      print("Respuesta de login recibida: ${respLogin.toJson()}");
      return respLogin;
    } on DioException catch (e) {
      _handleDioError(e, "login"); // Manejo detallado de errores de red/HTTP
      return null;
    } catch (e) {
      _handleGenericError(e, "performLoginRequest"); // Manejo de otros errores inesperados
      return null;
    }
  }

  // --- Manejo de errores detallado ---
  void _handleDioError(DioException e, String contextMessage) {
    if (!mounted) return; // Asegura que el widget todavía está montado
    String message;
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout) {
      message = "Error de conexión: tiempo de espera excedido. Verifica tu conexión a Internet o la disponibilidad del servidor.";
    } else if (e.response != null) {
      // Errores de respuesta HTTP (4xx, 5xx)
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        message = "Credenciales incorrectas o acceso no autorizado. Intenta de nuevo.";
      } else {
        // Intenta obtener un mensaje más específico si el backend lo proporciona
        String? backendErrorMessage = e.response?.data is Map ? (e.response?.data['message'] as String?) : null;
        message = "Error ${e.response?.statusCode}: ${backendErrorMessage ?? 'Error desconocido del servidor'}";
      }
      print("Error de respuesta HTTP en $contextMessage: ${e.response?.statusCode} - ${e.response?.data}");
    } else if (e.type == DioExceptionType.badCertificate) {
      message = "Error de certificado SSL/TLS. Contacta al administrador.";
    } else if (e.type == DioExceptionType.unknown) {
      message = "Error de red desconocido. Puede que no tengas conexión a internet o el servidor esté inaccesible.";
      print("Error de red desconocido en $contextMessage: ${e.message}");
    }
    else {
      // Otros tipos de errores Dio (cancelación, etc.)
      message = "Ocurrió un error inesperado durante la comunicación: ${e.message}";
      print("Error Dio inesperado en $contextMessage: ${e.type} - ${e.message}");
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleGenericError(dynamic e, String contextMessage) {
    print("Error inesperado en $contextMessage: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ocurrió un error inesperado. Por favor, intenta de nuevo.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFE3EED4), // Color de fondo claro
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset("assets/imagen/Logo_LB.png", height: 180.0), // Tu logo
                const SizedBox(height: 20),
                const Text(
                  "CAPACHICA", // Nombre de tu aplicación
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F2A1D), // Color oscuro para el texto
                  ),
                ),
                const SizedBox(height: 20),
                _buildForm(), // El formulario de login
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Form _buildForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _controllerUser,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: "Usuario",
                labelText: "Usuario",
                helperText: "Introduce tu usuario",
                helperStyle:
                TextStyle(color: Color(0xFF375534)), // Color para el texto de ayuda
              ),
              validator: (value) =>
              value!.isEmpty ? 'Ingresa tu nombre de usuario' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controllerPass,
              obscureText: passwordVisible, // Oculta/muestra la contraseña
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: "Contraseña",
                labelText: "Contraseña",
                helperText: "Introduce tu contraseña",
                helperStyle:
                const TextStyle(color: Color(0xFF375534)), // Color para el texto de ayuda
                suffixIcon: IconButton(
                  icon: Icon(passwordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  color: const Color(0xFF6B9071), // Color del icono
                  onPressed: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                ),
              ),
              validator: (value) =>
              value!.isEmpty ? 'Ingresa tu contraseña' : null,
            ),
            const SizedBox(height: 24),
            Button(
              label: 'Ingresar',
              onTap: () async {
                if (_formKey.currentState!.validate()) {
                  // Muestra un indicador de carga si lo deseas, antes de la llamada a la API
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text("Iniciando sesión..."), duration: Duration(seconds: 1)),
                  // );

                  // Realiza la solicitud de login. Ahora esperamos el token, userName y role.
                  final loginResponse = await performLoginRequest(
                    _controllerUser.text,
                    _controllerPass.text,
                  );

                  // Verificamos si la respuesta del login contiene todos los datos necesarios
                  if (loginResponse != null &&
                      loginResponse.token.isNotEmpty &&
                      loginResponse.userName.isNotEmpty &&
                      loginResponse.role.isNotEmpty) {

                    final prefs = await SharedPreferences.getInstance();
                    // Guarda el token (con "Bearer "), rol y userName en SharedPreferences
                    await prefs.setString("token", "Bearer ${loginResponse.token}");
                    await prefs.setString("role", loginResponse.role);
                    await prefs.setString("userName", loginResponse.userName);

                    // Actualiza TokenUtil con los datos del usuario logueado para uso global
                    TokenUtil.TOKEN = "Bearer ${loginResponse.token}";
                    TokenUtil.role = loginResponse.role;
                    TokenUtil.userName = loginResponse.userName;
                    TokenUtil.localx = false; // Indica que ahora hay un token válido y no es una sesión local de prueba

                    // Redirige directamente según el rol obtenido de la respuesta de login
                    if (mounted) { // Asegura que el contexto sigue siendo válido
                      if (loginResponse.role == 'ADMIN') { // Usa 'ADMIN' o el string exacto que tu API devuelve para el administrador
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            // Si NavigationHomeScreen requiere onThemeChanged, DEBES pasarlo aquí.
                            // Si no lo requiere, simplemente déjalo como NavigationHomeScreen().
                            // Si NavigationHomeScreen necesita el callback para el tema global,
                            // pero el login no tiene acceso a él, es un problema de arquitectura.
                            // La solución más simple para el login es que NavigationHomeScreen no lo requiera.
                            builder: (context) => NavigationHomeScreen(
                              // Si NavigationHomeScreen AÚN REQUIERE onThemeChanged, y no tienes una función real,
                              // como último recurso (no ideal para la gestión de tema global), pasa una función vacía:
                              onThemeChanged: () {
                                print("NavigationHomeScreen: onThemeChanged llamado (desde LoginPage, sin efecto real en el tema global)");
                              },
                            ),
                          ),
                        );
                      } else if (loginResponse.role == 'USER') { // Usa 'USER' o el string exacto que tu API devuelve para el usuario normal
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            // Similar a NavigationHomeScreen, si NavigationUserScreen requiere onThemeChanged.
                            builder: (context) => NavigationUserScreen(
                              onThemeChanged: () {
                                print("NavigationUserScreen: onThemeChanged llamado (desde LoginPage, sin efecto real en el tema global)");
                              },
                            ),
                          ),
                        );
                      } else {
                        // Rol no reconocido, muestra un mensaje de error.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Acceso denegado: rol de usuario no reconocido por la aplicación.")),
                        );
                      }
                    }
                  } else {
                    // Si el login inicial falla o los datos están incompletos
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Credenciales incorrectas o error en el inicio de sesión. Verifique sus datos.")),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}