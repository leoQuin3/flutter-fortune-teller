// -----------------------------------------------------------------------
// Filename: provider_user_profile.dart
// Original Author: Wyatt Bodle
// Creation Date: 6/18/2024
// Copyright: (c) 2024 CSC322
// Description: This file checks contains the provider class which manages
//              the Text to Speech state for the user.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////

// Flutter external package imports
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

// App relative file imports
import '../providers/provider_user_profile.dart';
import '../util/logging/app_logger.dart';

//////////////////////////////////////////////////////////////////////////
// State class that manages order variables; extends ChangeNotifier
// ChangeNotifier so it can be accessed in multiple files.
//////////////////////////////////////////////////////////////////////////
class ProviderTts extends ChangeNotifier {
  // The "instance variables" managed in this state
  late FlutterTts _flutterTts;
  final ProviderUserProfile _providerUserProfile;
  bool _isSpeaking = false;

///////////////////////////////////////////////////////////////////////////
// Constructor to initialize text to speech object.
//////////////////////////////////////////////////////////////////////////
  ProviderTts(this._providerUserProfile) {
    _flutterTts = FlutterTts();
    init();
  }

  ////////////////////////////////////////////////////////////////////////
  // GETTERS/SETTERS
  ////////////////////////////////////////////////////////////////////////
  double get pitch => _providerUserProfile.pitch;
  set pitch(double value) {
    _providerUserProfile.pitch = value;
    notifyListeners();
  }

  double get speed => _providerUserProfile.speed;
  set speed(double value) {
    _providerUserProfile.speed = value;
    notifyListeners();
  }

  Map<String, dynamic> get voice => _providerUserProfile.voice;
  set voice(Map<String, dynamic> value) {
    _providerUserProfile.voice = value;
    notifyListeners();
  }

  bool get isSpeaking => _isSpeaking;

  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  // UTILITY METHODS
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////
  // This method initializes the Text to Speech Object with the
  // so that it can be utilized later.
  ////////////////////////////////////////////////////////////////////////
  Future<void> init() async {
    //Get Providers
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(_providerUserProfile.pitch);
    await _flutterTts.setSpeechRate(_providerUserProfile.speed);
    Map<String, String> voice = _providerUserProfile.voice.map((key, value) {
      return MapEntry(key, value as String);
    });
    await _flutterTts.setVoice(voice);
  }

  ////////////////////////////////////////////////////////////////////////
  // This method begins the Text-To-Speech if there is not a temp voice
  // passed in it will assign it to the saved value
  ////////////////////////////////////////////////////////////////////////
  Future<void> speak(
    String text, {
    Map<String, String>? tempVoice,
    double? tempPitch,
    double? tempSpeed,
    bool isEnabled = true,
  }) async {
    // If the TTS is disabled, return
    if (!isEnabled) return;

    // Use the provided values or default to the values from ProviderUserProfile
    final voice = tempVoice ?? _providerUserProfile.voice;
    final pitch = tempPitch ?? _providerUserProfile.pitch;
    final speed = tempSpeed ?? _providerUserProfile.speed;

    // Apply the temporary settings
    await _flutterTts.setVoice(voice.map((key, value) => MapEntry(key, value as String)));
    await _flutterTts.setPitch(pitch);
    await _flutterTts.setSpeechRate(speed);

    // Speak the text
    _isSpeaking = true;
    notifyListeners();
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.speak(text);
    await Future.delayed(Duration(milliseconds: 500));
    _isSpeaking = false;
    notifyListeners();
    AppLogger.print("Done talking");

    // Restore the original settings (optional)
    await _flutterTts.setVoice(_providerUserProfile.voice.map((key, value) => MapEntry(key, value as String)));
    await _flutterTts.setPitch(_providerUserProfile.pitch);
    await _flutterTts.setSpeechRate(_providerUserProfile.speed);
  }

  ////////////////////////////////////////////////////////////////////////
  // This method will stop the Text-To-Speech
  ////////////////////////////////////////////////////////////////////////
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  ////////////////////////////////////////////////////////////////////////
  // This method will get all avalible voices for the particular device
  // the user is using
  ////////////////////////////////////////////////////////////////////////
  Future<dynamic> getVoices() async {
    return await _flutterTts.getVoices;
  }
}
