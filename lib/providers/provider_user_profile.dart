// -----------------------------------------------------------------------
// Filename: provider_user_profile.dart
// Original Author: Dan Grissom
// Creation Date: 5/22/2024
// Copyright: (c) 2024 CSC322
// Description: This file checks contains the provider class which manages
//              the user profile state of the user.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Dart imports
import 'dart:io';

// Flutter external package imports
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

// App relative file imports
import '../db_helpers/db_user_profile.dart';
import '../models/user_profile.dart';
import 'provider_auth.dart';

//////////////////////////////////////////////////////////////////////////
// State class that manages order variables; extends ChangeNotifier
// ChangeNotifier so it can be accessed in multiple files.
//////////////////////////////////////////////////////////////////////////
class ProviderUserProfile extends ChangeNotifier {
  // The "instance variables" managed in this state
  UserProfile _userProfile = UserProfile.empty();
  ImageProvider? _userImage;
  bool _dataLoaded = false;
  bool _imageLoaded = false;
  bool _internetIssues = false;
  bool _userChangeInProgress = false;
  late ProviderAuth _providerAuth; // Needed to update signin status

  ////////////////////////////////////////////////////////////////////////
  // GETTERS/SETTERS
  ////////////////////////////////////////////////////////////////////////
  bool get dataLoaded => _dataLoaded;

  PermissionLevel get permissionLevel => _userProfile.permissionLevel;

  String get uid => _userProfile.uid;
  set uid(String value) {
    _userProfile.uid = value;
    notifyListeners();
  }

  String get firstName => _userProfile.firstName;
  set firstName(String value) {
    _userProfile.firstName = value;
    notifyListeners();
  }

  String get lastName => _userProfile.lastName;
  set lastName(String value) {
    _userProfile.lastName = value;
    notifyListeners();
  }

  String get wholeName => "${_userProfile.firstName} ${_userProfile.lastName}";

  String get email => _userProfile.email;
  set email(String value) {
    _userProfile.email = value;
    notifyListeners();
  }

  int get accountCreationTime => _userProfile.accountCreationTime;
  set accountCreation(int value) {
    _userProfile.accountCreationTime = value;
    notifyListeners();
  }

  ImageProvider? get userImage => _userImage;
  set userImage(ImageProvider? value) {
    _userImage = value;
    notifyListeners();
  }

  bool get userChangeInProgress => _userChangeInProgress;
  set userChangeInProgress(bool value) {
    _userChangeInProgress = value;
    notifyListeners();
  }

  DateTime get dateLastPasswordChange => _userProfile.dateLastPasswordChange;
  set dateLastPasswordChange(DateTime value) {
    _userProfile.dateLastPasswordChange = value;
    writeUserProfileToDb();
  }

  bool get internetIssues => _internetIssues;
  set internetIssues(bool value) {
    _internetIssues = value;
    notifyListeners();
  }

  AccountCreationStep get accountCreationStep => _userProfile.accountCreationStep;
  set accountCreationStep(AccountCreationStep value) {
    _userProfile.accountCreationStep = value;
    notifyListeners();
  }

  double get pitch => _userProfile.pitch;
  set pitch(double value) {
    _userProfile.pitch = value;
    notifyListeners();
  }

  double get speed => _userProfile.speed;
  set speed(double value) {
    _userProfile.speed = value;
    notifyListeners();
  }

  Map<String, dynamic> get voice => _userProfile.voice;
  set voice(Map<String, dynamic> value) {
    _userProfile.voice = value;
    notifyListeners();
  }

  bool get voicePromptsEnabled => _userProfile.voicePromptsEnabled;
  set voicePromptsEnabled(bool value) {
    _userProfile.voicePromptsEnabled = value;
    notifyListeners();
  }

