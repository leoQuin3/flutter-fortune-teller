// -----------------------------------------------------------------------
// Filename: provider_auth.dart
// Original Author: Dan Grissom
// Creation Date: 5/22/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the screen for authenticating users
//              (login, account creation).

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Flutter external package imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
// import 'package:auto_route/auto_route.dart';
// import 'package:provider/provider.dart';

// App relative file imports
import '../../util/message_display/popup_dialogue.dart';
import '../../widgets/auth/widget_password_strength_indicator.dart';
import '../../providers/provider_user_profile.dart';
import '../../util/message_display/snackbar.dart';
import '../../util/logging/app_logger.dart';
import '../../providers/provider_auth.dart';
import '../../models/user_profile.dart';
import '../../theme/colors.dart';
import '../../main.dart';
// import '../../widgets/authentication/cloud_environment_banner_widget.dart';
// import '../../widgets/account/onboarding/onboarding_button.dart';
// import '../../providers/device_preferences_provider.dart';
// import '../../util/message_display/popup_dialogue.dart';
// import '../../providers/user_profile_provider.dart';
// import '../../util/message_display/snackbar.dart';
// import '../../constants/app/testing_keys.dart';
// import '../../util/print/print.dart';
// import '../../theme/colors.dart';

//////////////////////////////////////////////////////////////////
// StateFUL widget which manages state. Simply initializes the
// state object.
//////////////////////////////////////////////////////////////////
class ScreenAuth extends ConsumerStatefulWidget {
  static const routeName = '/auth';

  const ScreenAuth({super.key});

  @override
  ConsumerState<ScreenAuth> createState() => _ScreenAuthState();
}

//////////////////////////////////////////////////////////////////
// The actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////
class _ScreenAuthState extends ConsumerState<ScreenAuth> {
  // The "instance variables" managed in this state
  bool _signInMode = true;
  bool _passwordVisible = false;
  var _isInit = true;
  late ProviderUserProfile _providerUserProfile;
  late ProviderAuth _providerAuth;
  String _strengthText = "";
  Color _strengthColor = CustomColors.statusWarning;
  double _passwordStrength = 0;

  // Finals used in this widget
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
  _init() async {
    _providerUserProfile = ref.watch(providerUserProfile);
    _providerAuth = ref.watch(providerAuth);
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  ////////////////////////////////////////////////////////////////
  // Attempts to either login to existing account or signup for
  // new account.
  ////////////////////////////////////////////////////////////////
  void _submitAuthForm(
    String email,
    String password,
    bool isLogin,
    BuildContext ctx,
  ) async {
    try {
      // Update screen to indicate loading spinner
      setState(() {});

      // If in "login mode", attempt to login with email/password...
      User? user = _auth.currentUser;
      if (isLogin) {
        // Attempt login
        String errorMessage = (await _providerAuth.signinWithPassword(email, password)).trim();

        // If there was an error, display it...otherwise load the profile
        if (errorMessage.isNotEmpty) {
          //Snackbar.show(SnackbarDisplayType.SB_ERROR, errorMessage, false, context);
          setState(() {});
        } else {
          await _providerAuth.loadAuthedUserDetailsUponSignin();
        }

        // }
      } else {
        // ...otherwise, attempt to create a new account
        // Attempt to create a new account
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Send verification e-mail and create initial user profile
        try {
          if (ENFORCE_EMAIL_VERIFICATION) {
            await FirebaseAuth.instance.currentUser?.sendEmailVerification();
          }
          _providerUserProfile.email = user?.email ?? email;
          _providerUserProfile.accountCreationStep = AccountCreationStep.ACC_STEP_ONBOARDING_PROFILE_CONTACT_INFO;
          await _providerUserProfile.writeUserProfileToDb();
          _providerAuth.isSigningIn = false;
        } catch (e) {
          AppLogger.warning("Issue with sending email verification or writing to user profile.  email: $e");
        }

        // ...and send verification email
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();

          // ...and display to user as "Snack bar" pop-up at bottom of screen
          if (mounted) {
            Snackbar.show(SnackbarDisplayType.SB_INFO, 'Check ${user.email} for verification link.', context);
          }
        }
      }
    } on FirebaseAuthException catch (err) {
      // If error, dis-engage loading screen and display to user
      setState(() {});

      // If error occurs, gather error message...
      var message = 'An error occurred, please check your credentials!';
      if (err.message != null) message = err.message!;
      if (mounted) {
        Snackbar.show(SnackbarDisplayType.SB_ERROR, message, ctx);
      }
    }
  }

