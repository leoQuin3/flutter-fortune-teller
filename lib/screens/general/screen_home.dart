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
import 'package:csc322_starter_app/widgets/general/categories.dart';
import 'package:csc322_starter_app/widgets/general/text_bubble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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
  Categories _randomCategory = Categories.MISC;
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
      // Select a random category for a fortune
      _randomCategory =
          Categories.values[Random().nextInt(Categories.values.length)];
      print('FORTUNE WILL BE ABOUT: $_randomCategory');

      // Request fortune
      final response = await model.generateContent(
        [Content.text('Tell me a fortune about {${_randomCategory.name}}.')],
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('There was an error saving a fortune.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Extract fortune data
    String extractedText =
        generatedText!.substring(0, generatedText!.lastIndexOf('.') + 1);
    String extractedCategory =
        generatedText!.substring(generatedText!.lastIndexOf('.') + 1).trim();

    // Add new fortune to provider
    ref.read(providerFortunes).addFortune(
          text: extractedText,
          category: getCategory(extractedCategory),
        );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Fortune was saved successfully.'),
      backgroundColor: Colors.green,
    ));

    _hasSaved = true;
  }

  String getformattedText(String text) {
    return text!.trim().substring(0, text.lastIndexOf('.') + 1);
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
        temperature: 1.2,
        topK: 50,
        topP: 0.9,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
      systemInstruction: Content.system(
          'You are a genie who tells a fortune to the user. When they ask "Tell me a fortune about {CATEGORY}." create a unique fortune followed by a prediction whose topic is based on {CATEGORY}. If the category is {MISC}, then tell a whacky unpredictable fortune about anything. Your response must be short and concise, and be no longer than two sentences. Right after the last sentence, write the category WITHOUT the curly brackets.'),
    );
  }

  // Initializes state variables and resources
  Future<void> _init() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Button to save fortune
      // floatingActionButton: SizedBox(
      //   width: 200,
      //   height: 30,
      //   child: FloatingActionButton(
      //     // shape: ShapeBorder.lerp(CircleBorder(), StadiumBorder(), 0.5),
      //     onPressed: !_isGenerating ? saveFortune : () {},
      //     splashColor: Theme.of(context).primaryColor,
      //     child: Center(
      //       child: Text(
      //         'Save Fortune',
      //         style: TextStyle(
      //           fontSize: 18,
      //           color: Theme.of(context).colorScheme.onPrimary,
      //         ),
      //       ),
      //     ),
      //   ),
      // ),

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
              Stack(
                alignment: Alignment.center,
                children: [
                  //Left Hand
                  Positioned(
                    left: 200,
                    child: Image.asset(
                      'assets/images/ArmLeft.jpg',
                      height: 300,
                      width: 300,
                      fit: BoxFit.contain,
                    ),
                  ),

                  //Right Hand
                  Positioned(
                    right: 200,
                    child: Image.asset(
                      'assets/images/ArmRight.jpg',
                      height: 300,
                      width: 300,
                      fit: BoxFit.contain,
                    ),
                  ),
                  //Hold Ball Gif
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/SpinningBall.gif',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 25),

              // *****************************************
              // Text Bubble
              // *****************************************
              if (!_isGenerating && generatedText != null)
                TextBubble(
                  text: !_hasErrorOccurred
                      ? getformattedText(generatedText!)
                      : 'There was an error generating a fortune. Please try again.',
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
                  generatedText == null
                      ? 'Tell me a fortune.'
                      : 'Tell me another fortune.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                      fontSize: 16),
                ),
                onPressed: !_isGenerating
                    ? () {
                        ref.read(providerFortunes.notifier).incrementFortune();
                        generateFortune();
                      }
                    : () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.8),
                ),
              ),

              if (!_isGenerating && generatedText != null) SizedBox(height: 50),

              // ************************
              // Save fortune to profile
              // ************************
              if (!_isGenerating && generatedText != null)
                SizedBox(
                  width: 180,
                  height: 40,
                  child: FloatingActionButton(
                    onPressed: !_isGenerating ? saveFortune : () {},
                    splashColor: Theme.of(context).primaryColor,
                    child: Center(
                      child: Text(
                        'Save Fortune',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
