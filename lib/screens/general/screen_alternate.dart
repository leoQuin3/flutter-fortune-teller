// -----------------------------------------------------------------------
// Filename: screen_alternative.dart
// Original Author: Dan Grissom
// Creation Date: 10/31/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the screen for a dummy alternative screen
//               history screen.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////

// Flutter imports
import 'dart:async';

// Flutter external package imports
import 'package:csc322_starter_app/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// App relative file imports
import '../../util/message_display/snackbar.dart';

// Custom file imports
import 'package:csc322_starter_app/models/fortune.dart';
import 'package:csc322_starter_app/widgets/general/fortune_list_item.dart';

// ***************************************************
// Show list of all fortunes saved
// ***************************************************
class ScreenAlternate extends ConsumerStatefulWidget {
  static const routeName = '/alternative';

  @override
  ConsumerState<ScreenAlternate> createState() => _ScreenAlternateState();
}

//////////////////////////////////////////////////////////////////////////
// The actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////////////
class _ScreenAlternateState extends ConsumerState<ScreenAlternate> {
  // The "instance variables" managed in this state
  bool _isInit = true;

  ////////////////////////////////////////////////////////////////
  // Runs the following code once upon initialization
  ////////////////////////////////////////////////////////////////
  @override
  void didChangeDependencies() {
    // If first time running this code, update provider settings
    if (_isInit) {
      _init();
      _isInit = false;
      super.didChangeDependencies();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  ////////////////////////////////////////////////////////////////
  // Initializes state variables and resources
  ////////////////////////////////////////////////////////////////
  Future<void> _init() async {}

  //////////////////////////////////////////////////////////////////////////
  // Primary Flutter method overridden which describes the layout and bindings for this widget.
  //////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    //DEBUG: Test list. Replace with list with Fortune objects pulled from database
    var fortuneList = ref.watch(providerFortunes).fortuneList;

    return Scaffold(
      // ****************************************************
      // Show list of all fortunes saved to and from database
      // ****************************************************
      body: Expanded(
        child: ListView.builder(
          itemCount: fortuneList.length,
          itemBuilder: (context, index) => Column(
            children: [
              SizedBox(height: 15),
              Padding(
                child: FortuneListItem(text: fortuneList[index].text),
                padding: const EdgeInsets.symmetric(horizontal: 25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
