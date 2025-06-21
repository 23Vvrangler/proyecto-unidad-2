import 'package:app_capac/comp/CustomAppBar.dart';
import 'package:app_capac/drawer/drawer_user_controller.dart';
import 'package:app_capac/drawer/home_drawer.dart'; // Asegúrate que DrawerIndex está definido aquí
// import 'package:capachica/theme/AppTheme.dart'; // No se está usando directamente, Theme.of(context) es suficiente
import 'package:app_capac/ui/categorialugar/categoria_main.dart';
import 'package:app_capac/ui/help_screen.dart';
import 'package:app_capac/ui/lugares/lugares_main.dart';
import 'package:app_capac/ui/reservaciones/reservaciones_main.dart'; // Asegúrate que esta ruta es correcta y que la clase es ReservacionesMain

import 'package:flutter/material.dart';

class NavigationHomeScreen extends StatefulWidget {
  // Mantienes 'onThemeChanged' aquí porque es donde se gestiona el cambio de tema.
  // Será responsabilidad de `main.dart` (o el widget que instancie NavigationHomeScreen)
  // pasar este callback.
  final VoidCallback onThemeChanged;

  const NavigationHomeScreen({super.key, required this.onThemeChanged});

  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  Widget? screenView;
  DrawerIndex? drawerIndex;

  @override
  void initState() {
    drawerIndex = DrawerIndex.HOME;
    screenView = const HelpScreen(); // Usar const si el widget no cambia su estado
    super.initState();
  }

  // Este método será llamado por CustomAppBar para notificar cambios de tema
  void _handleAppBarThemeChange() {
    // Llama al callback proporcionado por el widget padre (main.dart)
    // para que el MaterialApp reconstruya y aplique el nuevo tema.
    widget.onThemeChanged();

    // Además, si alguna parte de NavigationHomeScreen (como el color del Scaffold)
    // necesita ser reconstruida debido al cambio de tema, haz un setState aquí.
    setState(() {
      // Forzar la reconstrucción de NavigationHomeScreen para reflejar cambios
      // en propiedades dependientes del tema que no estén en screenView.
    });
  }

  @override
  Widget build(BuildContext context) {
    // Accede al ColorScheme del tema actual (light o dark)
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      // Ya no es necesario especificar el color del Container si el Scaffold lo manejará
      // color: colorScheme.background, // o colorScheme.surface
      child: SafeArea(
        // Si tienes un CustomAppBar que maneja el padding superior,
        // puedes considerar remover top: false o todo el SafeArea si no es necesario.
        top: false, // Depende de si CustomAppBar ya tiene en cuenta el notch
        bottom: false, // Deja que el body se extienda por debajo de la barra de navegación del sistema si no hay Scaffold
        child: Scaffold(
          // El color de fondo del Scaffold debe ser del ColorScheme actual
          backgroundColor: colorScheme.background, // Usa el color del tema actual
          // Si tu CustomAppBar existe, descoméntalo y pasa el callback
          appBar: CustomAppBar(
            onThemeChanged: _handleAppBarThemeChange, // Pasar el callback
            // Aquí puedes añadir otras propiedades si tu CustomAppBar las requiere,
            // como un título, acciones, etc.
            // Por ejemplo: title: Text('CAPAC'),
          ),
          body: DrawerUserController(
            screenIndex: drawerIndex ?? DrawerIndex.HOME, // Null-safety
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
            },
            screenView: screenView ?? const Text("Error: No screen view available"), // Null-safety
            drawerIsOpen: (bool val) {
              // Puedes usar este callback si necesitas saber si el drawer está abierto/cerrado
              // y realizar alguna acción aquí en NavigationHomeScreen.
              // print("Drawer is open: $val");
            },
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      setState(() {
        if (drawerIndex == DrawerIndex.HOME) {
          screenView = const HelpScreen(); // Principal o la pantalla de inicio por defecto
        } else if (drawerIndex == DrawerIndex.PLACE_CATEGORY) { // Corregido el espacio
          screenView = const CategoriaMain(); // Pantalla de Estudiante
        } else if (drawerIndex == DrawerIndex.LOCATIONS) { // Corregido el espacio
          screenView = const LugarMain(); // Pantalla de Postulación
        } else if (drawerIndex == DrawerIndex.RESERVATIONS) {
          screenView = const ReservacionMain(); // <--- CORREGIDO: Usar ReservacionesMain si esa es la clase
        }
        // Añade más casos para otros índices del drawer si tienes más pantallas.
        // else if (drawerIndex == DrawerIndex.ABOUT) {
        //   screenView = const AboutUsScreen(); // Ejemplo
        // }
      });
    }
  }
}