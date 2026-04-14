// restore_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';

// restore_data.dart
import 'package:flutter/services.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'dart:convert';
import 'package:flutter/services.dart';


class RestoreService {
  static const platform = MethodChannel("save_drive/channel");

  /// Get last backup file content (JSON string) from Drive
  Future<String?> fetchLastBackup() async {
    try {
      final String? result =
      await platform.invokeMethod("getLastBackup"); // Android → JSON string
      return result;
    } catch (e) {
      print("❌ Error fetching backup: $e");
      return null;
    }
  }

  /// Only preview — return formatted JSON map
  Future<Map<String, dynamic>?> fetchLastBackupForPreview() async {
    final content = await fetchLastBackup();
    if (content == null) return null;

    try {
      return json.decode(content);
    } catch (e) {
      print("❌ JSON decode error: $e");
      return null;
    }
  }

  /// FULL RESTORE → writes all tables
  Future<bool> restoreDatabaseFromJson(String jsonContent) async {
    try {
      final decoded = json.decode(jsonContent);

      for (final tableName in decoded.keys) {
        final rows = List<Map<String, dynamic>>.from(decoded[tableName]);
        print("📌 Restoring: $tableName (${rows.length} rows)");
print("Rows are $rows");
        await DatabaseHelper().restoreTable(tableName, rows) ;
      }

      print("✅ Restore complete");
      return true;

    } catch (e) {
      print("❌ Restore failed: $e");
      return false;
    }
  }

  /// Auto-restore at app startup
  Future<bool> autoRestoreFromDrive() async {
    final content = await fetchLastBackup();
    if (content == null) return false;

    return await restoreDatabaseFromJson(content);
  }
}

//
// class RestoreService {
//   static const platform = MethodChannel("save_drive/channel");
//   final data = platform.invokeMethod("pickFile");
//   /// Restore → pick JSON file → return string content
//     Future<String?> pickAndReadBackupFile() async {
//     try {
//       // 1️⃣ Open Google Drive picker
//       final uri = await platform.invokeMethod("pickFile", {
//         "mime": "application/json"
//       });
//
//       if (uri == null) {
//         print("❌ No file selected.");
//         return null;
//       }
//
//       print("📌 Selected file URI: $uri");
//
//       // 2️⃣ Read file content
//       final content = await platform.invokeMethod("readFile", {"uri": uri});
//
//       if (content == null || content.toString().trim().isEmpty) {
//         print("❌ Empty file!");
//         return null;
//       }
//
//       print("📄 Backup content loaded (${content.length} chars)");
//       return content;
//
//     } catch (e) {
//       print("❌ Restore error: $e");
//       return null;
//     }
//   }
//
//   /// Restore backup JSON → writes into SQLite
//   static Future<bool> restoreDatabase(String jsonString) async {
//     try {
//       final data = jsonDecode(jsonString);
//
//       print("🔄 Starting DB restore...");
//       await DatabaseHelper().restoreDatabaseFromJson(data);
//
//       print("✅ Restore completed");
//       return true;
//
//     } catch (e) {
//       print("❌ Restore failed: $e");
//       return false;
//     }
//   }
// }

// class RestoreService {
//   static const platform = MethodChannel("save_drive/channel");
//
//   Future<String?> pickAndReadBackupFile() async {
//     try {
//       final content = await platform.invokeMethod("pickFile");
//
//       if (content == null) {
//         print("❌ No file selected");
//         return null;
//       }
//
//       print("📥 File content received:");
//
//
//       await restoreDatabaseFromJson(content);
//       print(content);
//       return content;  // return JSON for preview UI
//     } catch (e) {
//       print("❌ Restore error: $e");
//       return null;
//     }
//   }
//
//
//   Future<void> restoreDatabaseFromJson(String jsonContent) async {
//     try {
//       final map = json.decode(jsonContent);
//       print("🔍 JSON DECODED: $map");
//       final items = map["data"] as List;
//       print("🔍 JSON data: $items");
//       final db = DatabaseHelper();
//
//   // await db.clearAll();              // ⬅ delete all old data
//       await db.insertBulk(items);        // ⬅ restore new data
//
//       print("✅ Database restore completed!");
//
//     } catch (e) {
//       print("❌ Failed to restore DB: $e");
//     }
//   }
// }
// import 'dart:convert';
// import 'package:flutter/services.dart';
// import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
//
// class RestoreService {
//   static const platform = MethodChannel("save_drive/channel");
//
//   /// Auto restore from last Drive backup, returns JSON content for preview
//   Future<String?> fetchLastBackupForPreview() async {
//     try {
//       final String? jsonContent = await platform.invokeMethod("getLastBackup");
//
//       if (jsonContent == null || jsonContent.isEmpty) {
//         print("❌ No backup file found on Drive");
//         return null;
//       }
//
//       // Return JSON string for preview
//       return jsonContent;
//     } catch (e) {
//       print("❌ Error fetching backup for preview: $e");
//       return null;
//     }
//   }
//
//   /// Restore JSON to SQLite DB
//   Future<void> restoreDatabaseFromJson(String jsonContent) async {
//     try {
//       final decoded = json.decode(jsonContent);
//
//       final db = DatabaseHelper();
//
//       if (decoded is Map<String, dynamic>) {
//         for (var tableName in decoded.keys) {
//           final rows = List<Map<String, dynamic>>.from(decoded[tableName]);
//           await db.insertBulk(rows, tableName: tableName);
//         }
//       } else if (decoded is List) {
//         await db.insertBulk(decoded.cast<Map<String, dynamic>>(), tableName: "default_table");
//       } else {
//         print("❌ Invalid JSON structure");
//       }
//
//       print("✅ Database restored from JSON");
//     } catch (e) {
//       print("❌ Failed to restore DB: $e");
//     }
//   }
// }

// class RestoreService {
//   static const platform = MethodChannel("save_drive/channel");
//
//   /// Auto-Restore directly from last saved Drive backup
//   Future<bool> autoRestoreFromDrive() async {
//     try {
//       print("📂 Checking last backup on Drive...");
//
//       // Fetch latest backup JSON from Android
//       final String? jsonContent =
//       await platform.invokeMethod("getLastBackup");
//
//       if (jsonContent == null || jsonContent.isEmpty) {
//         print("❌ No backup file found on Drive");
//         return false;
//       }
//
//       print("📄 Backup file found. Restoring...");
//
//       // Restore to database
//       await restoreDatabaseFromJson(jsonContent);
//
//       print("✅ Auto restore completed successfully");
//       return true;
//
//     } catch (e) {
//       print("❌ Auto-Restore error: $e");
//       return false;
//     }
//   }
//
//   /// Restore JSON content to local SQLite DB
//   Future<void> restoreDatabaseFromJson(String jsonContent) async {
//     try {
//       final decoded = json.decode(jsonContent);
//       final db = DatabaseHelper();
//
//       if (decoded is Map<String, dynamic>) {
//         for (var tableName in decoded.keys) {
//           final rows = List<Map<String, dynamic>>.from(decoded[tableName]);
//           await db.insertBulk(rows, tableName: tableName);
//         }
//       } else if (decoded is List) {
//         await db.insertBulk(
//           decoded.cast<Map<String, dynamic>>(),
//           tableName: "default_table",
//         );
//       }
//
//       print("✅ Database Restore Complete");
//
//     } catch (e) {
//       print("❌ Failed to restore DB: $e");
//     }
//   }
