// -----------------------------------------------------------------------
// Filename: theme.dart
// Original Author: Dan Grissom
// Creation Date: 5/21/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the themes for the app.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////

// Flutter external package imports
import 'package:flutter/material.dart';
import 'package:csc322_starter_app/theme/colors.dart';

//////////////////////////////////////////////////////////////////////////
// LIGHT-MODE THEME
//////////////////////////////////////////////////////////////////////////
final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme(
    // primary: Color(0xFF7FBDDC),
    primary: Color(0xFF022A3A),
    onPrimary: Color(0xFFFFFFFF),
    // onPrimary: Color(0xFF022A3A),
    secondary: Color(0xFF022A3A),
    onSecondary: Color(0xFFFFFFFF),
    surface: CustomColors.offWhite,
    error: Color(0xFFCC0000),
    onError: Color(0xFFFFFFFF),
    onSurface: Color(0xFF022A3A),
    brightness: Brightness.light,
  ),
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: CustomColors.primaryBackgroundLightMode,
  cardColor: CustomColors.offWhite,

  // Input decoration theme - Used for TextFormFields
  inputDecorationTheme: milLightInputDecorationTheme,
  textButtonTheme: milLightTextButtonTheme,
  textTheme: Typography.blackRedmond,
  bottomNavigationBarTheme: milLightBottomNavigationBarTheme,
  appBarTheme: AppBarTheme(
    backgroundColor: CustomColors.cloudGrey,
  ),
  iconTheme: IconThemeData(color: CustomColors.statusInfo),
  floatingActionButtonTheme: milFloatingActionButtonTheme,
);

//////////////////////////////////////////////////////////////////////////
// DARK-MODE THEME
//////////////////////////////////////////////////////////////////////////
final ThemeData darkTheme = ThemeData(
  // Basic theme settings
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blueGrey,
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: CustomColors.primaryBackgroundDarkMode,

  // Widget stylings
  inputDecorationTheme: milLightInputDecorationTheme.copyWith(
    fillColor: Colors.grey[800],
    border: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    ),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    ),
    floatingLabelStyle: TextStyle(color: Colors.white),
    labelStyle: TextStyle(color: Colors.white),
    iconColor: CustomColors.statusInfoDarkMode,
  ),
  elevatedButtonTheme: milLightElevatedButtonTheme,
  textButtonTheme: milDarkTextButtonTheme,
  textTheme: Typography.whiteRedmond,
  appBarTheme: AppBarTheme(backgroundColor: CustomColors.primaryNavBarDarkMode),
  bottomNavigationBarTheme: milLightBottomNavigationBarTheme.copyWith(
    backgroundColor: CustomColors.primaryNavBarDarkMode,
    selectedItemColor: CustomColors.statusInfoDarkMode,
  ),
  floatingActionButtonTheme: milFloatingActionButtonTheme.copyWith(
    backgroundColor: CustomColors.statusInfoDarkMode,
  ),
);

// textTheme: TextTheme(
//   bodyLarge: TextStyle(color: Colors.white),
//   bodyMedium: TextStyle(color: Colors.white),
//   headlineLarge: TextStyle(color: Colors.white),
//   headlineMedium: TextStyle(color: Colors.white),
//   titleLarge: TextStyle(color: Colors.white),
//   titleMedium: TextStyle(color: Colors.white),
//   labelLarge: TextStyle(color: Colors.white),
//   labelMedium: TextStyle(color: Colors.white),
//   displayLarge: TextStyle(color: Colors.white),
//   displayMedium: TextStyle(color: Colors.white),
//   displaySmall: TextStyle(color: Colors.white),
//   titleSmall: TextStyle(color: Colors.white),
//   bodySmall: TextStyle(color: Colors.white),
// ),

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
// COMMON STYLING
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
// FLOATING ACTION BUTTON THEME
//////////////////////////////////////////////////////////////////////////
FloatingActionButtonThemeData milFloatingActionButtonTheme = FloatingActionButtonThemeData(
  backgroundColor: CustomColors.statusInfo,
  foregroundColor: Colors.white,
);

//////////////////////////////////////////////////////////////////////////
// INPUT DECORATION THEME
//////////////////////////////////////////////////////////////////////////
InputDecorationTheme milLightInputDecorationTheme = InputDecorationTheme(
  filled: true,
  fillColor: Colors.grey[200],
  border: const UnderlineInputBorder(
    borderSide: BorderSide(
      color: Colors.black,
    ),
    borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
  ),
  enabledBorder: const UnderlineInputBorder(
    borderSide: BorderSide(
      color: Colors.black,
    ),
    borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
  ),
  focusedBorder: const UnderlineInputBorder(
    borderSide: BorderSide(
      color: Colors.black,
    ),
    borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
  ),
  floatingLabelStyle: const TextStyle(color: Colors.black),
  constraints: const BoxConstraints(minHeight: 70),
  labelStyle: const TextStyle(color: Colors.black),
  // iconColor: CustomColors.statusInfo,
  iconColor: CustomColors.statusInfo,
);

//////////////////////////////////////////////////////////////////////////
// ELEVATED BUTTON THEME
//////////////////////////////////////////////////////////////////////////
ElevatedButtonThemeData milLightElevatedButtonTheme = ElevatedButtonThemeData(
  style: ButtonStyle(
    // padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.all(0)),
    textStyle: MaterialStateProperty.all<TextStyle>(
      const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
    ),
    backgroundColor: MaterialStateProperty.all<Color>(CustomColors.statusInfo),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),
  ),
);

//////////////////////////////////////////////////////////////////////////
// TEXT BUTTON THEME (LIGHT/DARK MODES)
//////////////////////////////////////////////////////////////////////////
TextButtonThemeData milLightTextButtonTheme = TextButtonThemeData(
  style: ButtonStyle(
    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.all(0)),
    textStyle: MaterialStateProperty.all<TextStyle>(
      const TextStyle(fontWeight: FontWeight.bold),
    ),
    foregroundColor: MaterialStateProperty.all<Color>(CustomColors.statusInfo),
  ),
);
TextButtonThemeData milDarkTextButtonTheme = TextButtonThemeData(
  style: ButtonStyle(
    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.all(0)),
    textStyle: MaterialStateProperty.all<TextStyle>(
      const TextStyle(fontWeight: FontWeight.bold),
    ),
    foregroundColor: MaterialStateProperty.all<Color>(CustomColors.statusInfoDarkMode),
  ),
);

//////////////////////////////////////////////////////////////////////////
// BOTTOM NAVIGATION BAR THEME (LIGHT MODE)
//////////////////////////////////////////////////////////////////////////
BottomNavigationBarThemeData milLightBottomNavigationBarTheme = BottomNavigationBarThemeData(
  backgroundColor: CustomColors.cloudGrey,
);
