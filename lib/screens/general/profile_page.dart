import 'dart:io';
import 'dart:typed_data';
// import 'package:csc322_starter_app/screens/general/screen_home.dart';
// import 'package:csc322_starter_app/widgets/general/bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc322_starter_app/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// ***********************************************
// Page to change name, email, and profile image
// ***********************************************
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  // URL for this widget
  static const routeName = '/profilePageEdit';

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  File? pickedImage;
  String? userEmail;
  String? username;
  String? userId;

  //Fetch username from Firebase Firestore
  Future<void> _fetchUsername(String uid) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      setState(() {
        username = userDoc.data()!['username'] as String?;
      });
    } else {
      _promptForUsername(uid);
    }
  }

//Will ask the user for their username if they don't have one already
  Future<void> _promptForUsername(String uid) async {
    final TextEditingController usernameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Your Username'),
          content: TextField(
            controller: usernameController,
            decoration: const InputDecoration(hintText: 'Enter your username'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final enteredUsername = usernameController.text.trim();
                if (enteredUsername.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .set({
                    'username': enteredUsername,
                  });
                  setState(() {
                    username = enteredUsername;
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Profile image picker function
  // TODO: Save to database (leo)
  Future<void> onProfileTapped() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    // final storageRef = FirebaseStorage.instance.ref();
    // final imageRef = storageRef.child("user_1.jpg");
    // final imageBytes = await image.readAsBytes();

    // // Save image data locally
    setState(() {
      pickedImage = File(image.path);
    });

    // // Upload to Firebase
    // await imageRef.putData(imageBytes);
  }

  @override
  Widget build(BuildContext context) {
    // Using user profile provider to fetch user data (leo)
    final userProfile = ref.watch(providerUserProfile);
    username = userProfile.wholeName;
    userEmail = userProfile.email;
    userId = userProfile.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Profile',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,

        // Return to previous page
        actions: [],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: <Color>[
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),

        // Replaced ListView with Column since there wasn't much to scroll thru. You can change it back if needed. (leo)
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 40),

              /////////////////////
              ///Set up a gesture detector which would allow us to see if
              ///the user clicked on the profile picture screen
              ////////////////////
              GestureDetector(
                // Edit profile image
                onTap: onProfileTapped,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      backgroundImage:
                          pickedImage != null ? FileImage(pickedImage!) : null,
                      child: pickedImage != null
                          ? null
                          : Icon(
                              Icons.person_outline,
                              size: 35,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.photo_camera),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 6)
                            ]),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Display the entered username or "No username" if none entered
              Text(
                username ??
                    'No Username Provided', // Show username or placeholder
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 6,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Display the email (if available) from FirebaseAuth
              Text(
                userEmail ?? 'No Email Found',
                style: TextStyle(
                  fontSize: 18,
                  color:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.75),
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 6,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
