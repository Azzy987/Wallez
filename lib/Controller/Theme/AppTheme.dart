import 'package:flutter/material.dart';
import 'package:wallez_app/colors.dart';

class AppTheme {
  AppTheme();

  final lightTheme = ThemeData.light().copyWith(
      primaryColor: accentColorDark,
      indicatorColor: Colors.white,
      textTheme: TextTheme(
        headline1: TextStyle(color: textColorDark),
        headline2: TextStyle(color: Colors.black),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity);

  final darkTheme = ThemeData.dark().copyWith(
    primaryColor: primaryColorDark,
    accentColorBrightness: Brightness.dark,
    indicatorColor: accentColorDark,
    accentColor: accentColorDark,
    backgroundColor: primaryColorDark,
    scaffoldBackgroundColor: primaryColorDark,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: TextTheme(
      headline1: TextStyle(color: textColorDark),
      headline2: TextStyle(color: textColorDark),
    ),
  );
}
