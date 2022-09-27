import 'package:arc/src/config/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    fontFamily: 'MyFont',
    brightness: Brightness.light,
    backgroundColor: AppColors.lightBG,
    primaryColor: AppColors.mainColor,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.lightAccent,
    ),
    appBarTheme: const AppBarTheme(color: AppColors.mainColor),
    toggleableActiveColor: Colors.blue,
    dividerColor: const Color(0xFFF8F8F8),
    scaffoldBackgroundColor: AppColors.lightBG,
    cupertinoOverrideTheme: const CupertinoThemeData(
      primaryColor: AppColors.mainColor,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: Colors.black,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        primary: Colors.black12,
        onPrimary: Colors.black,
      ),
    ),
  ).copyWith(
    colorScheme:
        ThemeData().colorScheme.copyWith(secondary: AppColors.lightAccent),
  );

  static final darkTheme = ThemeData(
    fontFamily: 'MyFont',
    brightness: Brightness.dark,
    backgroundColor: AppColors.darkBG,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBG,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.darkAccent,
    ),
    appBarTheme: const AppBarTheme(color: AppColors.darkAccent),
    toggleableActiveColor: Colors.blueAccent,
    dividerColor: const Color(0xFF2F2F2F),
    cupertinoOverrideTheme: const CupertinoThemeData(
      primaryColor: AppColors.darkAccent,
    ),
    buttonTheme: const ButtonThemeData(buttonColor: AppColors.darkAccent),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        primary: Colors.white12,
        onPrimary: Colors.white,
      ),
    ),
  ).copyWith(
    colorScheme:
        ThemeData().colorScheme.copyWith(secondary: AppColors.darkAccent),
  );
}
