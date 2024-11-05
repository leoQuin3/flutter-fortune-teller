// -----------------------------------------------------------------------
// Filename: user_profile.dart
// Original Author: Dan Grissom
// Creation Date: 5/22/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the model for the user profile

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Dart imports
import 'dart:convert';
import 'dart:io';

// Flutter external package imports
import 'package:cloud_firestore/cloud_firestore.dart';

// Enum definition for account creation status
enum AccountCreationStep {
  ACC_STEP_ONBOARDING_PROFILE_CONTACT_INFO,
  ACC_STEP_ONBOARDING_COMPLETE,
}

// Enum definition for permission level
// NOTE: Do NOT change the order of these enums. They are used for permissions
// checking (e.g., Developer has access to Beta and Production, but not vice versa by
// the fact that Developer is the highest enum value)
enum PermissionLevel {
  PRODUCTION,
  BETA,
  DEVELOPER,
}

//////////////////////////////////////////////////////////////////////////
// Model class definitition
//////////////////////////////////////////////////////////////////////////
class UserProfile {
  ////////////////////////////////////////////////////////////////////////
  // Instance variables
  ////////////////////////////////////////////////////////////////////////
  String _uid = "";
  String _firstName = "";
  String _lastName = "";
  String _email = "";
  double _pitch = 1.0;
  double _speed = 0.5;
  Map<String, dynamic> _iosVoice = {
    'name': "Karen",
    'locale': "en-GB",
  };
  Map<String, dynamic> _androidVoice = {
    'name': "en-gb-x-gba-local",
    'locale': "en-GB",
  };
  PermissionLevel _permissionLevel = PermissionLevel.PRODUCTION;
  int _accountCreationTime = 0;
  DateTime _dateLastPasswordChange = DateTime.now().add(const Duration(days: -365));
  AccountCreationStep _accountCreationStep = AccountCreationStep.ACC_STEP_ONBOARDING_PROFILE_CONTACT_INFO;
  bool _voicePromptsEnabled = true;
  bool _realTimeAssistantEnabled = true;

  ////////////////////////////////////////////////////////////////////////
  // CONSTRUCTORS
  ////////////////////////////////////////////////////////////////////////
  // Positional Constructor
  UserProfile(
    this._uid,
    this._firstName,
    this._lastName,
    this._email,
    this._speed,
    this._pitch,
    this._iosVoice,
    this._androidVoice,
    this._permissionLevel,
    this._accountCreationTime,
    this._dateLastPasswordChange,
    this._accountCreationStep,
    this._voicePromptsEnabled,
    this._realTimeAssistantEnabled,
  );

  // Named Constructor
  UserProfile.empty() {
    _uid = "";
    _lastName = "";
    _firstName = "";
    _email = "";
    _pitch = 1.0;
    _speed = 0.5;
    _iosVoice = {
      'name': "Karen",
      'locale': "en-GB",
    };
    _androidVoice = {
      'name': "en-gb-x-gba-local",
      'locale': "en-GB",
    };
    _permissionLevel = PermissionLevel.PRODUCTION;
    _accountCreationTime = 0;
    _accountCreationStep = AccountCreationStep.ACC_STEP_ONBOARDING_PROFILE_CONTACT_INFO;
    _voicePromptsEnabled = true;
    _realTimeAssistantEnabled = false;
  }

  ////////////////////////////////////////////////////////////////////////
  // Creates a new User profile and populates using the JSON object passed
  // in as parameter
  ////////////////////////////////////////////////////////////////////////
  UserProfile.defFromJsonDbObject(Map<String, dynamic> jsonObject, String firebaseUid) {
    firstName = jsonObject["first_name"] ?? "";
    lastName = jsonObject["last_name"] ?? "";
    email = jsonObject["email"] ?? "";
    if (jsonObject["ttsSettings"] != null) {
      pitch = jsonObject['ttsSettings']["pitch"] ?? 1.0;
      speed = jsonObject['ttsSettings']['speed'] ?? 0.5;
      _iosVoice = jsonObject['ttsSettings']['selectedVoices']['ios_voice'] ?? {'name': "Karen", 'locale': "en-GB"};
      _androidVoice = jsonObject['ttsSettings']['selectedVoices']['android_voice'] ??
          {'name': "en-gb-x-gba-local", 'locale': "en-GB"};
    }
    uid = firebaseUid;
    permissionLevel = _getPermissionLevelFromString(
        jsonObject["permission_level"] ?? _getStringFromPermissionLevel(PermissionLevel.PRODUCTION));
    _dateLastPasswordChange = (jsonObject["date_last_password_change"] as Timestamp?)?.toDate() ??
        DateTime.now().add(const Duration(days: -365));
    accountCreationStep = getStepFromString(jsonObject["account_creation_step"] ??
        getStringFromStep(AccountCreationStep.ACC_STEP_ONBOARDING_PROFILE_CONTACT_INFO));
    _voicePromptsEnabled = jsonObject["voice_prompts_enabled"] ?? true;
    _realTimeAssistantEnabled = jsonObject["real_time_assistant_enabled"] ?? false;
  }

  ////////////////////////////////////////////////////////////////////////
  // SETTERS
  ////////////////////////////////////////////////////////////////////////
  set uid(String value) => _uid = value;
  set firstName(String value) => _firstName = value;
  set lastName(String value) => _lastName = value;
  set email(String value) => _email = value;
  set pitch(double value) => _pitch = value;
  set speed(double value) => _speed = value;
  set voice(Map<String, dynamic> value) {
    if (Platform.isIOS) {
      _iosVoice = value;
    } else if (Platform.isAndroid) {
      _androidVoice = value;
    }
  }

