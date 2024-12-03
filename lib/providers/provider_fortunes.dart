import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc322_starter_app/db_helpers/firestore_keys.dart';
import 'package:csc322_starter_app/main.dart';
import 'package:csc322_starter_app/models/fortune.dart';
import 'package:csc322_starter_app/widgets/general/categories.dart';
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
  bool isFiltered = false;
  Categories _currentCategoryFilter = Categories.MISC;
  int _savedFortunesCount = 0;
  int _receivedFortunesCount = 0;

  // Getters
  List<Fortune> get fortunes => _fortuneList;
  List<Fortune> getFilteredFortunes() => _fortuneList
      .where((element) => element.category == _currentCategoryFilter)
      .toList();
  int get savedFortunesCount => _savedFortunesCount;
  int get receivedFortunesCount => _receivedFortunesCount;

  // Set filter to show certain fortunes
  void setFilter(Categories category) {
    _currentCategoryFilter = category;
    notifyListeners();
  }

  // Set filter
  void enableFilter(bool isOn) {
    isFiltered = isOn;
    notifyListeners();
  }

  // Add fortune to list
  void addFortune({required String text, required Categories category}) {
    String id = Uuid().v4().toString();
    Fortune newFortune = Fortune(text: text, category: category, id: id);
    _fortuneList.add(newFortune);
    saveFortunesToProfile();
    notifyListeners();

    saveFortunesToProfile();
    notifyListeners();
  }

  // Increment number of fortunes generated so far
  void incrementFortune() {
    _receivedFortunesCount++;
    notifyListeners();
  }

  // Remove fortune from list
  void removeFortune(Fortune fortune) {
    _fortuneList.removeWhere((element) => element.id == fortune.id);
    deleteFortuneFromProfile(fortune);
    notifyListeners();
  }

  // Save fortune to profile
  Future<bool> saveFortunesToProfile() async {
    final userProfile = ref.read(providerUserProfile);
    final userId = userProfile.uid;

    // Save each fortune into database
    try {
      for (var fortune in _fortuneList) {
        Map<String, dynamic> fortuneDoc = {
          'id': fortune.id,
          'text': fortune.text,
          'category': getUnformattedCategoryName(fortune.category),
        };

        await _firestore
            .collection(FS_COL_IC_USER_PROFILES)
            .doc(userId)
            .collection('fortunes')
            .doc(fortune.id)
            .set(fortuneDoc);
      }
      // Return true if successful
      _savedFortunesCount = _fortuneList.length;
      notifyListeners();
      return true;

      // Return false if unsuccessful
    } catch (err) {
      print('Failed to save fortunes: $err');
      return false;
    }
  }

  // Save user stats to profile
  Future<bool> saveStatesToProfile() async {
    final userProfile = ref.read(providerUserProfile);
    final userId = userProfile.uid;

    try {
      await _firestore.collection(FS_COL_IC_USER_PROFILES).doc(userId).update({
        'fortunesReceived': savedFortunesCount,
      });
      return true;
    } catch (err) {
      print('Failed to save user stats: $err');
      return false;
    }
  }

  // Fetch fortunes from profile
  // FIXME: Fortunes are not fetched until refreshed
  Future<bool> fetchFortunesFromProfile() async {
    final userProfile = ref.read(providerUserProfile);
    final userId = userProfile.uid;

    try {
      // Get snapshot of fortunes in the cloud
      QuerySnapshot snapshot = await _firestore
          .collection(FS_COL_IC_USER_PROFILES)
          .doc(userId)
          .collection('fortunes')
          .get();

      // Clear local list
      _fortuneList.clear();

      // Add fortunes to local list
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Fortune fortune = Fortune(
          id: data['id'],
          text: data['text'],
          category: getCategory(data['category']),
        );
        _fortuneList.add(fortune);
      }
      _savedFortunesCount = _fortuneList.length; // TODO: probably make another method to handle fetching stats.
      notifyListeners();
      return true;

      // Prompt error
    } catch (err) {
      print('Failed to fetch fortunes: $err');
      notifyListeners();
      return false;
    }
  }

  // Delete fortune from profile
  Future<bool> deleteFortuneFromProfile(Fortune fortune) async {
    final userProfile = ref.read(providerUserProfile);
    final userId = userProfile.uid;

    // Delete fortune
    try {
      await _firestore
          .collection(FS_COL_IC_USER_PROFILES)
          .doc(userId)
          .collection('fortunes')
          .doc(fortune.id)
          .delete();

      _savedFortunesCount -= 1;
      notifyListeners();
      return true;

      // Prompt error
    } catch (err) {
      notifyListeners();
      return false;
    }
  }
}
