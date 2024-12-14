// -----------------------------------------------------------------------
// Filename: widget_app_drawer.dart
// Original Author: Dan Grissom
// Creation Date: 5/27/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the primary scaffold for the app.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Flutter external package imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// App relative file imports
import '../../providers/provider_user_profile.dart';
import '../../screens/settings/screen_settings.dart';
import '../general/widget_profile_avatar.dart';
import '../../providers/provider_auth.dart';
import '../../main.dart';

// Custom file imports
import 'package:csc322_starter_app/screens/general/profile_page.dart';

enum BottomNavSelection { HOME_SCREEN, ALTERNATE_SCREEN }

// ********************************************
// Drawer which provides access app settings
// ********************************************
class WidgetAppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final ProviderAuth _providerAuth = ref.watch(providerAuth);
          final ProviderUserProfile _providerUserProfile =
              ref.watch(providerUserProfile);

          return Column(
            children: <Widget>[
              AppBar(
                backgroundColor: Theme.of(context).colorScheme.onSurface,
                title: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ProfileAvatar(
                      radius: 15,
                      userImage: _providerUserProfile.userImage,
                      userWholeName: _providerUserProfile.wholeName,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Welcome ${_providerUserProfile.firstName}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                    )
                  ],
                ),
                // ,
                automaticallyImplyLeading: false,
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
                textColor: Theme.of(context).colorScheme.onPrimary,
                iconColor: Theme.of(context).colorScheme.onPrimary,
                onTap: () {
                  // Close the drawer
                  Navigator.of(context).pop();
                  context.push(ProfilePage.routeName); // Go to Profile Page
                },
              ),
              ListTile(
                leading: Icon(Icons.spatial_audio_off),
                title: Text('Voice Settings'),
                textColor: Theme.of(context).colorScheme.onPrimary,
                iconColor: Theme.of(context).colorScheme.onPrimary,
                onTap: () {
                  // Close the drawer
                  Navigator.of(context).pop();
                  context.push(ScreenSettings.routeName, extra: false);
                },
              ),
              Divider(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.25)),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout'),
                textColor: Theme.of(context).colorScheme.onPrimary,
                iconColor: Theme.of(context).colorScheme.onPrimary,
                onTap: () {
                  _providerAuth.clearAuthedUserDetailsAndSignout();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