  ////////////////////////////////////////////////////////////////
  // Does basic validation and attempts to authenticate using the
  // method called in from the parent screen/widget.
  ////////////////////////////////////////////////////////////////
  void _trySubmit() {
    // Unfocus from any controls that may have focus to disengage the keyboard
    FocusScope.of(context).unfocus();

    // If the form validates, save the data and then execute the callback function,
    // which attempts to either login to existing account or signup for new account.
    final isValid = _formKey.currentState!.validate() && _passwordStrength >= .6;
    if (isValid) {
      _formKey.currentState!.save();
      _submitAuthForm(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _signInMode,
        context,
      );
    } else if (_passwordStrength < .6) {
      Snackbar.show(SnackbarDisplayType.SB_ERROR, "Please improve your password strength.", context);
    }
  }

  /* ---------------------------- validatePassword ---------------------------- */
  /// Does a check on the password inputted in the Password form.
  /// [value] is the value inputted by the user.
  /// Returns String if there was an error. Otherwise returns null.
  /// For this form a valid password must do all of the following:
  /// - Be 6 characters in length
  /// - Contain 1 letter
  /// - Contain 1 digit
  /// - Contain 1 symbol
  String? validatePasssword(String? value) {
    /// The password response message. Error messages are added to the end of it.
    String passwordResponse = "Password must have: ";

    /// Has the inputted password tripped an invalidation flag?
    bool invalidPassword = false;

    /// How many invalidation flags have been tripped?
    int errorCount = 0;

    /// Check if there was a password that was entered.
    if (value == null || value.isEmpty) {
      return 'Enter a password.';

      /// Validate the password
    } else {
      /// Make sure the password is at least 6 characters
      if (value.length < 6) {
        passwordResponse += "6 characters";
        invalidPassword = true;
        errorCount += 1;
      }

      /// Make sure the password contains a letter.
      if (!(RegExp(r"(?=.*[a-z])").hasMatch(value) || RegExp(r"(?=.*[A-Z])").hasMatch(value))) {
        if (invalidPassword) {
          passwordResponse += ", letter";
        } else {
          passwordResponse += "letter";
          invalidPassword = true;
        }
        errorCount += 1;
      }

      /// Make sure the password contains a number.
      if (!(RegExp(r"(?=.*\d)").hasMatch(value))) {
        if (invalidPassword) {
          passwordResponse += ", digit";
        } else {
          passwordResponse += "digit";
          invalidPassword = true;
        }
        errorCount += 1;
      }

      /// Make sure the password contains a special character.
      if (!(RegExp(r"(?=.*\W)").hasMatch(value))) {
        if (invalidPassword) {
          passwordResponse += ", symbol";
        } else {
          passwordResponse += "symbol";
          invalidPassword = true;
        }
        errorCount += 1;
      }

      /// Was the password marked as invalid?
      if (invalidPassword) {
        /// Punctuate the end of the error with a period.
        passwordResponse += ".";

        /// The comma checks to see if there was enough errors to add a comma
        /// to the response. (This would be 3)
        if (passwordResponse.contains(", ")) {
          /// Grab the index of the last occuring comma
          int lastIndex = passwordResponse.lastIndexOf(", ");

          /// Replace it with either "and" or ", and" for correct grammar
          String endingPhrase = (errorCount > 2) ? ", and" : " and";
          passwordResponse = passwordResponse.substring(0, lastIndex) +
              endingPhrase +
              passwordResponse.substring(lastIndex + 1, passwordResponse.length);
        }

        return passwordResponse;
      }
      return null;
    }
  }

  /* ------------------------- validateConfirmPassword ------------------------ */
  /// Ensures that the passwords put into confirm password and password fields match.
  /// [value] is the value inputted by the user.
  /// Returns String if there was an error. Otherwise returns null.
  String? validateConfirmPassword(String? value) {
    if (_signInMode) {
      return null;
    }

    /// Check if there was a password typed into the field
    if ((value == null || value.isEmpty)) {
      return 'Confirm your password.';
    }

    /// Check to make sure the passwords match
    else {
      if (_confirmPasswordController.text != _passwordController.text) {
        return "Passwords do not match.";
      }
      return null;
    }
  }

