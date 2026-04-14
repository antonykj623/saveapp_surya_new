// backup_preview_page.dart
import 'package:flutter/material.dart';

class BackupPreviewPage extends StatelessWidget {
  final String jsonContent;

  BackupPreviewPage({required this.jsonContent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Backup Preview"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Text(
            jsonContent,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
