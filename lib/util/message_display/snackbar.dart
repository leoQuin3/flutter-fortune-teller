// -----------------------------------------------------------------------
// Filename: snackbar.dart
// Original Author: Dan Grissom
// Creation Date: 5/21/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains a wrapper around the Flutter snackbar
//              library to display messages to the user.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Flutter external package imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// App relative file imports
import '../../theme/colors.dart';

// Enumeration type for coloring the snackbar
enum SnackbarDisplayType { SB_ERROR, SB_INFO, SB_SUCCESS, SB_WARNING }

//////////////////////////////////////////////////////////////////
// Class definition for SnackbarWrapper. This is essentially a
// wrapper around the Snackbar library and the required scaffolding
// to get that working.
//////////////////////////////////////////////////////////////////
class Snackbar {
  //////////////////////////////////////////////////////////////////
  // This function takes in a message type, message, message
  // origin (from frames or from phone) and local context and
  // displays a snackbar with the appropriate message, color and
  // source icon.
  //////////////////////////////////////////////////////////////////
  static show(SnackbarDisplayType msgType, String message, BuildContext context) {
    // Get proper color
    Color snackBarColor = CustomColors.statusSuccess;
    IconData snackBarIcon = CupertinoIcons.check_mark_circled;
    if (msgType == SnackbarDisplayType.SB_ERROR) {
      snackBarColor = CustomColors.statusError;
      snackBarIcon = CupertinoIcons.xmark_circle;
    } else if (msgType == SnackbarDisplayType.SB_INFO) {
      snackBarColor = CustomColors.statusInfo;
      snackBarIcon = CupertinoIcons.info_circle;
    } else if (msgType == SnackbarDisplayType.SB_WARNING) {
      snackBarColor = CustomColors.statusWarning;
      snackBarIcon = CupertinoIcons.exclamationmark_triangle;
    }

    // Show message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(snackBarIcon, color: Colors.white),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: snackBarColor,
      ),
    );
  }
}
