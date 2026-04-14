// // backup_service.dart
// import 'dart:convert';
// import 'package:flutter/services.dart';
//
// class BackupService {
//   static const platform = MethodChannel("save_drive/channel");
//
//   static Future<String?> backupToDrive(Map<String, dynamic> backupData) async {
//     try {
//       final uri = await platform.invokeMethod("createFile", {
//         "mime": "application/json",
//         "fileName": "backup_${DateTime.now().millisecondsSinceEpoch}.json",
//       });
//
//       if (uri == null) return null;
//
//       final jsonContent = jsonEncode(backupData);
//
//       await platform.invokeMethod("writeFile", {
//         "uri": uri,
//         "data": jsonContent,
//       });
//
//       return uri;
//
//     } catch (e) {
//       print("❌ Backup error: $e");
//       return null;
//     }
//   }
// }
//
// import 'dart:convert';
//
// import 'package:flutter/services.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
//
//
// class GDriveUpload {
//   static const platform = MethodChannel("save_drive/channel");
//
//
//       Future<String?> backupToDrive(Map<String, dynamic> backupData) async {
//     try {
//       final uri = await platform.invokeMethod("createFile", {
//         "mime": "application/json",
//         "fileName": "backup_${DateTime.now().millisecondsSinceEpoch}.json",
//       });
//
//       if (uri == null) return null;
//
//       final jsonContent = jsonEncode(backupData);
//
//       await platform.invokeMethod("writeFile", {
//         "uri": uri,
//         "data": jsonContent,
//       });
//
//       return uri;
//
//     } catch (e) {
//       print("❌ Backup error: $e");
//       return null;
//     }
//   }
//   // Future<String?> backupToDrive() async {
//   //   try {
//   //     final jsonContent = await _exportDatabase();
//   //
//   //     final uri = await platform.invokeMethod("createFile", {
//   //       "fileName": "backup_${DateTime.now().millisecondsSinceEpoch}.json",
//   //       "mime": "application/json",
//   //     });
//   //
//   //     if (uri == null) {
//   //       print("❌ Backup cancelled");
//   //       return;
//   //     }
//   //
//   //     await platform.invokeMethod("writeFile", {
//   //       "uri": uri,
//   //       "data": jsonContent,
//   //     });
//   //
//   //     print("✅ Backup completed successfully!");
//   //   } catch (e) {
//   //     print("❌ Backup failed: $e");
//   //   }
//   //   return null;
//   // }
//
//   // EXPORT ENTIRE SQLITE DB TO JSON
//   Future<String> _exportDatabase() async {
//     final dbPath = join(await getDatabasesPath(), 'save.db');
//     final db = await openDatabase(dbPath);
//
//     final tables = await db.rawQuery(
//         "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';"
//     );
//
//     Map<String, dynamic> allData = {};
//
//     for (var table in tables) {
//       final tableName = table['name'] as String;
//       final rows = await db.query(tableName);
//
//       allData[tableName] = rows.map((row) => Map.from(row)).toList();
//     }
//
//     await db.close();
//
//     return const JsonEncoder.withIndent("  ").convert(allData);
//   }
// }
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class BackupService {
  static const platform = MethodChannel("save_drive/channel");

  /// FULL BACKUP → Save entire save.db content to Google Drive
  static Future<String?> backupToDrive() async {
    try {
      // 1️⃣ Export all tables to a single JSON string
      final jsonContent = await DatabaseHelper().exportDatabaseToJsonContent();

      // 2️⃣ Create a new Drive file
      final uri = await platform.invokeMethod("createFile", {
        "mime": "application/json",

        "fileName": "MySaving_Backup_${DateTime.now().millisecondsSinceEpoch}.json",
      });

      if (uri == null) {
        print("❌ File URI is null.");
        return null;
      }

      print("📌 CREATED FILE URI: $uri");

      // 3️⃣ Write JSON to the new file
      await platform.invokeMethod("writeFile", {
        "uri": uri,
        "data": jsonContent,
      });

      print("✅ JSON WRITE SUCCESS");

      return uri;

    } catch (e) {
      print("❌ Backup error: $e");
      return null;
    }
  }
}
