import 'package:app_capac/drawer/home_drawer.dart';
import 'package:app_capac/theme/AppTheme.dart'; // Asumiendo que AppTheme está bien definido
import 'package:flutter/material.dart';

// Asegúrate de que DrawerIndex esté definido en 'package:capachica/drawer/home_drawer.dart'
// o donde corresponda, para que este archivo lo pueda importar.
// Por ejemplo, si está en home_drawer.dart:
// enum DrawerIndex {
//   HOME,
//   FEEDBACK,
//   HELP,
//   SHARE,
//   ABOUT,
//   INVITE,
//   // ... otros índices ...
// }

class DrawerUserController extends StatefulWidget {
  const DrawerUserController({
    super.key,
    this.drawerWidth = 250,
    required this.onDrawerCall,
    required this.screenView,
    this.animatedIconData = AnimatedIcons.arrow_menu, // Valor por defecto aquí
    this.menuView,
    required this.drawerIsOpen,
    required this.screenIndex,
  });

  final double drawerWidth;
  final Function(DrawerIndex) onDrawerCall;
  final Widget screenView;
  final Function(bool) drawerIsOpen;
  final AnimatedIconData animatedIconData;
  final Widget? menuView;
  final DrawerIndex screenIndex;

  @override
  _DrawerUserControllerState createState() => _DrawerUserControllerState();
}

class _DrawerUserControllerState extends State<DrawerUserController>
    with TickerProviderStateMixin {
  late ScrollController scrollController; // Usar 'late' para inicialización en initState
  late AnimationController iconAnimationController; // Usar 'late'
  // AnimationController? animationController; // No se usa en el código actual, se puede quitar

  double scrollOffset = 0.0; // Cambiado a 'scrollOffset' por convención

  @override
  void initState() {
    super.initState(); // Llamar a super.initState() primero es una buena práctica

    // Inicialización de controladores
    // animationController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this); // Si no se usa, eliminar
    iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 0),
    );
    iconAnimationController.animateTo(1.0,
        duration: const Duration(milliseconds: 0), curve: Curves.fastOutSlowIn);

    scrollController = ScrollController(initialScrollOffset: widget.drawerWidth);

    // Añadir listener al controlador de scroll
    scrollController.addListener(() {
      // Usar if-else if-else para manejar los estados del scroll
      if (scrollController.offset <= 0) {
        // Drawer completamente abierto
        if (scrollOffset != 1.0) {
          setState(() {
            scrollOffset = 1.0;
            widget.drawerIsOpen(true); // Informar que el drawer está abierto
          });
        }
        iconAnimationController.animateTo(0.0,
            duration: const Duration(milliseconds: 0),
            curve: Curves.fastOutSlowIn);
      } else if (scrollController.offset > 0 &&
          scrollController.offset < widget.drawerWidth) { // Eliminar .floor()
        // Drawer en movimiento
        iconAnimationController.animateTo(
            (scrollController.offset * 100 / (widget.drawerWidth)) / 100,
            duration: const Duration(milliseconds: 0),
            curve: Curves.fastOutSlowIn);
      } else {
        // Drawer completamente cerrado
        if (scrollOffset != 0.0) {
          setState(() {
            scrollOffset = 0.0;
            widget.drawerIsOpen(false); // Informar que el drawer está cerrado
          });
        }
        iconAnimationController.animateTo(1.0,
            duration: const Duration(milliseconds: 0),
            curve: Curves.fastOutSlowIn);
      }
    });

    // Llamada inicial para posicionar el drawer
    WidgetsBinding.instance.addPostFrameCallback((_) => getInitState());
  }

  // Se llamó 'acciondw', pero no hacía nada útil. Se puede eliminar o renombrar
  // si realmente tiene un propósito futuro.
  // void acciondw(){
  //   setState(() {});
  // }

  Future<bool> getInitState() async {
    scrollController.jumpTo(widget.drawerWidth);
    return true;
  }

  @override
  void dispose() {
    scrollController.dispose();
    iconAnimationController.dispose();
    // if (animationController != null) animationController?.dispose(); // Si se usa
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calcular una vez el alto de la AppBar
    final double appBarHeight = AppBar().preferredSize.height;

    return Scaffold(
      // backgroundColor: AppTheme.white, // Si quieres un color de fondo fijo
      body: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width + widget.drawerWidth,
          child: Row(
            children: <Widget>[
              SizedBox(
                width: widget.drawerWidth,
                height: MediaQuery.of(context).size.height,
                child: AnimatedBuilder(
                  animation: iconAnimationController, // No más !
                  builder: (BuildContext context, Widget? child) {
                    return Transform(
                      transform: Matrix4.translationValues(
                          scrollController.offset, 0.0, 0.0), // No más !
                      child: HomeDrawer(
                        screenIndex: widget.screenIndex, // Ya tiene un valor por defecto en el widget
                        iconAnimationController: iconAnimationController, // No más !
                        callBackIndex: (DrawerIndex indexType) {
                          onDrawerClick();
                          widget.onDrawerCall(indexType); // Quitado try-catch redundante
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Container(
                  decoration: BoxDecoration(
                    // color: AppTheme.white, // Si quieres un color de fondo fijo
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: AppTheme.grey.withOpacity(0.6), // Usar AppTheme.grey
                          blurRadius: 24),
                    ],
                  ),
                  child: Stack(
                    children: <Widget>[
                      // Ignorar puntero cuando el drawer está cerrado (scrollOffset == 0.0)
                      // y permitir puntero cuando el drawer está abierto (scrollOffset == 1.0)
                      IgnorePointer(
                        ignoring: scrollOffset == 0.0, // Ignorar si el drawer está cerrado
                        child: widget.screenView,
                      ),
                      // Overlay para cerrar el drawer al tocar la pantalla principal
                      if (scrollOffset == 1.0) // Si el drawer está abierto
                        InkWell(
                          onTap: () {
                            onDrawerClick();
                          },
                          child: Container(color: Colors.transparent), // Asegura que el InkWell sea interactivo
                        ),
                      // Icono de menú
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top + 2,
                            left: 8),
                        child: SizedBox(
                          width: appBarHeight - 8,
                          height: appBarHeight - 8,
                          // *** NO ANIDAR MaterialApp AQUÍ ***
                          // Accede al tema directamente desde el BuildContext principal.
                          child: InkWell(
                            borderRadius: BorderRadius.circular(appBarHeight),
                            child: Center(
                              // Si usas tu propia vista de menú UI, añádela desde la inicialización
                              child: widget.menuView ?? AnimatedIcon( // Simplificado con ??
                                  color: AppTheme.colorMenu, // Usar color de AppTheme
                                  icon: widget.animatedIconData, // animatedIconData ya tiene valor por defecto
                                  progress: iconAnimationController), // No más !
                            ),
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              onDrawerClick();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onDrawerClick() {
    // Si el scroll está en la posición 0.0 (drawer abierto), lo cierra (a widget.drawerWidth)
    // Si no está en 0.0 (drawer cerrado o moviéndose), lo abre (a 0.0)
    if (scrollController.offset == 0.0) { // Si está abierto
      scrollController.animateTo(
        widget.drawerWidth,
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
      );
    } else { // Si está cerrado o moviéndose
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
      );
    }
  }
}