  bool get realTimeAssistantEnabled => _userProfile.realTimeAssistantEnabled;
  set realTimeAssistantEnabled(bool value) {
    _userProfile.realTimeAssistantEnabled = value;
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  // UTILITY METHODS
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////
  // This method initializes the UserProfileProvider with the
  // ProviderAuth so that it can be utilized later.
  ////////////////////////////////////////////////////////////////////////
  Future<void> initProviders(ProviderAuth providerAuth) async {
    _providerAuth = providerAuth;
    providerAuth.isSigningOut = false;

    // Ensure the proper permissions are granted
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }

    status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  ////////////////////////////////////////////////////////////////////////
  // Returns true if the user is a developer (examining both the old and
  // new ways to check)
  ////////////////////////////////////////////////////////////////////////
  bool isDeveloper() {
    return permissionLevel == PermissionLevel.DEVELOPER;
  }

  ////////////////////////////////////////////////////////////////////////
  // This function clears all of the information stored in this
  // provider
  ////////////////////////////////////////////////////////////////////////
  Future<void> wipeAndCancelDbStream({bool? deletingAccount}) async {
    _userProfile = UserProfile.empty();
    _userImage = null;
    _dataLoaded = false;
    _imageLoaded = false;
    _internetIssues = false;
    await DBUserProfile.cancelProfileUpdateStream();
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////////////
  // This function updates the entire user profile to the one being
  // passed in.
  ////////////////////////////////////////////////////////////////////////
  Future<void> updateUserProfile(UserProfile userProfile) async {
    // Whenver the user profile is updated from the DB, first check if the
    // user has authed this device since the last known password change
    await _providerAuth.ensurePasswordUpToDate();

    // If the user is authed, ensure that the email in firebase
    // is the same as the one in the user profile (it may be out of
    // sync if it was changed via the app but the user clicked to cancel
    // via a confirmation e-mail to the old e-mail)
    //await _authProvider.ensureEmailInFirebaseMatchesProfile(userProfile);

    // Update primary variables
    _userProfile = userProfile;
    _dataLoaded = true;

    // Update display name and image if needed
    await fetchUserProfileImageIfNeeded();
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  // CLOUD ACCESS METHODS
  ////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////////////////
  // Get the user profile image from the DB helper (in GCS) and notify listeners if it is not
  // already there (notify is triggered by called method, so not done here)
  ////////////////////////////////////////////////////////////////////////////////////////////
  Future<bool> fetchUserProfileImageIfNeeded() async {
    // Ensure profile data (uid) has been loaded first
    if (!dataLoaded) {
      return false;
    }

    // Load image if not already loaded
    if (!_imageLoaded) {
      if (await DBUserProfile.fetchUserProfileImageAndSyncProvider(this)) {
        _imageLoaded = true;
        return true;
      } else {
        return false;
      }
    }

    // If made it here, we already have a profile
    return true;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  // Takes in a file (to an image) and uploads as new user profile image using the DB helper
  // (in GCS) and notifies listeners (notify is triggered by called method, so not done here)
  ////////////////////////////////////////////////////////////////////////////////////////////
  uploadAndSetNewUserProfileImage(File imageFile) async {
    // Convert file to image and set (which notifies listeners) to local profile picture
    userImage = FileImage(imageFile);

    // Upload image to Google Cloud Storage
    await DBUserProfile.uploadNewUserProfileImage(imageFile, this);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  // Removes user profile image using the DB helper (in GCS) and notifies listeners
  // (notify is triggered by called method, so not done here)
  ////////////////////////////////////////////////////////////////////////////////////////////
  removeUserProfileImage() async {
    // Update image
    userImage = null;

    // Remove image from Google Cloud Storage
    await DBUserProfile.deleteUserProfileImage(this);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  // Get the user profile from the DB helper and notify listeners if it is not already there
  // (notify is triggered by called method, so not done here)
  ////////////////////////////////////////////////////////////////////////////////////////////
  Future<bool> fetchUserProfileIfNeeded() async {
    // If data is missing (or empty), fetch profile
    if (_userProfile.isMissingKeyData() || !_dataLoaded) {
      bool success = await DBUserProfile.fetchUserProfileAndSyncProvider(this);
      if (success) {
        _dataLoaded = true;
      }
      return success;
    }

    // If made it here, we already have a profile
    return true;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  // Writes the user profile to the DB using the DB helper.
  ////////////////////////////////////////////////////////////////////////////////////////////
  Future<bool> writeUserProfileToDb({merge = true}) async {
    bool success = await DBUserProfile.writeUserProfile(_userProfile, merge: merge);
    _dataLoaded = true;
    notifyListeners();
    return success;
  }

  ////////////////////////////////////////////////////////////////////////////////
  // Deletes the account data associated with the current user.
  //
  // This method deletes the account data by calling the corresponding method in
  // the DBUserProfile class.
  ////////////////////////////////////////////////////////////////////////////////
  Future<void> deleteAccountData() async {
    await DBUserProfile.deleteAccountData(); // Delete the account data associated with the current user
  }
}