  set permissionLevel(PermissionLevel value) => _permissionLevel = value;
  set accountCreationTime(int value) => _accountCreationTime = value;
  set dateLastPasswordChange(DateTime value) => _dateLastPasswordChange = value;
  set accountCreationStep(AccountCreationStep value) => _accountCreationStep = value;
  set voicePromptsEnabled(bool value) => _voicePromptsEnabled = value;
  set realTimeAssistantEnabled(bool value) => _realTimeAssistantEnabled = value;

  ////////////////////////////////////////////////////////////////////////
  // GETTERS
  ////////////////////////////////////////////////////////////////////////
  String get uid => _uid;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  double get pitch => _pitch;
  double get speed => _speed;
  Map<String, dynamic> get voice {
    if (Platform.isIOS) {
      return _iosVoice;
    } else if (Platform.isAndroid) {
      return _androidVoice;
    }
    return {}; // Return an empty map if the platform is neither iOS nor Android
  }

  PermissionLevel get permissionLevel => _permissionLevel;
  int get accountCreationTime => _accountCreationTime;
  DateTime get dateLastPasswordChange => _dateLastPasswordChange;
  AccountCreationStep get accountCreationStep => _accountCreationStep;
  bool get voicePromptsEnabled => _voicePromptsEnabled;
  bool get realTimeAssistantEnabled => _realTimeAssistantEnabled;

  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  /// UTILITY METHODS
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  // Method checks to see if the user profile has been initialized
  // by checking if key data items exist
  ////////////////////////////////////////////////////////////////////////
  bool isMissingKeyData() {
    return (uid.isEmpty || firstName.isEmpty || lastName.isEmpty || email.isEmpty);
  }

  ////////////////////////////////////////////////////////////////
  // Converts from enum status to string (for DB usage)
  ////////////////////////////////////////////////////////////////
  String getStringFromStep(AccountCreationStep step) {
    if (step == AccountCreationStep.ACC_STEP_ONBOARDING_PROFILE_CONTACT_INFO) return "Contact";
    if (step == AccountCreationStep.ACC_STEP_ONBOARDING_COMPLETE) return "Complete";
    return "Contact";
  }

  ////////////////////////////////////////////////////////////////
  // Converts from String to enum status (for DB usage)
  ////////////////////////////////////////////////////////////////
  AccountCreationStep getStepFromString(String stepStr) {
    if (stepStr == "Contact") return AccountCreationStep.ACC_STEP_ONBOARDING_PROFILE_CONTACT_INFO;
    if (stepStr == "Complete") return AccountCreationStep.ACC_STEP_ONBOARDING_COMPLETE;
    return AccountCreationStep.ACC_STEP_ONBOARDING_COMPLETE;
  }

  ////////////////////////////////////////////////////////////////////////
  // Converts from enum status to string (for DB usage) for
  // permission level
  ////////////////////////////////////////////////////////////////////////
  String _getStringFromPermissionLevel(PermissionLevel permissionLevel) {
    if (permissionLevel == PermissionLevel.PRODUCTION) return "Production";
    if (permissionLevel == PermissionLevel.BETA) return "Beta";
    if (permissionLevel == PermissionLevel.DEVELOPER) return "Developer";
    return "Production";
  }

  ////////////////////////////////////////////////////////////////////////
  // Converts from String to enum status for permission level
  ////////////////////////////////////////////////////////////////////////
  PermissionLevel _getPermissionLevelFromString(String permissionLevelStr) {
    if (permissionLevelStr == "Production") return PermissionLevel.PRODUCTION;
    if (permissionLevelStr == "Beta") return PermissionLevel.BETA;
    if (permissionLevelStr == "Developer") return PermissionLevel.DEVELOPER;
    return PermissionLevel.PRODUCTION;
  }

  ////////////////////////////////////////////////////////////////////////
  // Converts to JSON for saving to noSQL database
  ////////////////////////////////////////////////////////////////////////
  Map<String, dynamic> toJsonForDb() {
    // Create empty map
    Map<String, dynamic> jsonObject = {};

    // Add all fields to the json map
    //dbObject[""] = uid; // FYI: Not currently stored in DB
    jsonObject["first_name"] = firstName;
    jsonObject["last_name"] = lastName;
    jsonObject["email"] = email;
    // Create ttsSettings object
    Map<String, dynamic> ttsSettings = {
      'pitch': pitch,
      'speed': speed,
      'selectedVoices': {
        'ios_voice': _iosVoice,
        'android_voice': _androidVoice,
      },
    };
    jsonObject["ttsSettings"] = ttsSettings;
    jsonObject["email_lowercase"] = email.toLowerCase(); // Added for bf_manage_share_request GCF
    jsonObject["permission_level"] = _getStringFromPermissionLevel(permissionLevel);
    jsonObject["account_creation_time"] = accountCreationTime;
    jsonObject["date_last_password_change"] = _dateLastPasswordChange;
    jsonObject["account_creation_step"] = getStringFromStep(accountCreationStep);
    jsonObject["voice_prompts_enabled"] = voicePromptsEnabled;
    jsonObject["real_time_assistant_enabled"] = realTimeAssistantEnabled;

    // Return the JSON object
    return jsonObject;
  }
}
