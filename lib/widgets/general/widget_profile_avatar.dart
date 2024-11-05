// Flutter imports
// -----------------------------------------------------------------------
// Filename: widget_profile_avatar.dart
// Original Author: Dan Grissom
// Creation Date: 5/29/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains code for a profile avatar widget that
//              displays a user's profile image or initials.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Flutter external package imports
import 'package:flutter/material.dart';

//////////////////////////////////////////////////////////////////////////
// StateFUL widget which manages state. Simply initializes the
// state object.
//////////////////////////////////////////////////////////////////////////
class ProfileAvatar extends StatefulWidget {
  const ProfileAvatar(
      {super.key,
      required this.radius,
      this.initialsSize = 0,
      required this.userImage,
      required this.userWholeName,
      this.isInAppBar = false});

  //radius of CircleAvatar
  final double radius;
  final double initialsSize;
  final ImageProvider? userImage;
  final String userWholeName;
  final bool isInAppBar;

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

//////////////////////////////////////////////////////////////////////////
// The actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////////////
class _ProfileAvatarState extends State<ProfileAvatar> {
  var _isInit = true;
  String initials = "";
  String selectedUid = "";
  double textSize = 0;

  @override
  void initState() {
    super.initState();
  }

  ////////////////////////////////////////////////////////////////////////
  // Gets the current state of the providers for consumption on
  // this page
  ////////////////////////////////////////////////////////////////////////
  getProviderSettings() async {
    getInitials();
  }

  ////////////////////////////////////////////////////////////////////////
  // Runs the following code once upon initialization
  ////////////////////////////////////////////////////////////////////////
  @override
  void didChangeDependencies() {
    // If first time running this code, update provider settings
    if (_isInit) {
      getProviderSettings();
    }

    // Now initialized; run super method
    _isInit = false;
    super.didChangeDependencies();
  }

  void getInitials() {
    // Update initial size, if needed
    textSize = widget.initialsSize == 0 ? (widget.radius * .7) : widget.initialsSize;

    // Now, get the initials themselves
    try {
      //Store first and last names from _userProfileProvider
      String fn = widget.userWholeName.split(' ')[0];
      String ln = widget.userWholeName.split(' ')[1];

      //Extract initials
      String i1 = fn.isEmpty ? "" : fn.substring(0, 1);
      String i2 = ln.isEmpty ? "" : ln.substring(0, 1);

      // Update initials
      initials = (i1 + i2).trim();
      initials = initials.isEmpty ? "ME" : initials;
    } catch (e) {
      // If an exception occurred during parsing, just load "ME" for Me (myself)
      initials = "ME";
    }
  }

  @override
  Widget build(BuildContext context) {
    // If current image is null, set to intials. Else, display user's photo
    // If no user data is loaded, the profile photo will default to "ME" initials
    if (widget.userImage == null && initials != "") {
      return Stack(children: [
        CircleAvatar(
            radius: widget.radius,
            backgroundColor: Color.fromARGB(255, 137, 137, 137),
            child: Text(
              initials,
              style: TextStyle(fontSize: textSize),
            )),
      ]);
    } else if (!widget.isInAppBar) {
      // This version of the avatar has the gapless playback feature
      // enabled to prevent the image from flickering when the user
      // updates the screen for any reason.
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: Image(
          image: widget.userImage!, //?? Image.asset("images/logo.png").image,
          gaplessPlayback: true,
          height: widget.radius * 2,
          width: widget.radius * 2,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // This version of the avatar does NOT have the gapless playback
      // feature b/c the ClipRRect did not work properly in the app bar.
      return CircleAvatar(
        radius: widget.radius,
        backgroundImage: Image(
          image: widget.userImage!,
          gaplessPlayback: true,
        ).image,
      );
    }
  }
}