  Widget animatedWidget({
    required Widget child,
    double? height,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [child],
      ),
    );
  }

  void showPopup() {
    PopupDialogue.showTextField(
      "Reset Password",
      "Email",
      context,
      (email) {
        resetPassword(email);
      },
      buttonText: "Reset Email",
      defaultValue: _emailController.text,
    );
  }

  final snackBar = const SnackBar(
    content:
        Text('If you have an account, a Reset Password Email will be sent to you. Remeber to check your spam folder.'),
  );
  Future resetPassword(String email) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'If you have an account, a Reset Password Email will be sent to you. Remember to check your spam folder.'),
          ),
        );
      }
      // if (mounted) context.router.popUntilRoot(); // DTG - Does this work in go router?
      if (mounted) context.go('/');
    } on FirebaseAuthException catch (e) {
      AppLogger.error("Failed to send a reset password email: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Enter a valid email"),
          ),
        );
      }

      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Form(
        key: _formKey,
        child: AutofillGroup(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ///////////////////////////////////////////////////////////////////////
                  // Logo
                  ///////////////////////////////////////////////////////////////////////
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Center(
                      child: Image.asset(
                        "images/logo.png",
                        width: MediaQuery.of(context).size.width * 0.8,
                      ),
                    ),
                  ),
                  Text(
                    "My App",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  ///////////////////////////////////////////////////////////////////////
                  /// Email Text Field
                  ///////////////////////////////////////////////////////////////////////
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: TextFormField(
                      controller: _emailController,
                      autofillHints: const [AutofillHints.username],
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                      onSaved: (value) {},
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                      ),
                    ),
                  ),
                  ///////////////////////////////////////////////////////////////////////
                  /// Password Text Field
                  ///////////////////////////////////////////////////////////////////////
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: TextFormField(
                      onFieldSubmitted: (value) {
                        if (_signInMode) {
                          _trySubmit();
                        }
                      },
                      enableInteractiveSelection: true,
                      controller: _passwordController,
                      autofillHints: const [AutofillHints.password],
                      validator: (value) {
                        if (validatePasssword(value) != null) {
                          return validatePasssword(value);
                        }
                        return null;
                      },
                      onChanged: (context) {
                        _passwordStrength = getPasswordStrength(_passwordController.text);
                        _strengthText = getPasswordStrengthText(_passwordStrength);
                        _strengthColor = getPasswordStrengthColor(_passwordStrength);
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Theme.of(context).inputDecorationTheme.iconColor,
                          ),
                          onPressed: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      onSaved: (value) {},
                      obscureText: !_passwordVisible,
                    ),
                  ),
                  ///////////////////////////////////////////////////////////////////////
                  /// Forgot Password Button
                  ///////////////////////////////////////////////////////////////////////
                  if (_signInMode)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 0),
                      child: TextButton(
                        onPressed: () {
                          showPopup();
                        },
                        child: Align(alignment: Alignment.centerRight, child: const Text("Forgot Password?")),
                      ),
                    ),
                  ///////////////////////////////////////////////////////////////////////
                  /// Password Strength Indicator
                  ///////////////////////////////////////////////////////////////////////
                  if (!_signInMode && _passwordController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: WidgetPasswordStrengthIndicator(
                        passwordStrength: _passwordStrength,
                        passwordText: _strengthText,
                        passwordColor: _strengthColor,
                      ),
                    ),

                  ///////////////////////////////////////////////////////////////////////
                  /// Confirm Password Text Field
                  ///////////////////////////////////////////////////////////////////////
                  if (!_signInMode)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: TextFormField(
                        onFieldSubmitted: (value) {
                          _trySubmit();
                        },
                        controller: _confirmPasswordController,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        enableSuggestions: false,
                        validator: (value) {
                          if (validateConfirmPassword(value) != null) {
                            return validateConfirmPassword(value);
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          suffixIcon: IconButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            icon: Icon(
                              // Based on passwordVisible state choose the icon
                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Theme.of(context).inputDecorationTheme.iconColor,
                            ),
                            onPressed: () {
                              // Update the state i.e. toogle the state of passwordVisible variable
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_passwordVisible,
                      ),
                    ),
                  ///////////////////////////////////////////////////////////////////////
                  /// Sign in Button and Create Account Toggle Button
                  ///////////////////////////////////////////////////////////////////////
                  if (_signInMode)
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          child: ElevatedButton(
                            onPressed: () {
                              _trySubmit();
                            },
                            child: const Text(
                              "Sign In",
                              style: TextStyle(fontSize: 23),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _signInMode = false;
                              });
                            },
                            child: const Text("Create an account"),
                          ),
                        )
                      ],
                    ),
                  ///////////////////////////////////////////////////////////////////////
                  /// Create Account Button and Already Have Account Toggle Button
                  ///////////////////////////////////////////////////////////////////////
                  if (!_signInMode)
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _trySubmit();
                          },
                          child: const Text(
                            "Create Account",
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _signInMode = true;
                            });
                          },
                          child: const Text("Use existing account"),
                        )
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
