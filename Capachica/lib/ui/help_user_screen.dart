import 'package:lb_app/comp/CustomAppBarX.dart';
import 'package:flutter/material.dart';
import 'package:lb_app/theme/AppTheme.dart';

class HelpUserScreen extends StatefulWidget {
  @override 
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpUserScreen> {
  @override
  void initState() {
    super.initState();
  }

  void accion() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: AppTheme.useLightMode ? ThemeMode.light : ThemeMode.dark,
      theme: AppTheme.themeDataLight,
      darkTheme: AppTheme.themeDataDark,
      home: SafeArea(
        top: false,
        child: Scaffold(
          appBar: CustomAppBarX(accionx: accion as Function),
          body: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: 16,
                  right: 16,
                ),
                child: Image.asset('assets/imagen/user-login-icon.png'),
              ),
              Container(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '¿En qué podemos ayudarte Usuario?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16),
                child: const Text(
                  'Parece que necesitas ayuda con nuestra\nplataforma de Bolsa Laboral. Estamos aquí para\nbrindarte asistencia y ayudarte a avanzar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Container(
                      width: 160,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.6),
                            offset: const Offset(4, 4),
                            blurRadius: 8.0,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Aquí podrías agregar la acción para abrir un chat de soporte o contactar con alguien.
                          },
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                'Habla con Soporte',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}