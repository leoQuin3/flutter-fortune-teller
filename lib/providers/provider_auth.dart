// -----------------------------------------------------------------------
// Filename: provider_auth.dart
// Original Author: Dan Grissom
// Creation Date: 5/21/2024
// Copyright: (c) 2024 CSC322
// Description: This file checks contains the provider class which manages
//              the authentication state of the user.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Dart imports
import 'dart:async';

// Flutter external package imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// App relative file imports
import '../util/message_display/popup_dialogue.dart';
import '../util/message_display/snackbar.dart';
import '../util/logging/app_logger.dart';
import 'provider_user_profile.dart';

// Constants
const bool ENFORCE_EMAIL_VERIFICATION = false;
const int SIGNIN_TIMEOUT_SECS = 15;

// Enum for authentication state
enum AuthState { UNKNOWN, AUTHENTICATED, UN_AUTHENTICATED }

//////////////////////////////////////////////////////////////////
// State class that manages order variables; extends ChangeNotifier
// ChangeNotifier so it can be accessed in multiple files.
//////////////////////////////////////////////////////////////////
class ProviderAuth extends ChangeNotifier {
  // The "instance variables" managed in provider
  late ProviderUserProfile _providerUserProfile;
  late StreamSubscription<User?>? _authStateSubscription;

  AuthState _authState = AuthState.UNKNOWN;
  bool _authStateJustChanged = false;
  bool _emailVerified = false;
  bool _isSigningIn = false;
  bool _isSigningOut = false;
  bool _isShowingSplash = false;
  int _splashStartTime = 0;
  late BuildContext _context;
  // bool _mobileProfileIsDoc = true; // Assume so until proven otherwise by DB

  ///////////////////////////////////////////////////////////////////
  // Initialize needed providers
  ///////////////////////////////////////////////////////////////////
  void initProviders(ProviderUserProfile providerUserProfile) {
    _providerUserProfile = providerUserProfile;
  }

