
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/More_page/setpattern.dart';
import 'package:new_project_2025/view/home/widget/profile_page/profile_page.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import '../../../../services/API_services/API_services.dart';
import '../../../../view_model/Gdrivefileupload/backupservice.dart';
import '../../../../view_model/Gdrivefileupload/gdrivebackuprestore.dart';

import '../../../../view_model/Gdrivefileupload/restoredata.dart';
import '../More_page/CheckPattern.dart';
import '../More_page/jsondatamodal.dart';
import '../More_page/pattern_lock.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: const Color(0xFF00897B),
      ),
      home: const SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String token = "";
  String timestamp = "";
  String userid = "";
  String? fileId;
  String status = "Ready";
  String? pickedJsonPreview = "";
  String? pickedFileName = "";
  static const platform = MethodChannel("save_drive/channel");
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


  Future<String> sendJsonToServer(String jsonContent) async {
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
          "token": token,
        },
      );

      print("✅ Raw response string:\n$response");

      var jsonResponse = json.decode(response);
      print("✅ Json response string:\n$jsonResponse");
      return jsonResponse['message'] ?? 'Upload successful';

    } catch (e) {
      print("❌ Error sending JSON: $e");
      return 'Failed to upload: ${e.toString()}';
    }
  }
  void profileUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;


    print("Token is $token");

    timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());


    ApiHelper api = ApiHelper();


    try {
      String logresponse = await api.postApiResponse(
        "getUserDetails.php",
        {},
      );
      debugPrint("Response1: $logresponse");
      var res = json.decode(logresponse);
      debugPrint("res is...$res");

      var data = res['data'];
      //print("Data is $data");

      userid = data['id'];
    //  print("userData is $userid");

    } catch (e) {
      print("Error: $e");
    }
  }





  Future<List<dynamic>?> fetchJsonFromUrl() async {
    print("userid isss : $userid");
    final url = Uri.parse('https://mysaving.in/IntegraAccount/backups/${userid}.json');
    print("url isss : $url");
    try {
      final response = await http.get(url);
      print("Status code: ${response.statusCode}");
      print("Body: ${response.body}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ JSON fetched successfully: $data');

        if (data is List) {
          return data;
        } else {
          print('⚠️ JSON is not a list');
          return null;
        }
      } else {
        print('❌ Server returned status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching JSON: $e');
      return null;
    }
  }

  @override

  void initState() {


    super.initState();

    profileUser();
    // Initialization code here

  }
   _showFetchedJson(BuildContext context) async {

   final jsonData = await fetchJsonFromUrl();
   print("Fetched json datas are $jsonData");

   await fetchJsonFromUrl();

 var jdata = jsonData.toString();


    if (jsonData != null) {
      showDialog(
        context: context,
        builder: (_) => Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Container(
            width: 100,
            height: 200,

            child: AlertDialog(
              title: const Text('Fetched JSON'),
              content: SingleChildScrollView(
                child: Text(const JsonEncoder.withIndent('  ').convert(jsonData)),
              ),
              actions: [
                TextButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch JSON')),
      );
    }
  }
  Future<void> fetchAndSaveJsonFromUrl() async {
    try {
      // 1️⃣ Fetch JSON from your online backup
      List<dynamic>? jsonData = await fetchJsonFromUrl();

      if (jsonData == null) {
        print("⚠️ No valid JSON fetched from server.");
        return;
      }

      // 2️⃣ Convert the data to a string for storage
      String jsonString = jsonEncode(jsonData);

      // 3️⃣ Save into local SQLite database
      final dbHelper = DatabaseHelper();
      //await ImportDatabaseHelper.instance.insertImportedJson(jsonString);

      print("✅ JSON data saved to local database successfully!");

    } catch (e) {
      print("❌ Error saving fetched JSON to database: $e");
    }
  }

  String? savedUri;
  String? jsonPreview;
  bool appLockEnabled = false;
  var applock = "";
  Future<void> saveAppLockState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_lock_enabled', value);
    print("Saved App Lock state: $value");
  }

  Future<void> loadAppLockState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      appLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
    });
    print("Loaded App Lock state: $appLockEnabled");
  }
  Future<void> restoreUsingFileId() async {
    if (fileId == null || fileId!.isEmpty) {
      setState(() => status = "❌ fileId is empty.");
      return;
    }

    try {
      final result = await platform.invokeMethod("readFileByUri", {
        "uri": fileId,
      });

      pickedJsonPreview =
          const JsonEncoder.withIndent("  ").convert(result["content"]);

      pickedFileName = "Restored from stored fileId";
      status = "✔ Restored using fileId";

      setState(() {});
    } catch (e) {
      setState(() => status = "ERROR: $e");
    }
  }

  Future<void> restoreDatabaseFromJson(String jsonContent) async {
    try {
      final decoded = json.decode(jsonContent);

      if (decoded is! Map<String, dynamic>) {
        print("❌ Invalid JSON structure");
        return;
      }

      final db = DatabaseHelper();

      print("🗑 Clearing old data...");
     // await db.clearAll();

      print("♻ Restoring tables...");

      for (var entry in decoded.entries) {
        final tableName = entry.key;
        final rows = entry.value;

        if (rows is! List) {
          print("⚠️ Skipping non-list data in table $tableName");
          continue;
        }

        for (var row in rows) {
          if (row is Map<String, dynamic>) {
            // Decode Base64 → Uint8List for images
            row.updateAll((key, value) {
              if (value is String && _isBase64(value)) {
                try {
                  print("vlaue is $value");
                  return base64Decode(value);
                } catch (_) {}
              }
              return value;
            });

            await db.insertIntoTable(tableName, row);
          }
        }
      }

      print("✅ Restore DONE!");

    } catch (e) {
      print("❌ Restore failed: $e");
    }
  }

  bool _isBase64(String str) {
    final base64Regex = RegExp(r'^[A-Za-z0-9+/=]+$');
    return base64Regex.hasMatch(str);
  }

  Future<void> doBackup() async {

    final uri = await BackupService.backupToDrive();
    setState(() {
      savedUri = uri;
      status = uri == null ? "❌ Backup failed" : "✅ Backup saved!\n$uri";
    });
  }


  void _confirmRestore(BuildContext context, String jsonContent) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Restore Backup"),
          content: Text("This will replace all current data. Continue?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                await restoreDatabaseFromJson(jsonContent);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Restore completed!")),
                );
              },
              child: Text("Restore"),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color(0xFF00897B),
      ),
      body:
      Container(
        color: Colors.white,
        height: double.infinity,
        child: ListView(
          children: [
            _buildSettingItem(
              title: 'Profile',
              hasToggle: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),

            _buildSettingItem(
              title: 'Bill Header',
              hasToggle: false,
              onTap: () {
                print('Bill Header tapped');
              },
            ),
            _buildSettingItem(
              title: 'App Lock',
              hasToggle: true,
              isToggled: appLockEnabled,
              onToggle: (value) {
                setState(() {
                  appLockEnabled = value;

                });
                saveAppLockState(value);
                print('App Lock toggled: $value');
              },
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                setState(() {

                  applock = prefs.getString('lock_pattern') ?? "no valueee";
                });


                if (appLockEnabled == true || applock.isEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SetPattern()),
                  );
                } else {
                  print('App Lock is disabled');
                }
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => SetPattern()),
                // );
              },
            ),
            _buildSettingItem(
              title: 'Data Backup',
              textColor: Colors.grey[600],
              hasToggle: false,
              onTap: doBackup

            ),


            _buildSettingItem(
              title: 'Restore Your Data',
              textColor: Colors.grey[600],
              hasToggle: false,
                onTap: () async {
                  final restore = RestoreService();

                  final jsonMap = await restore.fetchLastBackupForPreview();

                  if (jsonMap == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No backup found")),
                    );
                    return;
                  }

                  showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text("Restore Backup?"),
                      content: SizedBox(
                        height: 250,
                        child: SingleChildScrollView(
                          child: Text(const JsonEncoder.withIndent("  ").convert(jsonMap)),
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.pop(c),
                        ),
                        TextButton(
                          child: const Text("Restore Now"),
                          onPressed: () async {
                            Navigator.pop(c);

                            final jsonString = json.encode(jsonMap);
                            final ok =
                            await restore.restoreDatabaseFromJson(jsonString);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok ? "Restore Completed" : "Restore Failed"),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }
            ),

            _buildSettingItem(
              title: 'App Update',
              hasToggle: false,
              onTap: () {
                print('App Update tapped');
              },
            ),
            _buildSettingItem(
              title: 'Purchase or Renewal',
              hasToggle: false,
              onTap: () {
                print('Purchase or Renewal tapped');
              },
            ),
            _buildSettingItem(
              title: 'Logout',
              hasToggle: false,
              onTap: () {
                print('Logout tapped');
              },
            ),
            _buildSettingItem(
              title: 'Delete Account',
              hasToggle: false,
              onTap: () {
                print('Delete Account tapped');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    Color? textColor,
    required bool hasToggle,
    bool isToggled = false,
    Function(bool)? onToggle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 10,
        ),

        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor ?? Colors.black,
          ),
        ),
        trailing:
            hasToggle
                ? Switch(
                  value: isToggled,
                  onChanged: onToggle,
                  activeTrackColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.grey.shade300,
                  activeColor: Colors.white,
                )
                : const Icon(Icons.chevron_right, size: 24, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
