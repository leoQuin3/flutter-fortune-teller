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
import 'dart:math';

// Flutter external package imports
import 'package:csc322_starter_app/main.dart';
import 'package:csc322_starter_app/models/fortune.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// App relative file imports
import '../../util/message_display/snackbar.dart';

// Custom file imports
import 'package:csc322_starter_app/screens/general/profile_page.dart';
import 'package:csc322_starter_app/widgets/general/bottom_nav_bar.dart';

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
  final GEMINI_API_KEY = const String.fromEnvironment('GEMINI_API');
  late GenerativeModel model;
  FortuneType? fortuneType;
  String? generatedText;
  bool _isInit = true;
  bool _isGenerating = false;
  bool _hasErrorOccurred = false;

  // ************************************
  // Request Gemini to generate fortune
  // ************************************
  void generateFortune() async {
    // Check if API key provided
    if (GEMINI_API_KEY == null) {
      print('API key for Gemini AI not provided.');
      return;
    }

    // Update UI to "loading" state
    setState(() {
      _isGenerating = true;
    });

    try {
      // Request fortune
      final response = await model.generateContent(
        [Content.text('Tell me a fortune')],
      );

      // Update UI with new response
      setState(() {
        generatedText = response.text;
        _isGenerating = false;
      });
    } catch (err) {
      // Prompt error
      print('ERROR: $err');
      setState(() {
        generatedText = 'An error has occurred. Please tap again.';
        _isGenerating = false;
      });
    }
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

    // Define model
    model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: GEMINI_API_KEY,
      generationConfig: GenerationConfig(
        temperature: 2,
        topK: 40,
        // topP: 0.9,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
      systemInstruction: Content.system(
          'You are a genie who tells a fortune to the user. Create a unique fortune to the user with a prediction. The prediction can be good luck, which predicts desirable outcomes that will happen to the user. Or, the prediction can be a fortune of bad luck, a silly minor inconvenience. A fortune must be simple and be no more than two sentences long. Bad fortunes should not be dangerous or life threatening. Right after the last sentence, write either \"GOOD\" if the prediction is good luck, or \"BAD\" if the prediction is bad luck.'),
    );
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

        // ****************************
        // Save fortune to profile
        // ****************************
        onPressed: () async {
          // Cancel if waiting for fortune, an error occurs, or no fortune is generated.
          if (_isGenerating || _hasErrorOccurred || generatedText == null) {
            return;
          }

          // Get type from generated fortune
          String generatedFortuneType = generatedText!
              .substring(
                  generatedText!.lastIndexOf(' ') + 1, generatedText!.length)
              .trim()
              .toUpperCase();
          print(generatedFortuneType);

          // Assign type to fortune
          if (generatedFortuneType == 'BAD') {
            fortuneType = FortuneType.BAD_LUCK;
          } else {
            fortuneType = FortuneType.GOOD_LUCK;
          }

          // Indicate with loading overlay
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Saving fortune...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
          );

          // Save fortune to profile
          bool _isSuccessfullySaved = await ref
              .read(providerFortunes)
              .addFortune(text: generatedText!, type: fortuneType!);

          // Prompt save success
          if (!_isSuccessfullySaved) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('There was an error saving the fortune.')));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fortune was saved successfully.')));
          }

          // Remove loading indicator
          Navigator.of(context, rootNavigator: true).pop();
        },

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
            // FIXME: Fortune gets erased when switching out of screen. Maybe use providers to store previous fortune
            ElevatedButton(
              child: Text(
                'Tell me a fortune.',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: !_isGenerating ? generateFortune : () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
