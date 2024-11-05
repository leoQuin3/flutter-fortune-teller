// -----------------------------------------------------------------------
// Filename: secure_storage.dart
// Original Author: Dan Grissom
// Creation Date: 6/12/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the utility helper for storing data
//              on the device (via secure storage).

////////////////////////////////////////////////////////////////////////////////////////////
// Imports
////////////////////////////////////////////////////////////////////////////////////////////
// Flutter external package imports
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// App relative imports
import 'secure_storage_keys.dart';

//////////////////////////////////////////////////////////////////
// Class definition for DeviceStorage. This is essentially a
// wrapper around the SharedPreferences library.
//////////////////////////////////////////////////////////////////
class SecureStorage {
  //////////////////////////////////////////////////////////////////
  // Static methods for SAVING data
  //////////////////////////////////////////////////////////////////
  static Future<void> setIdToken(String idToken) async {
    FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    await secureStorage.write(key: SS_KEY_FIREBASE_ID_TOKEN, value: idToken);
  }

  //////////////////////////////////////////////////////////////////
  // Static methods for CLEARING data
  //////////////////////////////////////////////////////////////////
  static Future<void> clearIdToken() async {
    FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    await secureStorage.delete(key: SS_KEY_FIREBASE_ID_TOKEN);
  }

  //////////////////////////////////////////////////////////////////
  // Static methods for READING data
  //////////////////////////////////////////////////////////////////
  static Future<String> getIdToken() async {
    FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    return await secureStorage.read(key: SS_KEY_FIREBASE_ID_TOKEN) ?? "";
  }
}
