// -----------------------------------------------------------------------
// Filename: screen_provider_setup.dart
// Original Author: Dan Grissom
// Creation Date: 5/27/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the screen for setting up the user's
//              profile.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Dart imports
import 'dart:io';

// Flutter external package imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// App relative file imports
import '../../widgets/general/widget_profile_avatar.dart';
import '../../providers/provider_user_profile.dart';
import '../../util/message_display/snackbar.dart';
import '../../util/logging/app_logger.dart';
import '../../providers/provider_auth.dart';
import '../../models/user_profile.dart';
import '../../theme/colors.dart';
import '../../main.dart';

//////////////////////////////////////////////////////////////////
// StateFUL widget which manages state. Simply initializes the
// state object.
//////////////////////////////////////////////////////////////////
class ScreenProfileSetup extends ConsumerStatefulWidget {
  static const routeName = '/profileSetup';

  // Final variables passed in as parameters
  final bool isAuth;

  const ScreenProfileSetup({super.key, required this.isAuth});

  @override
  ConsumerState<ScreenProfileSetup> createState() => _ScreenProfileSetupState();
}

//////////////////////////////////////////////////////////////////
// The actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////
class _ScreenProfileSetupState extends ConsumerState<ScreenProfileSetup> {
  // The "instance variables" managed in this state
  var _isInit = true;
  late ProviderUserProfile _providerUserProfile;
  late ProviderAuth _providerAuth;
  File? pickedImage;
  bool editingPicture = false;

  // Finals used in this widget
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  ////////////////////////////////////////////////////////////////
  // Runs the following code once upon initialization
  ////////////////////////////////////////////////////////////////
  @override
  void didChangeDependencies() {
    // If first time running this code, update provider settings
    if (_isInit) {
      _init();

      //Update text fields to contain current names if set
      if (!widget.isAuth) {
        _firstNameController.text = _providerUserProfile.firstName;
        _lastNameController.text = _providerUserProfile.lastName;
      }

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
    // Get the providers
    _providerUserProfile = ref.watch(providerUserProfile);
    _providerAuth = ref.watch(providerAuth);
  }

  @override
  void initState() {
    super.initState();
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

        // If there was an error, display it...otherwise return true for success
        if (errorMessage.isNotEmpty) {
          //Snackbar.show(SnackbarDisplayType.SB_ERROR, errorMessage, false, context);
          setState(() {});
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
          await FirebaseAuth.instance.currentUser?.sendEmailVerification();
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
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();

      // Update profile information and write to database
      _providerUserProfile.firstName = _firstNameController.text.trim();
      _providerUserProfile.lastName = _lastNameController.text.trim();
      _providerUserProfile.accountCreationStep = AccountCreationStep.ACC_STEP_ONBOARDING_COMPLETE;
      _providerUserProfile.writeUserProfileToDb();

      //If saving a snack-bar will appear and will pop the navigator
      if (!widget.isAuth) {
        Snackbar.show(SnackbarDisplayType.SB_SUCCESS, "Profile Updated", context);
        context.pop();
      }
    }
  }

  ////////////////////////////////////////////////////////////////
  // Upload profile image to Firebase Storage
  ////////////////////////////////////////////////////////////////
  Future uploadProfileImage(String? uid) async {
    if (pickedImage != null) {
      final file = File(pickedImage!.path);
      await _providerUserProfile.uploadAndSetNewUserProfileImage(file);
    }
    setState(() {
      editingPicture = false;
    });
    Snackbar.show(SnackbarDisplayType.SB_SUCCESS, 'Profile Photo Saved Sucessfully', context);
    // Get the file that was chosen
  }

  ////////////////////////////////////////////////////////////////
  // Pick an image from the camera roll
  ////////////////////////////////////////////////////////////////
  Future pickImage() async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 300,
        maxWidth: 300,
        imageQuality: 100,
      );
      if (pickedImage == null) return;

