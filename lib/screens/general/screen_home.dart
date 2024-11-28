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
import 'package:csc322_starter_app/main.dart';
import 'package:csc322_starter_app/models/fortune.dart';
import 'package:csc322_starter_app/widgets/general/text_bubble.dart';
import 'package:csc322_starter_app/widgets/navigation/widget_primary_app_bar.dart';
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
  bool _isInit = true;
  bool _isGenerating = false;
  bool _hasErrorOccurred = false;
  bool _hasSaved = false;
  Fortune? fortune;
  String? generatedText;

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
      _hasErrorOccurred = false;
      _hasSaved = false;
    });

    try {
      // Request fortune
      final response = await model.generateContent(
        [Content.text('Tell me a fortune')],
      );
      if (response.text == null) {
        return;
      }

      // Set UI state to "loading"
      setState(() {
        _isGenerating = false;
        generatedText = response.text;
      });
    }

    // Prompt error
    catch (err) {
      print('ERROR: $err');
      setState(() {
        _hasErrorOccurred = true;
        _isGenerating = false;
      });
    }
  }

  // ****************************
  // Save fortune to provider
  // ****************************
  // TODO: save fortune to database
  void saveFortune() {
    // Cancel if waiting for fortune or no fortune is generated
    if (_hasSaved ||
        _isGenerating ||
        generatedText == null ||
        generatedText!.isEmpty) {
      return;
    }

    // Cancel if an error has occurred
    if (_hasErrorOccurred) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('There was an error saving a fortune.'), backgroundColor: Colors.red,));
      return;
    }

    // Indicate loading with overlay
    // TODO: When saving fortune to db,  show indicator
    /*
    showDialog(
      context: context,
      // barrierDismissible: false,
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
    */

    // Extract fortune data
    String extractedText =
        generatedText!.substring(0, generatedText!.lastIndexOf('.') + 1);
    String extractedType =
        generatedText!.substring(generatedText!.lastIndexOf('.') + 1).trim();

    // Add new fortune to provider
    ref.read(providerFortunes).addFortune(
          text: extractedText,
          type: extractedType.toUpperCase() == 'BAD'
              ? FortuneType.BAD_LUCK
              : FortuneType.GOOD_LUCK,
        );

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fortune was saved successfully.'), backgroundColor: Colors.green,));

    _hasSaved = true;

    // Pop off loading indicator
    // TODO: After saving fortune to database, pop off indicator
    /*
    Navigator.of(context, rootNavigator: true).pop();
    */
  }

  // Runs the following code once upon initialization
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
      model: 'gemini-1.5-flash-latest',
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

  // Initializes state variables and resources
  Future<void> _init() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Button to save fortune
      floatingActionButton: FloatingActionButton(
        shape: ShapeBorder.lerp(CircleBorder(), StadiumBorder(), 0.5),
        onPressed: !_isGenerating ? saveFortune : () {},
        splashColor: Theme.of(context).primaryColor,
        child: Icon(FontAwesomeIcons.plus),
      ),

      // Main content
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // **************************************
              // The genie who tells a fortune
              // **************************************
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                radius: 100,
              ),

              SizedBox(height: 25),

              // *****************************************
              // Text Bubble
              // *****************************************
              if (!_isGenerating && generatedText != null)
                TextBubble(
                  text: !_hasErrorOccurred ? generatedText!
                      .substring(0, generatedText!.lastIndexOf('.') + 1) : 'There was an error generating a fortune. Please try again.',
                  textColor: Theme.of(context).colorScheme.onSurface,
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: 16,
                )
              else if (_isGenerating)
                CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.surface),

              SizedBox(height: 25),

              // ***************
              // Tap Button
              // ***************
              ElevatedButton(
                child: Text(
                  'Tell me a fortune.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                      fontSize: 16),
                ),
                onPressed: !_isGenerating ? generateFortune : () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
