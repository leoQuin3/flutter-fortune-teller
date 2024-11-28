// -----------------------------------------------------------------------
// Filename: screen_home.dart
// Original Author: Dan Grissom
// Creation Date: 10/31/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the primary app bar.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Flutter imports

// Flutter external package imports
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// App relative file imports
import '../../util/message_display/snackbar.dart';
import '../../theme/colors.dart';

class WidgetPrimaryAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  // Constant parameters passedin
  final Widget title;
  final List<Widget>? actionButtons;
  bool inCurrentMeeting;

  WidgetPrimaryAppBar(
      {Key? key,
      required this.title,
      this.actionButtons,
      this.inCurrentMeeting = false})
      : super(key: key);
  // UserData().updateProfileImage();

  @override
  ConsumerState<WidgetPrimaryAppBar> createState() => _PrimaryAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}

//////////////////////////////////////////////////////////////////
// The actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////
class _PrimaryAppBar extends ConsumerState<WidgetPrimaryAppBar> {
  // The "instance variables" managed in this state
  var _isInit = true;

  ////////////////////////////////////////////////////////////////
  // Gets the current state of the providers for consumption on
  // this page
  ////////////////////////////////////////////////////////////////
  _init() async {
    // Get providers
  }

  ////////////////////////////////////////////////////////////////
  // Runs the following code once upon initialization
  ////////////////////////////////////////////////////////////////
  @override
  void didChangeDependencies() {
    // If first time running this code, update provider settings
    if (_isInit) {
      _init();
    }

    // Now initialized; run super method
    _isInit = false;
    super.didChangeDependencies();
  }

  ////////////////////////////////////////////////////////////////
  // Primary Flutter method overriden which describes the layout
  // and bindings for this widget.
  ////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: widget.title,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      actions: [
        // TODO: Allow user to change model, and allow to change categories by opening a new screen. Use fortunes provider to choose current provider
        PopupMenuButton(
          icon: Icon(Icons.settings),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Text('Configure Model'),
              value: 'category',
            ),
            PopupMenuItem(
              child: Text('Change Categories'),
              value: 'category',
            ),
          ],
        ),
        if (widget.actionButtons != null)
          ...widget.actionButtons!.map((e) {
            return e;
          }).toList()
      ],
    );
  }
}