      final imageTemporary = File(pickedImage.path);
      setState(() => this.pickedImage = imageTemporary);
      uploadProfileImage(_providerUserProfile.uid);
    } on PlatformException catch (e) {
      AppLogger.error('Failed to pick image: $e');
    }
  }

  ////////////////////////////////////////////////////////////////
  // Pick an image from the camera
  ////////////////////////////////////////////////////////////////
  Future takeImage() async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 10,
      );
      if (pickedImage == null) return;
      final imageTemporary = File(pickedImage.path);
      setState(() => this.pickedImage = imageTemporary);
      uploadProfileImage(_providerUserProfile.uid);
    } on PlatformException catch (e) {
      AppLogger.error('Failed to pick image: $e');
    }
  }

  ////////////////////////////////////////////////////////////////
  //Makes the buttons visible that allow you too take a picture or
  // select from camera roll
  ////////////////////////////////////////////////////////////////
  void setEditVisibile() {
    setState(() {
      editingPicture = !editingPicture;
      if (!editingPicture) {
        pickedImage = null;
      }
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  // Helper methods to create an edit icon
  ////////////////////////////////////////////////////////////////////////////////////////////
  Widget getEditIcon(Color color) => buildCircle(
        color: Theme.of(context).inputDecorationTheme.iconColor!,
        all: 5,
        child: buildCircle(
          color: color,
          all: 8,
          child: Icon(
            editingPicture ? Icons.edit_off_rounded : Icons.edit_rounded,
            size: 22,
            color: Colors.white,
          ),
        ),
      );
  Widget buildCircle({required Widget child, required double all, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      padding: EdgeInsets.all(all),
      child: child,
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  // Remove profile picture via provider
  ////////////////////////////////////////////////////////////////////////////////////////////
  Future removeProfileImage() async {
    _providerUserProfile.removeUserProfileImage();
    setState(() {
      pickedImage = null;
      editingPicture = false;
    });
  }

  //////////////////////////////////////////////////////////////////////////
  // Primary Flutter method overriden which describes the layout
  // and bindings for this widget.
  //////////////////////////////////////////////////////////////////////////
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
                mainAxisAlignment: widget.isAuth ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  ///////////////////////////////////////////////////////////////////////
                  // Logo
                  ///////////////////////////////////////////////////////////////////////
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: 5),
                  //   child: Image.asset(
                  //     'images/logo.png',
                  //     height: MediaQuery.of(context).size.width * .5,
                  //   ),
                  // ),
                  ///////////////////////////////////////////////////////////////////////
                  // Profile Avatar
                  ///////////////////////////////////////////////////////////////////////
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30, top: 20),
                      child: GestureDetector(
                        onTap: () => setEditVisibile(),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ProfileAvatar(
                                  radius: 100,
                                  userImage: pickedImage == null
                                      ? _providerUserProfile.userImage
                                      : Image.file(pickedImage!).image,
                                  userWholeName: _providerUserProfile.wholeName),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: getEditIcon(
                                  Theme.of(context).inputDecorationTheme.iconColor ?? CustomColors.statusInfo),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ///////////////////////////////////////////////////////////////////////
                  // Profile Image Edit Buttons
                  ///////////////////////////////////////////////////////////////////////
                  if (editingPicture)
                    Wrap(
                      runSpacing: 10,
                      spacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              backgroundColor: CustomColors.statusInfo,
                              foregroundColor: Colors.white,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 5),
                                Text("Gallery", style: TextStyle(fontSize: 15)),
                              ],
                            ),
                            // onPressed: () => pickImage(ImageSource.gallery, context),
                            onPressed: () => pickImage(),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            backgroundColor: CustomColors.statusInfo,
                            foregroundColor: Colors.white,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  CupertinoIcons.photo_camera,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text("Capture", style: TextStyle(fontSize: 15)),
                            ],
                          ),
                          onPressed: () => takeImage(),
                          // onPressed: () => pickImage(ImageSource.camera, context),
                        ),
                        if (_providerUserProfile.userImage != null)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              backgroundColor: CustomColors.statusInfo,
                              foregroundColor: Colors.white,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Icon(
                                    CupertinoIcons.delete,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text("Delete", style: TextStyle(fontSize: 15)),
                              ],
                            ),
                            onPressed: () => removeProfileImage(),
                            // onPressed: () => pickImage(ImageSource.camera, context),
                          ),
                      ],
                    ),
                  if (pickedImage != null && editingPicture)
                    ElevatedButton(
                      onPressed: () {
                        if (pickedImage != null) {
                          uploadProfileImage(_providerUserProfile.uid);
                        }
                        setState(() {
                          editingPicture = false;
                        });
                      },
                      child: const Text("Upload Image"),
                    ),
                  ///////////////////////////////////////////////////////////////////////
                  // First Name Text Field
                  ///////////////////////////////////////////////////////////////////////
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: TextFormField(
                      controller: _firstNameController,
                      autofillHints: const [AutofillHints.givenName],
                      autocorrect: false,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a first name.';
                        }
                        return null;
                      },
                      onSaved: (value) {},
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                      ),
                    ),
                  ),
                  ///////////////////////////////////////////////////////////////////////
                  // Last Name Text Field
                  ///////////////////////////////////////////////////////////////////////
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: TextFormField(
                      controller: _lastNameController,
                      autofillHints: const [AutofillHints.familyName],
                      autocorrect: false,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a last name.';
                        }
                        return null;
                      },
                      onSaved: (value) {},
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                      ),
                    ),
                  ),
                  ///////////////////////////////////////////////////////////////////////
                  /// Continue Button and Cancel Button
                  ///////////////////////////////////////////////////////////////////////
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        child: ElevatedButton(
                          onPressed: () {
                            _trySubmit();
                          },
                          child: widget.isAuth ? const Text("Submit") : const Text("Update"),
                        ),
                      ),
                      if (widget.isAuth)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          child: TextButton(
                            onPressed: () => _providerAuth.clearAuthedUserDetailsAndSignout(),
                            child: const Text("Log out"),
                          ),
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
