// -----------------------------------------------------------------------
// Filename: colors.dart
// Original Author: Dan Grissom
// Creation Date: 5/18/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains all of the custom colors used in the
//              MIC app.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Flutter external package imports
import 'package:flutter/material.dart';

//////////////////////////////////////////////////////////////////////////
// Class definition
//////////////////////////////////////////////////////////////////////////
class CustomColors {
  // Custom colors
  static const Color statusError = Color.fromARGB(255, 130, 40, 40);
  static const Color statusWarning = Color.fromARGB(255, 126, 130, 40);
  static const Color statusSuccess = Color.fromARGB(255, 40, 130, 76);
  static const Color statusInfo = Color(0xFF022A3A);
  static const Color statusInfoDarkMode = Color.fromARGB(255, 88, 123, 145);
  static const Color offWhite = Color(0xFFF7f7F7);
  static const Color cloudGrey = Color(0xFFF1F0EB);

  static const Color primaryBackgroundLightMode = Color.fromARGB(255, 255, 255, 255);
  static const Color primaryBackgroundDarkMode = Color.fromARGB(255, 33, 33, 33);
  static const Color primaryNavBarLightMode = Color.fromARGB(255, 219, 219, 219);
  static const Color primaryNavBarDarkMode = Color.fromARGB(255, 68, 68, 68);
}
