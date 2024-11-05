// -----------------------------------------------------------------------
// Filename: widget_app_drawer.dart
// Original Author: Wyatt Bodle
// Creation Date: 6/10/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the primary scaffold for the app.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Flutter external package imports
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:csc322_starter_app/widgets/navigation/widget_primary_app_bar.dart';

// App relative file imports
import '../../widgets/general/widget_scrollable_background.dart';
import '../auth/screen_profile_setup.dart';

//////////////////////////////////////////////////////////////////
// StateFUL widget which manages state. Simply initializes the
// state object.
//////////////////////////////////////////////////////////////////
class ScreenProfileEdit extends StatefulWidget {
  const ScreenProfileEdit({super.key});

  static const routeName = '/profileEdit';

  @override
  State<ScreenProfileEdit> createState() => _ScreenProfileEditState();
}

//////////////////////////////////////////////////////////////////
// The actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////
class _ScreenProfileEditState extends State<ScreenProfileEdit> {
  //////////////////////////////////////////////////////////////////////////
  // Primary Flutter method overriden which describes the layout
  // and bindings for this widget.
  //////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    // Return the widget to show
    return Scaffold(
      appBar: WidgetPrimaryAppBar(
        title: Text('Edit Profile'),
        actionButtons: [
          // IconButton(
          //   icon: const Icon(Icons.arrow_back),
          //   onPressed: () => context.pop(),
          // )
        ],
      ),
      body: ScrollableBackground(
        child: ScreenProfileSetup(
          isAuth: false,
        ),
        padding: 20,
      ),
    );
  }
}
