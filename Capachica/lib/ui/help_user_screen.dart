import 'package:app_capac/theme/AppTheme.dart';

import 'package:flutter/material.dart';


class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  // Cambiado de Function a VoidCallback para mayor claridad y seguridad de tipo
  CustomAppBar({
    super.key,
    required this.onThemeChanged // Renombrado de accionx a onThemeChanged
  }) : preferredSize = const Size.fromHeight(50.0); // Usar const si es posible

  // Cambiado de Function a VoidCallback
  final VoidCallback onThemeChanged;

  @override
  final Size preferredSize;

  @override
  _CustomAppBarState createState() => _CustomAppBarState(); // No se necesita pasar el callback al estado
}

class _CustomAppBarState extends State<CustomAppBar>{
  // El callback ya está disponible a través de widget.onThemeChanged
  // No es necesario declarar accionx aquí ni en el constructor
  // _CustomAppBarState(this.accionx);
  // Function accionx;

  @override
  Widget build(BuildContext context) {
    // La variable coloS está bien, pero el onTap de PopupMenuItem ya lo asigna
    // Puedes mover la actualización del tema a onSelected.
    int coloS = AppTheme.colorSelected; // Inicializar con el color actual

    return AppBar(
      title: Center(child: AppTheme.useMaterial3 ? const Text("BOLSA LABORAL") : const Text("Bolsa Laboral")),
      actions: [
        IconButton(
          icon: AppTheme.useLightMode? const Icon(Icons.wb_sunny_outlined): const Icon(Icons.wb_sunny),
          onPressed: (){
            setState(() {
              AppTheme.useLightMode = !AppTheme.useLightMode;
              AppTheme.themeData = ThemeData(
                  colorSchemeSeed: AppTheme.colorOptions[AppTheme.colorSelected],
                  useMaterial3: AppTheme.useMaterial3,
                  brightness: AppTheme.useLightMode ? Brightness.light : Brightness.dark);

              // Llama al callback para notificar a NavigationHomeScreen
              widget.onThemeChanged();
            });
          },
          tooltip: "Toggle brightness",
        ),
        IconButton(
          icon: AppTheme.useMaterial3? const Icon(Icons.filter_3): const Icon(Icons.filter_2),
          onPressed: (){
            setState(() {
              AppTheme.useMaterial3 = !AppTheme.useMaterial3;
              AppTheme.themeData = ThemeData(
                  colorSchemeSeed: AppTheme.colorOptions[AppTheme.colorSelected],
                  useMaterial3: AppTheme.useMaterial3,
                  brightness: AppTheme.useLightMode ? Brightness.light : Brightness.dark);
            });
            // Llama al callback para notificar a NavigationHomeScreen
            widget.onThemeChanged();
          },
          tooltip: "Switch to Material ${AppTheme.useMaterial3 ? 2 : 3}",
        ),
        PopupMenuButton<int>( // Especifica el tipo genérico para PopupMenuButton
          icon: const Icon(Icons.more_vert),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          itemBuilder: (context) {
            return List.generate(AppTheme.colorOptions.length, (index) {
              return PopupMenuItem<int>( // Especifica el tipo genérico para PopupMenuItem
                value: index,
                child: Wrap(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Icon(
                        index == AppTheme.colorSelected? Icons.color_lens: Icons.color_lens_outlined,
                        color: AppTheme.colorOptions[index],
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(AppTheme.colorText[index]))
                  ],
                ),
                // Quitar onTap aquí y manejar el cambio de color en onSelected de PopupMenuButton
                // El onTap del PopupMenuItem se ejecuta ANTES que onSelected,
                // lo que puede causar un doble setState o un estado inconsistente.
                // Es mejor dejar que onSelected maneje el cambio y el setState.
              );
            });
          },
          onSelected: (int selectedValue){ // selectedValue es el 'value' del PopupMenuItem
            setState(() {
              AppTheme.colorSelected = selectedValue; // Actualiza el color seleccionado globalmente
              AppTheme.themeData = ThemeData(
                  colorSchemeSeed: AppTheme.colorOptions[AppTheme.colorSelected], // Usar AppTheme.colorSelected
                  useMaterial3: AppTheme.useMaterial3,
                  brightness: AppTheme.useLightMode ? Brightness.light : Brightness.dark);
            });
            // Llama al callback para notificar a NavigationHomeScreen
            widget.onThemeChanged();
          },
        ),
      ],
    );
  }
}