import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;

import '../../../../services/API_services/API_services.dart';

class ExportToDriveScreen extends StatelessWidget {
  String token = "";
  String timestamp = "";

  ExportToDriveScreen({super.key});

  // Sign in with Google
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  Future<String> exportDatabaseToJsonContent() async {
    try {
      final dbPath = join(await getDatabasesPath(), 'save.db');
      final db = await openDatabase(dbPath);

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
      );

      Map<String, dynamic> allData = {};

      for (var table in tables) {
        final tableName = table['name'] as String;
        final rows = await db.query(tableName);

        final encodedRows = rows.map((row) {
          final updatedRow = Map<String, dynamic>.from(row);
          updatedRow.forEach((key, value) {
            if (value is Uint8List) {
              updatedRow[key] = base64Encode(value);
            }
          });
          return updatedRow;
        }).toList();

        allData[tableName] = encodedRows;
      }

      await db.close();

      final jsonString = const JsonEncoder.withIndent('  ').convert(allData);
      return jsonString;
    } catch (e) {
      print('❌ Error exporting DB: $e');
      rethrow;
    }
  }

  Future<void> sendJsonToServer(String jsonContent) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token') ?? '';
      timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      ApiHelper api = ApiHelper();


      String response = await api.postApiResponse(
        "uploadBackupFile.php",
        {
          "data": jsonContent,
          "timestamp": timestamp,
          "token": token,},
      );

      print("✅ Raw response string:\n$response");

      // Try decoding it as JSON

      var jsonResponse = json.decode(response);
      print("✅ Decoded JSON response:\n$jsonResponse");

      if (jsonResponse is Map<String, dynamic> &&
          jsonResponse.containsKey('data')) {
        print("📦 Data from response: ${jsonResponse['data']}");
      }
    } catch (decodeError) {
      print("❌ Failed to decode response as JSON: $decodeError");
    }
  }


  // Exports SQLite DB to JSON string and saves to a file
  // Future<File> exportJsonToFile() async {
  //   final dbPath = join(await getDatabasesPath(), 'save.db');
  //   final db = await openDatabase(dbPath);
  //
  //   final tables = await db.rawQuery(
  //     "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
  //   );
  //
  //   Map<String, dynamic> allData = {};
  //
  //   for (var table in tables) {
  //     final tableName = table['name'] as String;
  //     final rows = await db.query(tableName);
  //
  //     final encodedRows = rows.map((row) {
  //       final updatedRow = Map<String, dynamic>.from(row);
  //       updatedRow.forEach((key, value) {
  //         if (value is Uint8List) {
  //           updatedRow[key] = base64Encode(value);
  //         }
  //       });
  //       return updatedRow;
  //     }).toList();
  //
  //     allData[tableName] = encodedRows;
  //   }
  //
  //   await db.close();
  //
  //   final jsonString = const JsonEncoder.withIndent('  ').convert(allData);
  //
  //   final tempDir = await getTemporaryDirectory();
  //   final filePath = '${tempDir.path}/database_backup.json';
  //   final file = File(filePath);
  //   await file.writeAsString(jsonString);
  //
  //   return file;
  // }

  // Upload file to Google Drive
  // Future<void> uploadToGoogleDrive(File file, BuildContext context) async {
  //   try {
  //     final account = await _googleSignIn.signIn();
  //     if (account == null) {
  //       print('❌ Sign-in aborted');
  //       return;
  //     }
  //
  //     final authHeaders = await account.authHeaders;
  //     final client = GoogleAuthClient(authHeaders);
  //     final driveApi = drive.DriveApi(client);
  //
  //     final driveFile = drive.File();
  //     driveFile.name = basename(file.path);
  //     driveFile.mimeType = 'application/json';
  //
  //     final media = drive.Media(file.openRead(), await file.length());
  //
  //     final uploaded = await driveApi.files.create(
  //       driveFile,
  //       uploadMedia: media,
  //     );
  //
  //     print('✅ File uploaded: https://drive.google.com/file/d/${uploaded.id}/view');
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Uploaded to Drive: ${uploaded.name}')),
  //     );
  //   } catch (e) {
  //     print('❌ Upload error: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Export JSON to Google Drive")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final jsonContent = await exportDatabaseToJsonContent();
            await sendJsonToServer(jsonContent);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('JSON content sent to server')),
            );
            // final jsonFile = await exportJsonToFile();
            // await uploadToGoogleDrive(jsonFile, context);
          },
          child: const Text('Export & Upload JSON'),
        ),
      ),
    );
  }
}

// Required for GoogleAuthClient
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }

  @override
  void close() => _client.close();
}
