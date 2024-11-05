// -----------------------------------------------------------------------
// Filename: screen_login_validation.dart
// Original Author: Dan Grissom
// Creation Date: 5/21/2024
// Copyright: (c) 2024 CSC322
// Description: This file checks the users authentication status and
//              ensures they progress along the proper screen sequence.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Dart imports
import 'dart:async';

// Flutter external package imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// App relative file imports
import '../../widgets/general/widget_scrollable_background.dart';
import '../../widgets/navigation/widget_primary_scaffold.dart';
import '../../widgets/general/widget_annotated_loading.dart';
import '../../providers/provider_user_profile.dart';
import '../../providers/provider_auth.dart';
import '../../models/user_profile.dart';
import 'screen_unverified_email.dart';
import 'screen_profile_setup.dart';
import 'screen_splash.dart';
import 'screen_auth.dart';
import '../../main.dart';

//////////////////////////////////////////////////////////////////////////
// StateFUL widget which manages state. Simply initializes the
// state object.
//////////////////////////////////////////////////////////////////////////
class ScreenLoginValidation extends ConsumerStatefulWidget {
  // Route name declaration
  static const routeName = '/';

  const ScreenLoginValidation({Key? key}) : super(key: key);

  @override
  ConsumerState<ScreenLoginValidation> createState() => _ScreenLoginValidationState();
}

//////////////////////////////////////////////////////////////////
// The actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////
class _ScreenLoginValidationState extends ConsumerState<ScreenLoginValidation> {
  // The "instance variables" managed in this state
  var _isInit = true;
  late ProviderAuth _providerAuth;
  late ProviderUserProfile _providerUserProfile;
  bool isEmailVerified = false;
  Timer? timer;

  ////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////
  /// Helper Methods (for state object)
  ////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////
  // Initialize the app
  ////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////
  // Gets the current state of the providers for consumption on
  // this page
  ////////////////////////////////////////////////////////////////
  _init() async {
    // Load providers
    _providerUserProfile = ref.watch(providerUserProfile);
    _providerAuth = ref.watch(providerAuth);

    // Set splash screen flag and attempt authentication
    _providerAuth.isShowingSplash = true;
    await _providerAuth.setupAuthListener(context);
  }

  ////////////////////////////////////////////////////////////////
  // Runs the following code once upon initialization
  ////////////////////////////////////////////////////////////////
  @override
  void didChangeDependencies() {
    // If first time running this code, update provider settings
    if (_isInit) {
      _init();
    }

    // Now initialized; run super method
    _isInit = false;
    super.didChangeDependencies();
  }

  ////////////////////////////////////////////////////////////////
  // Gets the widget to show based on the current state of the app
  ////////////////////////////////////////////////////////////////
  Widget _getWidgetToShow() {
    // if (true) return const ScreenProfileSetup();
    // const WidgetAnnotatedLoading(loadingText: "Loading...")

    if (_providerAuth.isShowingSplash) {
      return const ScreenSplash();
    } else if (_providerAuth.authState == AuthState.UNKNOWN) {
      return const WidgetAnnotatedLoading(loadingText: "Authenticating User...");
    } else if (_providerAuth.authState == AuthState.UN_AUTHENTICATED) {
      return const ScreenAuth();
    } else if (ENFORCE_EMAIL_VERIFICATION &&
        _providerAuth.authState == AuthState.AUTHENTICATED &&
        !_providerAuth.emailVerified &&
        _providerUserProfile.permissionLevel != PermissionLevel.DEVELOPER) {
      return const ScreenUnverifiedEmail();
    } else if (_providerAuth.authState == AuthState.AUTHENTICATED) {
      // If authenticated, show widgets based on other flags
      if (_providerAuth.isSigningOut) {
        return const WidgetAnnotatedLoading(loadingText: "Signing Out...");
      }
      // else if (_providerUserProfile.internetIssues) {
      //   return const InternetIssuesWidget();
      // }
      else if (!_providerUserProfile.dataLoaded) {
        _providerAuth.loadAuthedUserDetailsUponSignin();
        return WidgetAnnotatedLoading(
          loadingText: "Loading Profile...",
          timeOutEnabled: true,
          timeOutTextPrefix: "Loading profile",
          //timeOutSignsOut: true,
          timeOutCallback: () => _providerUserProfile.internetIssues = true,
        );
      } else if (_providerUserProfile.accountCreationStep ==
          AccountCreationStep.ACC_STEP_ONBOARDING_PROFILE_CONTACT_INFO) {
        return const ScreenProfileSetup(
          isAuth: true,
        );
      } else {
        return const WidgetPrimaryScaffold();
      }
    } else {
      return const WidgetAnnotatedLoading(
        loadingText: "Loading...",
        timeOutEnabled: true,
        timeOutTextPrefix: "Loading",
        timeOutSignsOut: true,
      );
    }
  }

  ////////////////////////////////////////////////////////////////
  // Primary Flutter method overriden which describes the layout
  // and bindings for this widget.
  ////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    // If auth state just chagned to authenticated, load user details
    // if (_providerAuth.justLoggedIn) {
    //   _providerAuth.loadAuthedUserDetailsUponSignin();
    // }

    // Return the widget to show
    return Scaffold(
      body: Consumer(
        builder: (context, watch, child) {
          _providerAuth = ref.watch(providerAuth);
          _providerUserProfile = ref.watch(providerUserProfile);
          bool isLoggedIn = _providerAuth.authState == AuthState.AUTHENTICATED &&
              _providerUserProfile.dataLoaded &&
              _providerUserProfile.accountCreationStep == AccountCreationStep.ACC_STEP_ONBOARDING_COMPLETE;
          return ScrollableBackground(
            child: _getWidgetToShow(),
            padding: isLoggedIn ? 0 : 20,
          );
        },
      ),
    );
  }
}
