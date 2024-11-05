// -----------------------------------------------------------------------
// Filename: screen_unverified_email.dart
// Original Author: Dan Grissom
// Creation Date: 5/21/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the screen that checks that the user
//              has verified their email address.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Dart imports
import 'dart:async';

// Flutter external package imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// App relative file imports
import '../../main.dart';
import '../../util/message_display/snackbar.dart';
import '../../providers/provider_auth.dart';

//////////////////////////////////////////////////////////////////////////
// StateFUL widget which manages state. Simply initializes the
// state object.
//////////////////////////////////////////////////////////////////////////
class ScreenUnverifiedEmail extends ConsumerStatefulWidget {
  const ScreenUnverifiedEmail({super.key});

  @override
  ConsumerState<ScreenUnverifiedEmail> createState() => _ScreenUnverifiedEmailState();
}

//////////////////////////////////////////////////////////////////////////
// The actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////////////
class _ScreenUnverifiedEmailState extends ConsumerState<ScreenUnverifiedEmail> {
  // The "instance variables" managed in this state
  var _isInit = true;
  late ProviderAuth _providerAuth;
  bool isEmailVerified = false;
  Timer? timer;
  User? user = FirebaseAuth.instance.currentUser;

  ////////////////////////////////////////////////////////////////////////
  // Runs the following code once upon initialization
  ////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      checkEmailVerified();
    });
  }

  ////////////////////////////////////////////////////////////////////////
  // Runs the following code once upon initialization
  ////////////////////////////////////////////////////////////////////////
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

  ////////////////////////////////////////////////////////////////////////
  // Gets the current state of the providers for consumption on
  // this page
  ////////////////////////////////////////////////////////////////////////
  _init() async {
    _providerAuth = ref.watch(providerAuth);
  }

  ////////////////////////////////////////////////////////////////////////
  // Resends the email verification email
  ////////////////////////////////////////////////////////////////////////
  Future<void> _resendEmail() async {
    try {
      if (user != null && !user!.emailVerified) {
        await user!.sendEmailVerification();

        if (mounted) {
          Snackbar.show(SnackbarDisplayType.SB_INFO, 'Verification email sent.', context);
        }
      }
    } catch (err) {
      if (mounted) {
        Snackbar.show(SnackbarDisplayType.SB_INFO, 'Please wait 30 seconds before trying again.', context);
      }
    }
  }

  ////////////////////////////////////////////////////////////////////////
  // Checks if the email has been verified
  ////////////////////////////////////////////////////////////////////////
  Future checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await user.reload();
    if (!_providerAuth.emailVerified) {
      setState(() {
        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      });
    }
    if (isEmailVerified) {
      timer?.cancel();
      _providerAuth.emailVerified = true;
    }
  }

  ////////////////////////////////////////////////////////////////////////
  // Primary Flutter method overriden which describes the layout
  // and bindings for this widget.
  ////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  "images/logo.png",
                  height: MediaQuery.of(context).size.height * .1,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Card(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.mark_email_unread_rounded,
                          color: Theme.of(context).inputDecorationTheme.iconColor,
                          size: MediaQuery.of(context).size.width * 0.15,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        "Check your email",
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text:
                                      "An e-mail with an account activation link has been sent to ${FirebaseAuth.instance.currentUser!.email}.\n\nNot you?",
                                  style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge!.color),
                                ),
                                TextSpan(
                                  text: ' Go Back',
                                  style:
                                      TextStyle(color: Theme.of(context).inputDecorationTheme.iconColor, fontSize: 16),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _providerAuth.clearAuthedUserDetailsAndSignout();
                                    },
                                ),
                              ]),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          // SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '\nDid not recieve an email? ',
                                      style:
                                          TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge!.color),
                                    ),
                                    TextSpan(
                                      text: 'Resend.',
                                      style: TextStyle(
                                          color: Theme.of(context).inputDecorationTheme.iconColor, fontSize: 16),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          await _resendEmail();
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
