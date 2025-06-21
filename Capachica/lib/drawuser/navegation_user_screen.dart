import 'package:app_capac/drawer/drawer_user_controller.dart';
import 'package:app_capac/drawer/home_drawer.dart'; // Asegúrate que DrawerIndex está aquí
// import 'package:capachica/theme/AppTheme.dart'; // No se está usando directamente, Theme.of(context) es suficiente
import 'package:app_capac/ui/categorialugar/categoria_main.dart';
import 'package:app_capac/ui/help_screen.dart';
import 'package:app_capac/ui/lugares/lugares_main.dart';

import 'package:flutter/material.dart';

class NavigationUserScreen extends StatefulWidget {
  // ELIMINA la línea `final VoidCallback onThemeChanged;` si esta pantalla NO va a iniciar el cambio de tema.
  // Y cambia el constructor para que NO requiera parámetros.
  // Si esta pantalla NO necesita un callback para el tema desde el exterior, déjalo así:
  final VoidCallback onThemeChanged;
  const NavigationUserScreen({super.key, required this.onThemeChanged}); // <-- Constructor SIN parámetros requeridos

  // Si SÍ necesita un callback para el tema (ej. tiene un botón de tema), hazlo OPCIONAL:
  // final VoidCallback? onThemeChanged;
  // const NavigationUserScreen({super.key, this.onThemeChanged});


  @override
  _NavigationUserScreenState createState() => _NavigationUserScreenState();
}

class _NavigationUserScreenState extends State<NavigationUserScreen> {
  Widget? screenView;
  DrawerIndex? drawerIndex;

  @override
  void initState() {
    drawerIndex = DrawerIndex.HOME;
    screenView = const HelpScreen(); // Usar const para widgets inmutables
    super.initState();
  }

  // Si decides mantener `onThemeChanged` como opcional en el constructor,
  // y tuvieras un botón para cambiar el tema en esta pantalla, lo llamarías así:
  // void _toggleTheme() {
  //   widget.onThemeChanged?.call(); // Llama al callback si no es nulo
  //   setState(() {}); // Opcional, para reconstruir la UI de esta pantalla si es necesario
  // }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          // Usa el ColorScheme para mayor flexibilidad del tema
          backgroundColor: colorScheme.background, // O colorScheme.primary si quieres un color más vivo
          // Si tienes un CustomAppBar para usuarios, asegúrate de que su constructor sea compatible.
          // appBar: CustomAppBar(accionx: accion as Function), // Descomenta si lo usas
          body: DrawerUserController(
            screenIndex: drawerIndex ?? DrawerIndex.HOME, // Null-safety
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
              //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
            },
            screenView: screenView ?? const Text("Error: No screen view available"), // Null-safety
            drawerIsOpen: (bool value) {  }, // <--- CORREGIDO: Añadir nombre de la variable 'value'
            //we replace screen view as we need on navigate starting screens like MyHomePage, HelpScreen, FeedbackScreen, etc...
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
          screenView = const HelpScreen(); //Principal
        } else if (drawerIndex == DrawerIndex.LOCATIONS) {
          screenView = const LugarMain();  //Estudiante
        } else if (drawerIndex == DrawerIndex.PLACE_CATEGORY) {
          screenView = const CategoriaMain();  //Postulacion
        } else {
          // <--- CORREGIDO: Añadir un caso por defecto si el índice no coincide
          screenView = const HelpScreen(); // O la pantalla de inicio
        }
      });
    }
  }
}