// -----------------------------------------------------------------------
// Filename: screen_settings.dart
// Original Author: Wyatt Bodle
// Creation Date: 6/06/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the screen for the tts settings.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Flutter external package imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';
import 'package:csc322_starter_app/widgets/navigation/widget_primary_app_bar.dart';

// App relative file imports
import '../../providers/provider_user_profile.dart';
import '../../util/message_display/snackbar.dart';
import '../../util/logging/app_logger.dart';
import '../../providers/provider_tts.dart';
import '../../main.dart';

//////////////////////////////////////////////////////////////////
// StateFUL widget which manages state. Simply initializes the
// state object.
//////////////////////////////////////////////////////////////////
class ScreenSettings extends ConsumerStatefulWidget {
  const ScreenSettings({super.key});

  static const routeName = '/settings';

  @override
  ConsumerState<ScreenSettings> createState() => _ScreenSettingsState();
}

//////////////////////////////////////////////////////////////////
// The actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////
class _ScreenSettingsState extends ConsumerState<ScreenSettings> {
  // The "instance variables" managed in this state
  var _isInit = true;
  late ProviderUserProfile _providerUserProfile;
  late ProviderTts _providerTts;
  List<Map<String, dynamic>> _voices = [];
  Map<String, dynamic> _selectedVoice = {};
  bool _isListening = false;
  double _pitch = 1.0;
  double _rate = 0.5;
  TextEditingController _textController = TextEditingController(
      text:
          "Technology advances rapidly, yet the essential need for clear, effective communication remains unchanged.");

  ////////////////////////////////////////////////////////////////
  // Runs the following code once upon initialization
  ////////////////////////////////////////////////////////////////
  @override
  void didChangeDependencies() {
    // If first time running this code, update provider settings
    if (_isInit) {
      _init();

      // Now initialized; run super method
      _isInit = false;
      super.didChangeDependencies();
    }
  }
  ////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////
  /// Helper Methods (for state object)
  ////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////
  // Gets the current state of the providers for consumption on
  // this page
  ////////////////////////////////////////////////////////////////
  Future<void> _init() async {
    // Get providers
    _providerUserProfile = ref.watch(providerUserProfile);

    // Initialize the text-to-speech object
    _providerTts = ref.watch(providerTts);

    // Convert the list to a usable type
    dynamic voicesDyn = await _providerTts.getVoices();
    List<dynamic> voices = voicesDyn.map((item) {
      return item;
    }).toList();

    setState(() {
      // Get all the English voices
      for (dynamic voice in voices) {
        if (voice["locale"].startsWith("en")) {
          _voices.add({
            "name": voice["name"],
            "locale": voice["locale"],
          });
        }
      }
    });

    //Get and set the saved pitch and speed
    getCurrentData();
  }

  ////////////////////////////////////////////////////////////////
  // Gets the current data for consumption on
  // this page
  ////////////////////////////////////////////////////////////////
  void getCurrentData() async {
    _pitch = _providerUserProfile.pitch;
    _rate = _providerUserProfile.speed;
    //Checks the operating system to get the correct voice
    _selectedVoice = _voices.firstWhere(
      (voice) => voice["name"]!.contains(_providerUserProfile.voice['name'] ?? ""),
      orElse: () => _voices.first,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  ////////////////////////////////////////////////////////////////
  // Submits the current data to the _providerprofile
  ////////////////////////////////////////////////////////////////
  void _trySubmit() {
    // Unfocus from any controls that may have focus to disengage the keyboard
    FocusScope.of(context).unfocus();

    _providerUserProfile.pitch = _pitch;
    _providerUserProfile.speed = _rate;
    _providerUserProfile.voice = Map<String, String>.from(_selectedVoice);

    _providerUserProfile.writeUserProfileToDb();

    Snackbar.show(SnackbarDisplayType.SB_SUCCESS, 'Save Sucessful', context);
    context.pop();
  }

////////////////////////////////////////////////////////////////
  // Restores the current settings to defualt settings
  ////////////////////////////////////////////////////////////////
  void _restore() {
    //Set data back to original
    setState(() {
      _pitch = 1.0;
      _rate = 0.5;
      _selectedVoice = _voices.first;
    });
  }

  //////////////////////////////////////////////////////////////////////////
  // Primary Flutter method overriden which describes the layout
  // and bindings for this widget.
  //////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetPrimaryAppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Voice:'),
            DropdownButton<dynamic>(
              selectedItemBuilder: (BuildContext context) {
                return _voices.map<DropdownMenuItem<dynamic>>((dynamic value) {
                  String voiceName = value['name'] ?? '';
                  return DropdownMenuItem<dynamic>(value: value, child: Text(voiceName));
                }).toList();
              },
              isExpanded: true,
              value: _selectedVoice,
              hint: const Text('Select Voice'),
              items: _voices.map<DropdownMenuItem<dynamic>>((dynamic value) {
                String voiceName = value['name'] ?? '';
                return DropdownMenuItem<dynamic>(
                  value: value,
                  child: _selectedVoice['name'] == voiceName
                      ? Container(
                          width: double.infinity,
                          color: Theme.of(context).appBarTheme.backgroundColor,
                          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                          child: Text(voiceName),
                        )
                      : Text(voiceName),
                );
              }).toList(),
              onChanged: (dynamic? newValue) {
                setState(() {
                  _selectedVoice = newValue;
                });
              },
            ),
            const Text(
              '*These voices are provided by your own device',
              style: TextStyle(fontSize: 12.0),
            ),
            const SizedBox(height: 20),
            const Text('Pitch:'),
            Slider(
              value: _pitch,
              onChanged: (double newPitch) {
                setState(() {
                  _pitch = newPitch;
                });
              },
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: _pitch.toStringAsFixed(1),
            ),
            const SizedBox(height: 20),
            const Text('Speed:'),
            Slider(
              value: _rate,
              onChanged: (double newRate) {
                setState(() {
                  _rate = newRate;
                });
              },
              min: 0.1,
              max: 1.0,
              divisions: 18,
              label: _rate.toStringAsFixed(1),
            ),
            const SizedBox(height: 20),
            const Text('Text to Speak:'),
            TextField(
              maxLines: null,
              controller: _textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _providerTts.speak(_textController.text,
                            tempVoice: Map<String, String>.from(_selectedVoice), tempPitch: _pitch, tempSpeed: _rate),
                        child: const Text('Speak'),
                      ),
                      SizedBox(width: 50.0),
                      ElevatedButton(
                        onPressed: _restore,
                        child: const Text('Restore'),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _trySubmit,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
