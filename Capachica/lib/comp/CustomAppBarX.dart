import 'package:app_capac/theme/AppTheme.dart';
import 'package:flutter/material.dart';

class CustomAppBarX extends StatefulWidget implements PreferredSizeWidget {
  // Cambiado de Function a VoidCallback para mayor claridad y seguridad de tipo
  CustomAppBarX({
    super.key,
    required this.onThemeChanged, // Renombrado para consistencia
  }) : preferredSize = const Size.fromHeight(50.0); // Usar const

  final VoidCallback onThemeChanged; // Tipo explícito

  @override
  final Size preferredSize;

  @override
  _CustomAppBarXState createState() => _CustomAppBarXState(); // No pasar el callback al estado
}

class _CustomAppBarXState extends State<CustomAppBarX> {
  // No es necesario declarar ni pasar accionx/onThemeChanged aquí en el estado.
  // Se accede a través de widget.onThemeChanged.

  @override
  Widget build(BuildContext context) {
    // Obtener el ColorScheme del tema actual (light o dark) que está activo
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      title: Center(
        child: Text(
          "BOLSA LABORAL",
          // Usa el color del tema actual para el texto del título
          // Por ejemplo, onPrimary o primary si es un título claro sobre un AppBar oscuro.
          style: TextStyle(
            color: colorScheme.onPrimary, // Color de texto sobre el color primario del tema
          ),
        ),
      ),
      // El color de fondo del AppBar debería venir del ColorScheme de tu tema
      // o ser AppTheme.themeData.appBarTheme.backgroundColor si lo defines ahí.
      backgroundColor: colorScheme.primary, // Ejemplo: color primario del tema
      // Si quieres el color específico 0xFF375534 como en tu código,
      // deberías definirlo en tu AppTheme como una propiedad y usarlo aquí,
      // o como parte de tu ColorScheme si es un color primario/secundario.
      // backgroundColor: Color(0xFF375534), // Si realmente quieres un color fijo aquí
      actions: [
        IconButton(
          icon: AppTheme.useLightMode
              ? const Icon(Icons.wb_sunny_outlined)
              : const Icon(Icons.wb_sunny),
          // El color del ícono debe venir del ColorScheme del tema
          // Por ejemplo, onPrimary si el AppBar tiene un color primario de fondo
          color: colorScheme.onPrimary, // Color del ícono
          onPressed: () {
            setState(() {
              AppTheme.useLightMode = !AppTheme.useLightMode;
              // No es necesario reconstruir ThemeData aquí, AppTheme.themeData ya lo hace
              // automáticamente cuando se accede, o debería tener un método para actualizarlo.
              // La lógica de AppTheme.colorMenu debe estar en AppTheme.dart y depender de
              // AppTheme.useLightMode y AppTheme.useMaterial3.

              // Notifica al widget padre que el tema ha cambiado
              widget.onThemeChanged();
            });
          },
          tooltip: "Toggle brightness",
        ),
        // IconButton para Material3, si aún lo necesitas. Lo quitaré si no es necesario.
        // Si tu intención es solo cambiar de Material2 a Material3 una vez,
        // esto podría ser un ajuste de configuración global y no un botón en el AppBar.
        // Si lo necesitas, mantén el patrón:
        /*
        IconButton(
          icon: AppTheme.useMaterial3 ? const Icon(Icons.filter_3) : const Icon(Icons.filter_2),
          color: colorScheme.onPrimary, // Color del ícono
          onPressed: () {
            setState(() {
              AppTheme.useMaterial3 = !AppTheme.useMaterial3;
              // Notifica al widget padre que el tema ha cambiado
              widget.onThemeChanged();
            });
          },
          tooltip: "Switch to Material ${AppTheme.useMaterial3 ? 2 : 3}",
        ),
        */
        PopupMenuButton<int>( // Especifica el tipo genérico
          icon: Icon(
            Icons.more_vert,
            color: colorScheme.onPrimary, // Color del ícono
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          itemBuilder: (context) {
            return List.generate(AppTheme.colorText.length, (index) { // Usar AppTheme.colorText
              return PopupMenuItem<int>(
                value: index,
                child: Wrap(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Icon(
                        index == AppTheme.colorSelected // Usar AppTheme.colorSelected
                            ? Icons.color_lens
                            : Icons.color_lens_outlined,
                        // El color del ícono en el menú debería venir de AppTheme.colorOptions
                        color: AppTheme.colorOptions[index], // Usar AppTheme.colorOptions
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(AppTheme.colorText[index]), // Usar AppTheme.colorText
                    ),
                  ],
                ),
                // Quita el onTap del PopupMenuItem; el manejo principal debe ser en onSelected
              );
            });
          },
          onSelected: (int selectedValue) {
            setState(() {
              AppTheme.colorSelected = selectedValue;
              // No es necesario reconstruir ThemeData aquí, AppTheme.themeData ya lo hace
              // automáticamente cuando se accede, o debería tener un método para actualizarlo.
              // La lógica de AppTheme.colorMenu debe estar en AppTheme.dart y depender de
              // AppTheme.useLightMode y AppTheme.useMaterial3.

              // Notifica al widget padre que el tema ha cambiado
              widget.onThemeChanged();
            });
          },
        ),
      ],
    );
  }
}