  ///////////////////////////////////////////////////////////////////
  // Initialization method
  ///////////////////////////////////////////////////////////////////
  setupAuthListener(BuildContext context) async {
    _context = context;
    // Ensure the device preferences are loaded
    // await _devicePrefsProvider.initFromDeviceStorage();

    // Initialize Firebase with the default options (in case not already initialized)
    // Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Listen for auth state changes
    // NOTE: NEVER dispose of this listener as it is always relevant whether
    // the user is logged in or not
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) async {
        _emailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
        // If no real change in state, return
        if (_authState == AuthState.AUTHENTICATED && user != null) {
          return;
        } else if (_authState == AuthState.UN_AUTHENTICATED && user == null) {
          return;
        }

        // If it's been less than 3 seconds since the splash screen started, wait
        // until 3 seconds have passed before showing the next screen
        int splashScreenDuration = 1500;
        if (DateTime.now().millisecondsSinceEpoch - _splashStartTime < splashScreenDuration) {
          await Future.delayed(
              Duration(milliseconds: splashScreenDuration - (DateTime.now().millisecondsSinceEpoch - _splashStartTime)),
              () {});
        }

        // Otherwise, state is new...respond accordingly
        if (user == null) {
          AppLogger.print("Auth state changed: UN_AUTHENTICATED");

          _authState = AuthState.UN_AUTHENTICATED;
          _isShowingSplash = false;
          // loadAuthedUserDetailsUponSignin();
          // _mobileProfileIsDoc = false;
        } else {
          AppLogger.print("Auth state changed: AUTHENTICATED");

          _authState = AuthState.AUTHENTICATED;
          _isShowingSplash = false;
          _isSigningIn = true;
        }

        // If the state changes, notify listeners
        _authStateJustChanged = true;
        notifyListeners();
      },
    );
  }

  ///////////////////////////////////////////////////////////////////
  // Makes sure the user is logged in and has a valid ID token (i.e.,
  // didn't change their password on another device). If they have
  // changed their password after this device was authed, log this
  // device out.
  ///////////////////////////////////////////////////////////////////
  ensurePasswordUpToDate() async {
    // Get the current user's ID token
    IdTokenResult idTokenResult = await FirebaseAuth.instance.currentUser!.getIdTokenResult();
    // DateTime? lastPwChangeTime = _userProfileProvider.dateLastPasswordChange;
    DateTime? lastAuthTime = idTokenResult.authTime;

    // If either time is null, return for now
    if (lastAuthTime == null) return;

    // AppLogger.print("TOKEN - LAST PW CHANGE TIME: ${lastPwChangeTime.toString()}");

    AppLogger.print("TOKEN - LAST AUTH TIME: ${lastAuthTime.toString()}");

    // Whenver the user profile is updated from the DB, first check if the
    // user has authed this device since the last known password change
    // if (lastPwChangeTime.isAfter(lastAuthTime)) {
    //   Snackbar.show(SnackbarDisplayType.SB_INFO, "Logged out due to password change; please log in with your new password", false, _context);
    //   await clearAuthedUserDetailsAndSignout();
    // }
  }

  ensureEmailInFirebaseMatchesProfile(userProfile) async {
    // if (authedUserEmail.isNotEmpty) {
    //   if (authedUserEmail != userProfile.email) {
    //     userProfile.email = authedUserEmail;
    //     await DBUserProfile.writeUserProfile(userProfile);
    //   }
    // }
  }

  Future<String> signinWithPassword(String email, String password) async {
    // Set message
    String errorMessage = "";

    // Re-authenticate the user
    try {
      // Attempt to sign in with email/password
      UserCredential authResult = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw FirebaseAuthException(code: "timeout");
      });
    } catch (e) {
      if (e is FirebaseAuthException) {
        AppLogger.error("FirebaseAuthException: ${e.code}");
        // Check for specific error codes
        FirebaseAuthException fae = e;
        AppLogger.print("FirebaseAuthException: ${fae.code}");
        if (fae.code == "wrong-password" ||
            fae.code == "user-not-found" ||
            fae.code == "invalid-email" ||
            fae.code == "INVALID_LOGIN_CREDENTIALS" ||
            fae.code == "invalid-credential") {
          errorMessage = "Email/Password is incorrect - please check your credentials and try again";
        } else if (fae.code == "too-many-requests") {
          errorMessage = "Too many failed login attempts - please try again later";
        } else if (fae.code == "timeout") {
          errorMessage = "Login attempt took too long - please check internet connection and try again";
        } else if (fae.code == "network-request-failed") {
          errorMessage = "An network request error occurred - please check internet connection and try again";
        } else {
          errorMessage =
              "An unknown error occurred during authentication - please check internet connection and try again";
        }
      }
    }

    // Display error message if there is one
    if (errorMessage.isNotEmpty) {
      Snackbar.show(SnackbarDisplayType.SB_ERROR, errorMessage, _context);
    }

    // Return error message
    return errorMessage;
  }

  ///////////////////////////////////////////////////////////////////
  // Confirms user's current password (if one was passed in) and then
  // updates the user's password with the new password; returns an empty
  // string if successful and an error message if not.
  ///////////////////////////////////////////////////////////////////
  Future<String> updatePassword(String newPassword, {String? curPassword}) async {
    // Before trying anything with Firestore, do some basic validation
    String errorMessage = _validatePasssword(newPassword);
    if (errorMessage.isNotEmpty) {
      return errorMessage;
    }

    // Attempt to change password
    try {
      // Init variables
      late AuthCredential authCredential;
      User user = FirebaseAuth.instance.currentUser!;

      // If they passed an current password, then validate the current password
      // before trying to change it
      if (curPassword != null) {
        user = FirebaseAuth.instance.currentUser!;
        authCredential = EmailAuthProvider.credential(email: user.email!, password: curPassword);
        UserCredential? authResult = await user.reauthenticateWithCredential(authCredential);
        user = authResult.user!;
      }

      // If we made it here, the user is authenticated and we can update the password
      DateTime dateLastPasswordChange = DateTime.now().subtract(const Duration(seconds: 5));
      await user.updatePassword(newPassword);

      // Re-auth with the new password (not completely necessary)
      authCredential = EmailAuthProvider.credential(email: user.email!, password: newPassword);
      await user.reauthenticateWithCredential(authCredential);

      // Password has been updated, we should now log the password change time in the user profile
      // so we can sign out any other instances that are logged in
      // _userProfileProvider.dateLastPasswordChange = dateLastPasswordChange;
    } catch (e) {
      if (e is FirebaseAuthException) {
        // Check for specific error codes
        FirebaseAuthException fae = e;
        if (fae.code == "wrong-password") {
          errorMessage = "Current password is incorrect";
        } else if (fae.code == "weak-password") {
          errorMessage = fae.message?.toString() ?? "Password is too weak";
        } else if (fae.code == "requires-recent-login") {
          errorMessage = "Please re-login to change your password";
        } else {
          errorMessage = "An error occurred checking current password - please try again";
        }
      }
    }

    // Return error message
    return errorMessage;
  }

  ////////////////////////////////////////////////////////////////////////////////
  // Does a check on the password inputted in the Password form. [value] is the
  // value inputted by the user.
  //
  // For this form a valid password must do all of the following:
  // - Be 6 characters in length
  // - Contain 1 letter
  // - Contain 1 digit
  // - Contain 1 symbol
  //
  // Returns: Returns non-empty string if there was an error. Otherwise returns
  // empty String.
  ////////////////////////////////////////////////////////////////////////////////
  String _validatePasssword(String pwCandidate) {
    // The password response message. Error messages are added to the end of it.
    String passwordResponse = "Password must have: ";

    // Has the inputted password tripped an invalidation flag?
    bool invalidPassword = false;

    // How many invalidation flags have been tripped?
    int errorCount = 0;

    // Check if there was a password that was entered.
    if (pwCandidate.isEmpty) {
      return 'Enter a password.';
    } else {
      // Validate the password
      // Make sure the password is at least 6 characters
      if (pwCandidate.length < 6) {
        passwordResponse += "6 characters";
        invalidPassword = true;
        errorCount += 1;
      }

      // Make sure the password contains a letter.
      if (!(RegExp(r"(?=.*[a-z])").hasMatch(pwCandidate) || RegExp(r"(?=.*[A-Z])").hasMatch(pwCandidate))) {
        if (invalidPassword) {
          passwordResponse += ", letter";
        } else {
          passwordResponse += "letter";
          invalidPassword = true;
        }
        errorCount += 1;
      }

      // Make sure the password contains a number.
      if (!(RegExp(r"(?=.*\d)").hasMatch(pwCandidate))) {
        if (invalidPassword) {
          passwordResponse += ", digit";
        } else {
          passwordResponse += "digit";
          invalidPassword = true;
        }
        errorCount += 1;
      }

      // Make sure the password contains a special character.
      if (!(RegExp(r"(?=.*\W)").hasMatch(pwCandidate))) {
        if (invalidPassword) {
          passwordResponse += ", symbol";
        } else {
          passwordResponse += "symbol";
          invalidPassword = true;
        }
        errorCount += 1;
      }

      // Was the password marked as invalid?
      if (invalidPassword) {
        // Punctuate the end of the error with a period.
        passwordResponse += ".";

        // The comma checks to see if there was enough errors to add a comma
        // to the response. (This would be 3)
        if (passwordResponse.contains(", ")) {
          // Grab the index of the last occuring comma
          int lastIndex = passwordResponse.lastIndexOf(", ");

          /// Replace it with either "and" or ", and" for correct grammar
          String endingPhrase = (errorCount > 2) ? ", and" : " and";
          passwordResponse = passwordResponse.substring(0, lastIndex) +
              endingPhrase +
              passwordResponse.substring(lastIndex + 1, passwordResponse.length);
        }

        return passwordResponse;
      }

      // Password was good, return empty string
      return "";
    }
  }

  ////////////////////////////////////////////////////////////////////////////////
  // Reauthenticates the user with the provided email and password.
  //
  // Parameters:
  // - email: The email of the user.
  // - password: The password of the user.
  //
  // Returns: A Future that completes with a boolean indicating the success status of the reauthentication.
  ////////////////////////////////////////////////////////////////////////////////
  Future<bool> reauthenticateUser(String password) async {
    try {
      User user = FirebaseAuth.instance.currentUser!;
      AuthCredential authCredential = EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(authCredential);
    } catch (e) {
      return false;
    }

    // Return true if we made it here
    return true;
  }

  ///////////////////////////////////////////////////////////////////
  // Confirms user's current password and then updates the user's
  // password with the new password; returns an empty string if
  // successful and an error message if not.
  ///////////////////////////////////////////////////////////////////
  Future<String> updateEmail(String newEmail, BuildContext context, {String? curPassword}) async {
    // Set message
    String errorMessage = "";

    // Re-authenticate the user
    try {
      // Init variables
      late AuthCredential authCredential;
      User user = FirebaseAuth.instance.currentUser!;

      // If they passed an current password, then validate the current password
      // before trying to change it
      if (curPassword != null) {
        user = FirebaseAuth.instance.currentUser!;
        authCredential = EmailAuthProvider.credential(email: user.email!, password: curPassword);
        UserCredential? authResult = await user.reauthenticateWithCredential(authCredential);
        user = authResult.user!;
      }

      // If we made it here, the user is authenticated and we can update the email
      await user.verifyBeforeUpdateEmail(newEmail);

      // Inform user that they need to check their e-mail to confirm the change
      Snackbar.show(SnackbarDisplayType.SB_INFO, "Check $newEmail to verify e-mail", context);
      clearAuthedUserDetailsAndSignout();

      // DO NOT DO B/C of E-MAIL VALIDATION: Email has been updated, we should now write to DB
      //_userProfileProvider.email = newEmail;
      //_userProfileProvider.writeUserProfileToDb();
      //_userProfileProvider.syncProfileNameAndEmailToAcceptedShareRequests();
    } catch (e) {
      if (e is FirebaseAuthException) {
        // Check for specific error codes
        FirebaseAuthException fae = e;
        if (fae.code == "wrong-password") {
          errorMessage = "Current password is incorrect";
        } else if (fae.code == "invalid-email" || (fae.message?.contains("INVALID_NEW_EMAIL") ?? false)) {
          errorMessage = "$newEmail is not a valid e-mail address";
        } else if (fae.code == "email-already-in-use") {
          errorMessage = fae.message?.toString() ?? "$newEmail is already in use by another user";
        } else if (fae.code == "email-already-in-use") {
          errorMessage = fae.message?.toString() ?? "$newEmail is already in use by another user";
        } else {
          errorMessage = "An error occurred updating account - please try again";
          AppLogger.error(e.toString());
          AppLogger.error("fae.code = ${fae.code}");
        }
      } else {
        errorMessage = "An error occurred updating account - please try again";
        AppLogger.error(e.toString());
      }
    }

    // Return error message
    return errorMessage;
  }

  ///////////////////////////////////////////////////////////////////
  // After prompt is confirmed, clears the authenticated user deatils
  // (in all the providers) and logs user out.
  ///////////////////////////////////////////////////////////////////
  promptAndClearAuthedUserDetailsAndSignout() async {
    // Prompt user to logout
    bool confirmed = await PopupDialogue.showConfirm(
          "Are you sure you want to log out?",
          _context,
        ) ??
        false;

    // If they confirmed, logout
    if (confirmed) await clearAuthedUserDetailsAndSignout();
  }

  ///////////////////////////////////////////////////////////////////
  // Clears the authenticated user deatils (in all the providers)
  // and logs user out.
  ///////////////////////////////////////////////////////////////////
  clearAuthedUserDetailsAndSignout() async {
    // Clear all user details/data
    await _clearAuthedUserDetails();

    // Wait 1 second before calling sign out to allow for listeners to be cancelled before
    // firebase unauths
    Future.delayed(const Duration(seconds: 1), () async {
      await FirebaseAuth.instance.signOut();
      // await Firebase.app().delete();
      _emailVerified = false;
      isSigningOut = false;
      notifyListeners();
    });
  }

  ///////////////////////////////////////////////////////////////////
  // Clears the authenticated user deatils (in all the providers)
  ///////////////////////////////////////////////////////////////////
  _clearAuthedUserDetails() async {
    // Set a flag to indicate that the user is logging out
    isSigningOut = true;
    // _context.router.popUntilRoot();

    // Wipe data stored in providers
    await _providerUserProfile.wipeAndCancelDbStream();

    // Terminate the current instance of Firestore and clear any persistant state (cache) being stored locally
    await FirebaseFirestore.instance.terminate();
    await FirebaseFirestore.instance.clearPersistence();
  }

  ///////////////////////////////////////////////////////////////////
  // Load all providers/data (to be called upon successful
  // authentication
  ///////////////////////////////////////////////////////////////////
  loadAuthedUserDetailsUponSignin() async {
    // // Load provider data from DB if needed
    await _providerUserProfile.fetchUserProfileIfNeeded();
    await _providerUserProfile.fetchUserProfileImageIfNeeded();
  }

  //////////////////////////////////////////////////////////////
  // Statics/Getters/Setters
  //////////////////////////////////////////////////////////////
  AuthState get authState => _authState;
  bool get justLoggedIn => _authStateJustChanged && _authState == AuthState.AUTHENTICATED;

  bool get emailVerified => _emailVerified;
  set emailVerified(bool value) {
    _emailVerified = value;
    notifyListeners();
  }

  bool get isSigningIn => _isSigningIn;
  set isSigningIn(bool value) {
    _isSigningIn = value;
    notifyListeners();
  }

  bool get isSigningOut => _isSigningOut;
  set isSigningOut(bool value) {
    _isSigningOut = value;
    notifyListeners();
  }

  bool get isShowingSplash => _isShowingSplash;
  set isShowingSplash(bool value) {
    _isShowingSplash = value;

    // If showing the splash screen, activate a new splash screen widget
    if (_isShowingSplash) {
      AppLogger.debug("SPLASH STARTING...");
      // Get the current timestamp in millis
      _splashStartTime = DateTime.now().millisecondsSinceEpoch;
    } else {
      AppLogger.debug("SPLASH ENDING...");
      notifyListeners();
    }
  }

  String get authedUserEmail => FirebaseAuth.instance.currentUser?.email ?? "";
}
