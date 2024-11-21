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
    var fortuneList = [
      Fortune(
        text:
            'The stars align in your favor. Expect to find a 100 dollar bill on your way to work!',
        type: FortuneType.GOOD_LUCK,
      ),
      Fortune(
        text:
            'Mischief will befall on you. A horde of squirrels will ruin your date by unleashing their acorns!',
        type: FortuneType.BAD_LUCK,
      ),
      Fortune(
        text:
            'I sense a frequency of good fortune. You will land a job and excel at your career!',
        type: FortuneType.BAD_LUCK,
      ),
    ];

    return Scaffold(
      // TODO: Remove action button
      // floatingActionButton: FloatingActionButton(
      //   shape: ShapeBorder.lerp(CircleBorder(), StadiumBorder(), 0.5),
      //   onPressed: () => Snackbar.show(
      //       SnackbarDisplayType.SB_INFO, 'You clicked the floating button on the alternate screen!', context),
      //   splashColor: Theme.of(context).primaryColor,
      //   child: Icon(FontAwesomeIcons.plus),
      // ),

      // ****************************************************
      // Show list of all fortunes saved to and from database
      // ****************************************************
      body: Expanded(
        child: ListView.builder(
          itemCount: fortuneList.length,
          itemBuilder: (context, index) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: FortuneListItem(text: fortuneList[index].text),
              ),
              SizedBox(height: 15)
            ],
          ),
        ),
      ),
    );
  }
}
