// -----------------------------------------------------------------------
// Filename: screen_home.dart
// Original Author: Dan Grissom
// Creation Date: 10/31/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the screen for a dummy home screen
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
import 'package:google_generative_ai/google_generative_ai.dart';

// App relative file imports
import '../../util/message_display/snackbar.dart';

//////////////////////////////////////////////////////////////////////////
// StateFUL widget which manages state. Simply initializes the state object.
//////////////////////////////////////////////////////////////////////////
class ScreenHome extends ConsumerStatefulWidget {
  static const routeName = '/home';

  @override
  ConsumerState<ScreenHome> createState() => _ScreenHomeState();
}

//////////////////////////////////////////////////////////////////////////
// The actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////////////
class _ScreenHomeState extends ConsumerState<ScreenHome> {
  // The "instance variables" managed in this state
  bool _isInit = true;
  bool _isGenerating = false;
  String? generatedText = null;

  // Generate a fortune by calling Gemini to generate text
  void generateFortune() async {
    // Call gemini
    final GEMINI_API_KEY = const String.fromEnvironment('GEMINI_API');

    print('Gemini\'s API: $GEMINI_API_KEY');
    if (GEMINI_API_KEY == null) {
      print('API key for Gemini AI not provided.');
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    // Define model
    final model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: GEMINI_API_KEY,
    );

    // Request fortune
    final prompt =
        '''You are a genie who tells a fortune to the user. Read a fortune to 
        the user and state a specific prediction. The prediction is either a 
        fortune of good luck or bad luck. Fortunes of good luck predicts 
        desirable events that will happen to the user. Fortunes of bad luck 
        predicts a comedic minor inconvenience that will befall on the user. 
        A fortune must be no more than two sentences long, and must be 
        detailed. Bad fortunes should not be dangerous, life threatening, 
        nor obscene, and must be light-hearted.''';
    final response = await model.generateContent([Content.text(prompt)]);

    setState(() {
      generatedText = response.text;
      _isGenerating = false;
    });
  }

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
    // Return the scaffold
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: ShapeBorder.lerp(CircleBorder(), StadiumBorder(), 0.5),
        onPressed: () => Snackbar.show(SnackbarDisplayType.SB_INFO,
            'You clicked the floating button on the home screen!', context),
        splashColor: Theme.of(context).primaryColor,
        child: Icon(FontAwesomeIcons.plus),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ************
            // Genie Avatar
            // ************
            CircleAvatar(
              backgroundColor: Colors.indigoAccent,
              radius: 100,
            ),

            SizedBox(height: 25),

            // *****************************************
            // Text Bubble
            // *****************************************
            if (generatedText != null && !_isGenerating)
              Padding(
                padding: EdgeInsets.all(8),
                child: Container(
                  child: Text(
                    '$generatedText',
                    style: TextStyle(color: Colors.white),
                    softWrap: true,
                  ),
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  constraints: BoxConstraints(maxWidth: 300),
                ),
              )
            else if (_isGenerating)
              CircularProgressIndicator(),

            SizedBox(height: 25),

            // ***************
            // Tell a fortune
            // ***************
            ElevatedButton(
              child: Text(
                'Tell me a fortune.',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: generateFortune,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
