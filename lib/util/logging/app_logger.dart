// -----------------------------------------------------------------------
// Filename: app_logger.dart
// Original Author: Dan Grissom
// Creation Date: 5/18/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains a simple logger class that wraps
//              the Flutter print method. This allows for easy logging
//              to the console.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Flutter external package imports
import 'package:logger/logger.dart';

//////////////////////////////////////////////////////////////////////////
// Class Definition
//////////////////////////////////////////////////////////////////////////
class AppLogger {
  static void print(String message) {
    var logger = Logger(
      filter: null,
      printer: PrettyPrinter(colors: true, errorMethodCount: 2),
    );
    logger.i(message);
  }

  static void error(String error) {
    var logger = Logger(
      filter: null,
      printer: PrettyPrinter(colors: true, errorMethodCount: 2),
    );
    logger.e(error, error: '');
  }

  static void warning(String warning) {
    var logger = Logger(
      filter: null,
      printer: PrettyPrinter(colors: true, errorMethodCount: 2),
    );
    logger.w(warning);
  }

  static void debug(String debug) {
    var logger = Logger(
      filter: null,
      printer: PrettyPrinter(colors: true, errorMethodCount: 0, methodCount: 0),
    );
    logger.d(debug);
  }
}
