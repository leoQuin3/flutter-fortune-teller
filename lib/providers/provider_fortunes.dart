import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc322_starter_app/db_helpers/firestore_keys.dart';
import 'package:csc322_starter_app/main.dart';
import 'package:csc322_starter_app/models/fortune.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// *******************************************
// Stores fortunes from and to database.
// *******************************************
class ProviderFortunes extends ChangeNotifier{
  ProviderFortunes(this.ref);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 
  final Ref ref;
  final Uuid uuid = Uuid();

  // Variables being watched
  List<Fortune> fortuneList = [];
  
  // Add fortune to list (locally and database)
  Future<bool> addFortune({required String text, required FortuneType type}) async {
    bool _isSuccessfullySaved  = false;
    final fortuneId = uuid.v4();
    Fortune newFortune = Fortune(text: text, type: type, id: fortuneId);

    try {
      // Access user id
      final userId = ref.read(providerUserProfile).uid;

      // If user id is not found, cancel
      if (userId.isEmpty) {
        print('User ID not found.');
        return false;
      }

      // Create fortune document
      Map<String, dynamic> fortuneDoc = {
        'id' : fortuneId,
        'text' : text,
        'type' : type.toString(),
      };

      // Store fortune into user profile
      await _firestore.collection(FS_COL_IC_USER_PROFILES).doc(userId).collection('fortunes').doc(fortuneId).set(fortuneDoc);
      
      // Store fortune locally
      fortuneList.add(newFortune);

      // Update state
      _isSuccessfullySaved = true;
      notifyListeners();
    }

    // Print error if unsuccessful
    catch (err) {
      print("Error saving fortunes: $err");
    }

    // Return if successful
    return _isSuccessfullySaved;
  }
}