import 'package:app_capac/apis/usuario_api.dart';
import 'package:app_capac/util/TokenUtil.dart';
import 'package:flutter/material.dart';


class HomeDrawer extends StatefulWidget {
  const HomeDrawer({
    super.key,
    required this.screenIndex,
    required this.iconAnimationController,
    required this.callBackIndex,
  });

  final AnimationController iconAnimationController;
  final DrawerIndex screenIndex;
  final Function(DrawerIndex) callBackIndex;

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  List<DrawerList>? drawerList; // Descomentado: Necesario para el drawer
  //String? estudianteNombre; // Comentado: Relacionado con estudiante
  //String? estudianteApellido; // Comentado: Relacionado con estudiante
  //String? estudianteApellidoM; // Comentado: Relacionado con estudiante
  //bool isLoading = true; // Comentado: Relacionado con estudiante

  @override
  void initState() {
    setDrawerListArray();
    super.initState();
  }



  void setDrawerListArray() {
    drawerList = <DrawerList>[
      DrawerList(
        index: DrawerIndex.HOME,
        labelName: 'Principal',
        icon: const Icon(Icons.home_outlined),
      ),
      DrawerList(
        index: DrawerIndex.PLACE_CATEGORY,
        labelName: 'Categoría Lugar',
        icon: const Icon(Icons.category_outlined),
      ),
      DrawerList(
        index: DrawerIndex.LOCATIONS,
        labelName: 'Lugares',
        icon: const Icon(Icons.location_on_outlined),
      ),
      DrawerList(
        index: DrawerIndex.PROFILE,
        labelName: 'Perfil',
        icon: const Icon(Icons.person_outline),
      ),
      DrawerList(
        index: DrawerIndex.RESERVATIONS,
        labelName: 'Reservaciones',
        icon: const Icon(Icons.book_online_outlined),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background, // Fondo del Scaffold
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            color: colorScheme.primary, // Fondo del encabezado con color primario
            padding: const EdgeInsets.only(top: 40.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: widget.iconAnimationController,
                    builder: (BuildContext context, Widget? child) {
                      return ScaleTransition(
                        scale: AlwaysStoppedAnimation<double>(
                            1.0 - (widget.iconAnimationController.value) * 0.2),
                        child: RotationTransition(
                          turns: AlwaysStoppedAnimation<double>(Tween<double>(
                              begin: 0.0, end: 24.0)
                              .animate(CurvedAnimation(
                              parent: widget.iconAnimationController,
                              curve: Curves.fastOutSlowIn))
                              .value /
                              360),
                          child: Center(
                            child: CircleAvatar(
                              backgroundImage: AssetImage(
                                  'assets/imagen/configuraciones.png'),
                              radius: 40,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child:
                    // Comentado: Indicador de carga y texto del estudiante
                    /*isLoading
                        ? CircularProgressIndicator(
                            color: colorScheme.onPrimary, // Color de carga
                          )
                        :*/
                    Text(
                      "Usuario Anónimo (Administrador)", // Texto fijo al comentar estudiante
                      textAlign: TextAlign.left, // Mejor alineación para el nombre
                      style: textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimary, // Texto sobre color primario
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Divider(height: 1, color: colorScheme.outline), // Divisor con color del tema
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(0.0),
              itemCount: drawerList?.length,
              itemBuilder: (BuildContext context, int index) {
                return inkwell(drawerList![index]);
              },
            ),
          ),
          Divider(height: 1, color: colorScheme.outline), // Divisor con color del tema
          Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  'Salir',
                  style: textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface, // Color de texto principal
                  ),
                  textAlign: TextAlign.left,
                ),
                trailing: Icon(Icons.power_settings_new,
                    color: colorScheme.onSurface), // Color del ícono principal
                onTap: () {
                  onTapped(); // Llama a la función onTapped
                },
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ],
      ),
    );
  }

  // Comentado: Función onTapped para navegar al Login
  void onTapped() {
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(builder: (context) {
    //     return LoginPage(); // Comentado: Ya no se importa LoginPage
    //   }),
    //   ModalRoute.withName('/'),
    // );
    // Puedes añadir un print o una acción alternativa si deseas probar la salida
    print("Acción de salir (login comentado)");
  }

  Widget inkwell(DrawerList listData) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: colorScheme.primary.withOpacity(0.1), // Splash con color primario
        highlightColor: Colors.transparent,
        onTap: () {
          navigationtoScreen(listData.index);
        },
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 6.0,
                    height: 46.0,
                    color: widget.screenIndex == listData.index
                        ? colorScheme.secondary // Color de resaltado para el elemento seleccionado
                        : Colors.transparent,
                  ),
                  const Padding(padding: EdgeInsets.all(4.0)),
                  listData.isAssetsImage
                      ? Container(
                    width: 24,
                    height: 24,
                    child: Image.asset(listData.imageName,
                        color: widget.screenIndex == listData.index
                            ? colorScheme.secondary // Color seleccionado
                            : colorScheme.onSurfaceVariant), // Color no seleccionado
                  )
                      : Icon(listData.icon?.icon,
                      color: widget.screenIndex == listData.index
                          ? colorScheme.secondary // Color seleccionado
                          : colorScheme.onSurfaceVariant), // Color no seleccionado
                  const Padding(padding: EdgeInsets.all(4.0)),
                  Text(
                    listData.labelName,
                    style: textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: widget.screenIndex == listData.index
                          ? colorScheme.secondary // Color seleccionado
                          : colorScheme.onSurface, // Color no seleccionado
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> navigationtoScreen(DrawerIndex indexScreen) async {
    widget.callBackIndex(indexScreen);
  }
}

enum DrawerIndex {
  HOME,
  PLACE_CATEGORY,
  LOCATIONS,
  PROFILE,
  RESERVATIONS,
  HELP
  // NOTIFICATIONS, // Si agregaste Notificaciones al enum en setDrawerListArray
}

class DrawerList {
  DrawerList({
    this.isAssetsImage = false,
    this.labelName = '',
    this.icon,
    required this.index,
    this.imageName = '',
  });

  String labelName;
  Icon? icon;
  bool isAssetsImage;
  String imageName;
  DrawerIndex index;
}
