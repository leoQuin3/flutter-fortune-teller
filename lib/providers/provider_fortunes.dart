import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc322_starter_app/db_helpers/firestore_keys.dart';
import 'package:csc322_starter_app/models/fortune.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// *******************************************
// Stores fortunes from and to database.
// *******************************************
class ProviderFortunes extends ChangeNotifier {
  ProviderFortunes(this.ref);
  Ref ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variables being watched
  List<Fortune> _fortuneList = [];

  // Getters
  List<Fortune> get fortunes => _fortuneList;

  // Add fortune to list
  void addFortune({required String text, required FortuneType type}) {
    String id = Uuid().v4().toString();
    Fortune newFortune = Fortune(text: text, type: type, id: id);
    _fortuneList.add(newFortune);
    notifyListeners();
  }

  // Remove fortune from list
  void removeFortune(String id) {
    _fortuneList.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  // Save fortune to profile
  Future<bool> saveFortuneToProfile(Fortune newFortune, String userId) async {
    try {
      if (userId.isEmpty) {
        return false;
      }

      // Create fortune document
      Map<String, dynamic> fortuneDoc = {
        'id': newFortune.id,
        'text': newFortune.text,
        'type': newFortune.type.toString(),
      };

      // Upload fortune to user's profile
      await _firestore
          .collection(FS_COL_IC_USER_PROFILES)
          .doc(userId)
          .collection('fortunes')
          .doc(newFortune.id)
          .set(fortuneDoc);
    }
    // Print error if unsuccessful
    catch (err) {
      print("Error saving fortunes: $err");
    }

    // Return if successful
    return true;
  }
}
