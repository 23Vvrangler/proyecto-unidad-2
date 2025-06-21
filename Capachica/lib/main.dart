import 'package:app_capac/login/login_user.dart';
import 'package:app_capac/theme/AppTheme.dart';

import 'package:flutter/material.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title:"CAPACHICAS",
      theme: AppTheme.themeData,
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}