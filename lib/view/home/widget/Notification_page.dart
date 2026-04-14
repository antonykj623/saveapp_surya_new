
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/API_services/API_services.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {

    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    ApiHelper api = ApiHelper();

    try {
      String response =
      await api.getApiResponse("getNotificationsData.php?timestamp=$timestamp");
      debugPrint("Response: $response");

      final res = json.decode(response);

      if (res['status'] == 1 && res['data'] is List) {
        setState(() {
          notifications.addAll(res['data']);
          isLoading = false;
        });
      } else {
        print("⚠️ Invalid or empty data");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Error fetching notifications: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? Center(child: Text("No notifications available"))
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading:Container(
                width: 40,
                height: 40,
                color: Colors.teal, // Replace with your desired color
                child: Image.asset('assets/ic_saveicon.png'),
              ),
              title: Text(
                notification["title"] ?? "No title",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(notification["message"] ?? "No message"),
              trailing: Text(
                notification["created_date"]?.split(" ")?.first ?? "",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}
