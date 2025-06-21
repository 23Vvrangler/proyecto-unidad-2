// lib/drawer/main_drawer.dart
import 'package:app_capachica/login/login_user.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Encabezado del Drawer - Más visual
          Container(
            height: 180, // Altura del encabezado
            decoration: BoxDecoration(
              color: Colors.blue[700],
              image: DecorationImage(
                image: const AssetImage('assets/background_drawer.png'), // Asegúrate de que esta ruta sea válida
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.blue[700]!.withOpacity(0.7),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
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
                  const Text(
                    'Nombre de Usuario', // Placeholder
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'usuario@ejemplo.com', // Placeholder
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
          ListTile(
            leading: Icon(Icons.account_circle, color: Colors.blue[700]),
            title: Text(
              'Perfil',
              style: TextStyle(fontSize: 16, color: Colors.blueGrey[800]),
            ),
            onTap: () {
              Navigator.pop(context); // Cierra el drawer
              // Aquí iría la navegación a PerfilScreen()
              // Navigator.push(context, MaterialPageRoute(builder: (context) => PerfilScreen()));
            },
          ),
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
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriasScreen()));
                },
              ),
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
              // Navigator.push(context, MaterialPageRoute(builder: (context) => ReservacionesScreen()));
            },
          ),
          const Divider(height: 20, thickness: 1, indent: 20, endIndent: 20),

          // Botón de Cerrar Sesión con redirección a login_user.dart
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontSize: 16)),
            onTap: () {
              // Cierra el drawer primero
              Navigator.pop(context);
              // Navega a la pantalla de login y elimina todas las rutas anteriores
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginUserScreen()),
                    (Route<dynamic> route) => false, // Elimina todas las rutas de la pila
              );
            },
          ),
        ],
      ),
    );
  }
}