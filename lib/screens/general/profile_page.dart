import 'dart:typed_data';
import 'package:csc322_starter_app/screens/general/screen_home.dart';
import 'package:csc322_starter_app/widgets/general/bottom_nav_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  // URL for this widget
  static const routeName = '/profilePageEdit';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Uint8List? pickedImage;
  String? userEmail;
  String? username; // Store the username here

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      userEmail = user?.email;
    });
  }

  // Profile image picker function
  Future<void> onProfileTapped() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child("user_1.jpg");
    final imageBytes = await image.readAsBytes();

    // Save image data locally
    setState(() {
      pickedImage = imageBytes;
    });

    // Upload to Firebase
    await imageRef.putData(imageBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        centerTitle: true,
        backgroundColor: Colors.blue,

        // Return to previous page
        actions: [],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: <Color>[
              Colors.blue,
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          children: [
            const Padding(padding: EdgeInsets.only(top: 20)),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /////////////////////
                  ///Set up a gesture detector which would allow us to see if
                  ///the user clicked on the profile picture screen
                  ////////////////////
                  GestureDetector(
                    onTap: onProfileTapped,
                    //TODO: Turn this into a stack and add a smaller circle bottom left of circleAvatar to show that users can add picture

                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.brown.shade800,
                      backgroundImage: pickedImage != null
                          ? MemoryImage(pickedImage!)
                          : null,
                      child: pickedImage == null
                          ? const Icon(Icons.person_outline)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Display the entered username or "No username" if none entered
                  Text(
                    username ??
                        'No username provided', // Show username or placeholder
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // Display the email (if available) from FirebaseAuth
                  Text(
                    userEmail ?? 'No email found',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      /////////////////////
      ///This will control the bottom navigation bar and allows
      ///switching between main and profile screen.
      ///
      ///There is a BottomNavBar.dart which holds the syntax for setting up
      ///the navigation bar.
      ///
      ///This Navigation is copied into the MainScreen file with the indexes being
      ///reversed.
      /////////////////////
      //   bottomNavigationBar: BottomNavBar(
      //     currentIndex: 1,
      //     onTap: (index) {
      //       if (index == 0) {
      //         Navigator.pushReplacement(
      //           context,
      //           // TODO: Connect ScreenHome here, then figure how to integrate into GoRouter in main.dart.
      //           MaterialPageRoute(builder: (context) => ScreenHome()),
      //         );
      //       }
      //     },
      //   ),
    );
  }
}
