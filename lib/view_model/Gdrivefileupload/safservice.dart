import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SafDriveService {
  static const MethodChannel _channel = MethodChannel("save_drive/channel");

  /// Pick a folder in Google Drive
  static Future<String?> pickFolder() async {
    try {
      final folderUri = await _channel.invokeMethod<String>("pickFolder");
      return folderUri;
    } catch (e) {
      print("❌ Error picking folder: $e");
      return null;
    }
  }

  /// Pick a JSON file from Google Drive
  static Future<Map<String, dynamic>?> pickJsonFile() async {
    try {
      final result = await _channel.invokeMethod<Map>("pickJsonFile");
      return result?.cast<String, dynamic>();
    } catch (e) {
      print("❌ Error picking JSON file: $e");
      return null;
    }
  }

  /// Create an auto folder "SaveApp_Backups" inside the selected folder
  static Future<String?> createAutoFolder(String folderUri) async {
    try {
      final backupFolderUri = await _channel.invokeMethod<String>(
        "createAutoFolder",
        {"folderUri": folderUri},
      );
      return backupFolderUri;
    } catch (e) {
      print("❌ Error creating auto folder: $e");
      return null;
    }
  }

  /// Create a JSON file inside a folder

  static Future<String?> createJsonFile({
  required String jsonContent,
  String fileName = 'backup.json',
  }) async {
  try {
  final String? result = await _channel.invokeMethod('createFile', {
  'json': jsonContent,
  'fileName': fileName,
  });
  return result;
  } catch (e) {
  print('❌ createJsonFile error: $e');
  return null;
  }
  }


  /// Read JSON file content by URI
  static Future<Map<String, dynamic>?> readFileByUri(String uri) async {
    try {
      final result = await _channel.invokeMethod<Map>("readFileByUri", {"uri": uri});
      return result?.cast<String, dynamic>();
    } catch (e) {
      print("❌ Error reading file by URI: $e");
      return null;
    }
  }
}