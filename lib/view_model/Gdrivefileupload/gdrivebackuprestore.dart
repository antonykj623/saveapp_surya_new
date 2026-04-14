// // backup_restore_page.dart
// import 'package:flutter/material.dart';
// import 'package:new_project_2025/view_model/Gdrivefileupload/restoredata.dart';
//
// import 'backupservice.dart';
//
// class Uploadpage extends StatefulWidget {
//   @override
//   _BackupRestorePageState createState() => _BackupRestorePageState();
// }
//
// class _BackupRestorePageState extends State<Uploadpage> {
//   String status = "Ready";
//   String? savedUri;
//   String? jsonPreview;
//
//   Future<void> doBackup() async {
//     // final backupData = {
//     //   "time": DateTime.now().toIso8601String(),
//     //   "items": [
//     //     {"id": 1, "name": "Item A"},
//     //     {"id": 2, "name": "Item B"},
//     //   ]
//     // };
//
//     //final uri = await BackupService.backupToDrive(backupData);
// final uri = await BackupService.backupToDrive();
//     setState(() {
//       savedUri = uri;
//       status = uri == null ? "❌ Backup failed" : "✅ Backup saved!\n$uri";
//     });
//   }
//
//   Future<void> doRestore() async {
//
//   final data = await RestoreService().pickAndReadBackupFile();
//     if (data == null) {
//       setState(() => status = "❌ Restore failed");
//       return;
//     }
//
//     setState(() {
//       jsonPreview = data.toString();
//       status = "✅ Restore completed!";
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Backup & Restore")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(status, style: TextStyle(fontSize: 16)),
//             SizedBox(height: 20),
//
//             ElevatedButton(
//               onPressed: doBackup,
//               child: Text("Backup to Google Drive"),
//             ),
//
//             SizedBox(height: 20),
//
//             ElevatedButton(
//               onPressed: doRestore,
//               child: Text("Restore From Google Drive"),
//             ),
//
//             SizedBox(height: 30),
//
//             if (savedUri != null)
//               Text("Backup File URI:\n$savedUri",
//                   style: TextStyle(color: Colors.blue, fontSize: 14)),
//
//             SizedBox(height: 20),
//
//             if (jsonPreview != null)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("JSON Preview:",
//                       style:
//                       TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   SizedBox(height: 8),
//                   Container(
//                     height: 200,
//                     padding: EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade200,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: SingleChildScrollView(
//                       child: Text(
//                         jsonPreview!,
//                         style: TextStyle(fontFamily: "monospace"),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
