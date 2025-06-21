// Asegúrate de que las importaciones sean correctas para tu proyecto
import 'package:app_capac/login/login_user.dart';
import 'package:app_capac/theme/AppTheme.dart';
import 'package:app_capac/util/TokenUtil.dart'; // Usará TokenUtil.userName, TokenUtil.TOKEN, TokenUtil.role
import 'package:app_capac/modelo/UsuarioModelo.dart'; // Solo para la estructura de UsuarioModeloCompleto y UserRole
import 'package:flutter/material.dart';

// Definición del enum DrawerIndex y la clase DrawerList (si no están ya en otro archivo)
enum DrawerIndex {
  HOME,
  FeedBack,
  Help,
  Share,
  About,
  Invite,
  Testing,
  PLACE_CATEGORY,
  LOCATIONS,
  RESERVATIONS,
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


class UserDrawuser extends StatefulWidget {
  const UserDrawuser({
    super.key,
    required this.screenIndex,
    required this.iconAnimationController,
    required this.callBackIndex,
  });

  final AnimationController iconAnimationController;
  final DrawerIndex screenIndex;
  final Function(DrawerIndex) callBackIndex;

  @override
  _UserDrawuserState createState() => _UserDrawuserState();
}

class _UserDrawuserState extends State<UserDrawuser> {
  List<DrawerList>? drawerList;
  UsuarioModeloCompleto? loggedInUser;
  bool isLoading = true; // Todavía útil para el caso inicial de TokenUtil vacío

  @override
  void initState() {
    super.initState();
    setDrawerListArray();
    _loadUserDataFromToken(); // Nuevo método para cargar datos desde TokenUtil
  }

  // Nuevo método para cargar los datos del usuario directamente desde TokenUtil
  void _loadUserDataFromToken() {
    // Comprobar si los datos esenciales están en TokenUtil
    if (TokenUtil.userName.isNotEmpty && TokenUtil.TOKEN.isNotEmpty && TokenUtil.role.isNotEmpty) {
      // Intenta parsear el rol a UserRole. Si falla, usa un valor por defecto.
      UserRole userRole;
      try {
        userRole = UserRole.values.firstWhere(
              (e) => e.toString().split('.').last == TokenUtil.role.toUpperCase(),
          orElse: () => UserRole.USER, // Rol por defecto si no se encuentra
        );
      } catch (e) {
        userRole = UserRole.USER; // En caso de cualquier error de parseo
        print("Error parsing user role from TokenUtil: $e");
      }


      setState(() {
        loggedInUser = UsuarioModeloCompleto(
          userName: TokenUtil.userName,
          // Asumo que firstName y lastName no están directamente en TokenUtil.
          // Si tu backend NO los devuelve en el login, considera si UserName debería ser el 'nombre visible'
          // O si necesitas un endpoint de perfil que los devuelva.
          // Por ahora, los dejaré vacíos o derivados del userName si es posible.
          firstName: TokenUtil.userName, // Usar userName como firstName si no hay otro dato
          lastName: '', // Dejar vacío
          email: '${TokenUtil.userName}@example.com', // Email ficticio si no está en TokenUtil
          role: userRole,
          // Si tienes otros campos como email, DNI, carrera, etc. en tu token/login response,
          // deberías añadirlos a TokenUtil y luego mapearlos aquí.
          // Por ejemplo:
          // email: TokenUtil.userEmail,
          // dateOfBirth: TokenUtil.userDateOfBirth != null ? DateTime.parse(TokenUtil.userDateOfBirth!) : null,
        );
        isLoading = false; // Los datos ya están cargados
      });
    } else {
      // Si no hay datos en TokenUtil, el usuario no está logueado o los datos son incompletos
      setState(() {
        loggedInUser = UsuarioModeloCompleto(
          userName: 'Invitado',
          email: 'invitado@example.com',
          firstName: 'Invitado',
          lastName: '',
          role: UserRole.USER,
        );
        isLoading = false; // Ya no estamos cargando de una API, solo verificando
      });
    }
  }

  void setDrawerListArray() {
    drawerList = <DrawerList>[
      DrawerList(index: DrawerIndex.HOME, labelName: 'Principal', icon: const Icon(Icons.home)),
      DrawerList(index: DrawerIndex.Invite, labelName: 'Perfil', icon: const Icon(Icons.person)),
      DrawerList(index: DrawerIndex.FeedBack, labelName: 'Postulaciones', icon: const Icon(Icons.description)),
      DrawerList(index: DrawerIndex.Share, labelName: 'Ofertas', icon: const Icon(Icons.local_offer)),
      DrawerList(index: DrawerIndex.Testing, labelName: 'Notificaciones', icon: const Icon(Icons.notifications)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16.0),
            color: colorScheme.primary,
            child: Padding(
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
                          child: const Center(
                            child: CircleAvatar(
                              backgroundImage: AssetImage('assets/imagen/perfil.png'),
                              radius: 40,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, left: 4),
                    child: isLoading
                        ? Center(child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                    ))
                        : Text(
                      "${loggedInUser?.firstName ?? 'Anonimo'} ${loggedInUser?.lastName ?? ''} (Usuario)",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  if (!isLoading && loggedInUser?.email != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        loggedInUser!.email,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onPrimary.withOpacity(0.7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Divider(height: 1, color: colorScheme.onSurface.withOpacity(0.2)),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(0.0),
              itemCount: drawerList?.length,
              itemBuilder: (BuildContext context, int index) {
                return _inkwell(drawerList![index]);
              },
            ),
          ),
          Divider(height: 1, color: colorScheme.onSurface.withOpacity(0.2)),
          Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  'Salir',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.left,
                ),
                trailing: Icon(
                  Icons.power_settings_new,
                  color: colorScheme.error,
                ),
                onTap: () {
                  _onTapped();
                },
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ],
      ),
    );
  }

  void _onTapped() {
    TokenUtil.TOKEN = "";
    TokenUtil.userName = "";
    TokenUtil.role = "";
    TokenUtil.localx = false;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) {
        return LoginPage();
      }),
          (Route<dynamic> route) => false,
    );
  }

  Widget _inkwell(DrawerList listData) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: colorScheme.primary.withOpacity(0.1),
        highlightColor: Colors.transparent,
        onTap: () {
          _navigationtoScreen(listData.index);
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
                  ),
                  const Padding(padding: EdgeInsets.all(4.0)),
                  listData.isAssetsImage
                      ? SizedBox(
                    width: 24,
                    height: 24,
                    child: Image.asset(listData.imageName,
                        color: widget.screenIndex == listData.index
                            ? colorScheme.primary
                            : colorScheme.onSurface),
                  )
                      : Icon(listData.icon?.icon,
                      color: widget.screenIndex == listData.index
                          ? colorScheme.primary
                          : colorScheme.onSurface),
                  const Padding(padding: EdgeInsets.all(4.0)),
                  Text(
                    listData.labelName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: widget.screenIndex == listData.index
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            widget.screenIndex == listData.index
                ? AnimatedBuilder(
              animation: widget.iconAnimationController,
              builder: (BuildContext context, Widget? child) {
                return Transform(
                  transform: Matrix4.translationValues(
                      (MediaQuery.of(context).size.width * 0.75 - 64) *
                          (1.0 - widget.iconAnimationController.value),
                      0.0,
                      0.0),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Container(
                      width:
                      MediaQuery.of(context).size.width * 0.75 - 64,
                      height: 46,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.2),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(28),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(28),
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Future<void> _navigationtoScreen(DrawerIndex indexScreen) async {
    widget.callBackIndex(indexScreen);
  }
}