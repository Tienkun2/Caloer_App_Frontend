import 'package:flutter/material.dart';
import 'package:caloer_app/screens/home_screen.dart';
import 'package:caloer_app/service/SplashScreen.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: Color(0xFF4CAF50),
      colorScheme: ColorScheme.light(
        primary: Color(0xFF4CAF50),
        secondary: Color(0xFF8BC34A),
      ),
      fontFamily: 'Roboto',
    ),
    home: SplashScreen(),
  ));
}