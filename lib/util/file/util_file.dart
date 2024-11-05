// -----------------------------------------------------------------------
// Filename: util_file.dart
// Original Author: Dan Grissom
// Creation Date: 7/23/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains utility methods for file-related
//              needs.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Dart imports
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

// Flutter external package imports
import 'package:path_provider/path_provider.dart';

// App relative file imports
import '../logging/app_logger.dart';

//////////////////////////////////////////////////////////////////////////
// Class definition (Static methods only)
//////////////////////////////////////////////////////////////////////////
class UtilFile {
  ////////////////////////////////////////////////////////////////
  // Static variables
  ////////////////////////////////////////////////////////////////
  static String _appDirPath = "";

  ////////////////////////////////////////////////////////////////
  // Returns the app directory path.
  ////////////////////////////////////////////////////////////////
  static Future<String> init() async {
    // If it's not already set, set it
    if (_appDirPath.isEmpty) {
      Directory _appDir = await getApplicationDocumentsDirectory();
      _appDirPath = _appDir.path;
      AppLogger.debug("App directory path: $_appDirPath");
    }
    return _appDirPath;
  }

  ////////////////////////////////////////////////////////////////
  // Getter for the app directory path.
  ////////////////////////////////////////////////////////////////
  static String getAppDirPath() {
    return _appDirPath;
  }

  ////////////////////////////////////////////////////////////////
  // Formats the file size in a human-readable format in bytes,
  // kilobytes, or megabytes.
  ////////////////////////////////////////////////////////////////
  static String formatFileSize(double fileSizeInBytes) {
    //If the file size is less than 1KB
    if (fileSizeInBytes < 1024) {
      return '${fileSizeInBytes.toStringAsFixed(2)} B';
    } else if (fileSizeInBytes < 1024 * 1024) {
      //If the file size is less than 1MB
      double fileSizeInKB = fileSizeInBytes / 1024;
      return '${fileSizeInKB.toStringAsFixed(2)} KB';
    } else if (fileSizeInBytes < 1024 * 1024 * 1024) {
      //If the file size is less than 1GB
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      return '${fileSizeInMB.toStringAsFixed(2)} MB';
    } else {
      //If the file size is greater than 1GB
      double fileSizeInGB = fileSizeInBytes / (1024 * 1024 * 1024);
      return '${fileSizeInGB.toStringAsFixed(2)} GB';
    }
  }

  ////////////////////////////////////////////////////////////////
  // Takes a file path and returns the size in bytes of the file.
  ////////////////////////////////////////////////////////////////
  static int getFileSizeInBytes(String filePath) {
    // Init variables
    int fileSize = 0;

    // Get file size
    File file = File(filePath);
    if (file.existsSync()) {
      fileSize = file.lengthSync();
    }

    // Return the file size
    return fileSize;
  }

  ////////////////////////////////////////////////////////////////
  // Takes a file path and deletes the file.
  ////////////////////////////////////////////////////////////////
  static bool deleteFile(String filePath) {
    // Init variables
    bool isDeleted = false;

    // Delete the file
    try {
      File file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync();
        isDeleted = true;
        AppLogger.debug("Deleted file: $filePath");
      }
    } catch (e) {
      AppLogger.error("Error deleting $filePath: $e");
    }

    // Return whether the file was deleted
    return isDeleted;
  }

  ////////////////////////////////////////////////////////////////
  // Takes in a file path and returns the base64 encoding of the
  // file.
  ////////////////////////////////////////////////////////////////
  static String getBase64Encoding(String filePath) {
    // Init variables and read the file as bytes
    String base64Audio = "";
    File file = File(filePath);
    Uint8List bytes = file.readAsBytesSync();

    // Convert the bytes to a Base64 string and return
    if (bytes.isNotEmpty) base64Audio = base64Encode(bytes);
    return base64Audio;
  }

  ////////////////////////////////////////////////////////////////
  // Takes in a file path and returns the file name with extension.
  ////////////////////////////////////////////////////////////////
  static getFileNameWithExtension(String filePath) {
    return filePath.split('/').last;
  }

  ////////////////////////////////////////////////////////////////
  // Takes in a file path and returns the file name extension.
  ////////////////////////////////////////////////////////////////
  static getFileNameExtension(String localFilePath) {
    return localFilePath.split('.').last.toUpperCase();
  }

  ////////////////////////////////////////////////////////////////
  // Takes in a file path and returns whether the file exists.
  ////////////////////////////////////////////////////////////////
  static fileExists(String localFilePath) {
    return File(localFilePath).existsSync();
  }

  ////////////////////////////////////////////////////////////////
  // Takes in a filename and returns a path to the file in the
  // external storage directory.
  ////////////////////////////////////////////////////////////////
  static Future<String> getFilePathInExternalStorage(String fileName) async {
    // Get the external storage directory, append the file name, and return
    try {
      Directory? extStorageDirectory = await getExternalStorageDirectory();
      String filePath = '${extStorageDirectory!.path}/$fileName';
      return filePath;
    } catch (e) {
      AppLogger.error("Error getting file path in external storage: $e");
    }

    return "filePath";
  }
}
