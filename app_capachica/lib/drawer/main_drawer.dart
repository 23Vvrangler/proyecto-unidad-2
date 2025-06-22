// lib/drawer/main_drawer.dart
import 'package:app_capachica/login/login_user.dart';
import 'package:app_capachica/ui/categoria/main_categoria.dart';
import 'package:app_capachica/ui/lugar/main_lugar.dart';
import 'package:app_capachica/ui/reservacion/main_reservacion.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Para almacenar/recuperar datos
import 'package:app_capachica/apis/usuario_api.dart';         // Para la API de usuarios
import 'package:app_capachica/modelo/UsuarioModelo.dart';    // Para el modelo UsuarioCreacionModelo

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  // Variables para almacenar la información del usuario, con valores por defecto
  // que se mostrarán mientras se carga la información.
  String _userNameDisplay = 'Cargando...';
  String _userEmailDisplay = 'cargando@ejemplo.com';
  // Puedes añadir un URL de imagen de perfil aquí si tu backend lo proporciona:
  // String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Llama a la función para cargar los datos del usuario al inicializar el Drawer
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    // Intenta obtener el ID del usuario guardado en SharedPreferences
    final int? userId = prefs.getInt('userId');
    // Opcional: Obtener un userName guardado para mostrarlo inmediatamente
    final String? storedUserName = prefs.getString('userName');

    // Imprime para depuración: verifica si se recupera el userId
    print('MainDrawer: userId recuperado de SharedPreferences: $userId');
    print('MainDrawer: storedUserName recuperado de SharedPreferences: $storedUserName');


    if (userId != null) {
      // Si tenemos un userId, actualizamos el estado inicial con el nombre guardado
      // y mostramos que estamos cargando el email.
      setState(() {
        _userNameDisplay = storedUserName ?? 'Cargando datos...';
        _userEmailDisplay = 'Cargando correo...';
      });

      try {
        // Instancia tu API de usuario
        final UsuarioApi api = UsuarioApi.create();
        // Realiza la consulta para obtener los detalles completos del usuario por su ID
        final UsuarioCreacionModelo userDetails = await api.getUserById(userId);

        // Una vez que los datos son recibidos, actualiza el estado para reflejarlos en la UI
        setState(() {
          // Si firstName y lastName existen, úsalos; de lo contrario, usa userName.
          _userNameDisplay = userDetails.firstName != null && userDetails.lastName != null
              ? '${userDetails.firstName!} ${userDetails.lastName!}'
              : userDetails.userName;
          _userEmailDisplay = userDetails.email;
          // Si tu modelo tiene profilePictureUrl y quieres mostrarlo:
          // _profilePictureUrl = userDetails.profilePictureUrl;
        });
        print('MainDrawer: Datos de usuario cargados con éxito: Nombre: $_userNameDisplay, Email: $_userEmailDisplay');
      } catch (e) {
        // En caso de error (ej. conexión, ID no encontrado), muestra un mensaje de error.
        print('MainDrawer: Error al cargar datos del usuario desde la API: $e');
        setState(() {
          _userNameDisplay = 'Error al cargar';
          _userEmailDisplay = 'Verifique conexión';
        });
      }
    } else {
      // Si no hay userId en SharedPreferences, el usuario no está logueado.
      setState(() {
        _userNameDisplay = 'Usuario no logueado';
        _userEmailDisplay = ''; // O un placeholder como 'Iniciar Sesión'
      });
      print('MainDrawer: No se encontró userId en SharedPreferences. Usuario no logueado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Encabezado del Drawer
          Container(
            width: double.infinity, // <--- Añadido explícitamente para asegurar que tome todo el ancho disponible
            height: 180, // Altura del encabezado
            decoration: BoxDecoration(
              color: Colors.blue[700],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _userNameDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _userEmailDisplay,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Opciones del menú
          Expanded( // <--- Se envuelve el ListView con Expanded para que ocupe el espacio restante
            child: ListView(
              padding: EdgeInsets.zero, // Importante para que no añada padding extra
              children: [
                ExpansionTile(
                  leading: Icon(Icons.location_on, color: Colors.blue[700]),
                  title: Text(
                    'Lugares',
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey[800]),
                  ),
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 40),
                      title: Text(
                        'Categorías',
                        style: TextStyle(fontSize: 15, color: Colors.blueGrey[700]),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // Aquí iría la navegación a CategoriasScreen()
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MainCategoriaScreen()));
                      },
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 40),
                      title: Text(
                        'Lugares',
                        style: TextStyle(fontSize: 15, color: Colors.blueGrey[700]),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // Aquí iría la navegación a CategoriasScreen()
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MainLugarScreen()));
                      },
                    )
                  ],
                ),
                ListTile(
                  leading: Icon(Icons.book_online, color: Colors.blue[700]),
                  title: Text(
                    'Reservaciones',
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey[800]),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Aquí iría la navegación a ReservacionesScreen()
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MainReservacionScreen()));
                  },
                ),
                const Divider(height: 20, thickness: 1, indent: 20, endIndent: 20),

                // Botón de Cerrar Sesión con redirección a login_user.dart
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontSize: 16)),
                  onTap: () async {
                    // Limpiar todos los datos de sesión de SharedPreferences
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear(); // Esto borra userId, token, userName, etc.

                    // Cierra el drawer
                    Navigator.pop(context);
                    // Navega a la pantalla de login y elimina todas las rutas anteriores de la pila
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginUserScreen()),
                          (Route<dynamic> route) => false, // Elimina todas las rutas
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}