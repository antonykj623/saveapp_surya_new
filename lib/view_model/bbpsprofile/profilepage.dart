import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../services/API_services/API_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<HomeScreen> {
String _token = "";
  String? imageUrl = "";
  String? timestamp;


  void profileUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token')!;


    print("Token is $_token");

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


      setState(() {

        // Fixed: Correct URL construction
        String baseUrl = "https://mysaving.in/uploads/profile/";
        String profileImage = data['profile_image'] ?? ''; // Handle null case

        if (profileImage.isNotEmpty) {
          imageUrl =
              baseUrl + profileImage; // Fixed: Remove extra concatenation
          print("Complete Image URL: $imageUrl"); // Debug print
        } else {
          imageUrl = ""; // No image available
        }
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  var apidata = ApiHelper();

  File? _profileImage;
Future<void> uploadProfilePicture(File imageFile) async {
  final url = Uri.parse(
    'https://mysaving.in/IntegraAccount/api/uploadUserProfile.php',
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  final timestamp = DateTime.now().toUtc().toIso8601String();

  print('File path: ${imageFile.path}');
  print('File exists: ${await imageFile.exists()}');
  print('File size: ${await imageFile.length()}');

  final request =
  http.MultipartRequest('POST', url)
    ..headers.addAll({
      'Authorization': 'Bearer $token',
      'x-timestamp': timestamp,
    })

    ..files.add(
      await http.MultipartFile.fromPath(
        'file', // <-- field name expected by PHP backend
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
    );

  try {
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    try {
      final json = jsonDecode(response.body);
      print('Decoded JSON: $json');
    } catch (e) {
      print('Could not decode response as JSON: $e');
    }
  } catch (e) {
    print('Error uploading: $e');
  }
}
@override
void initState() {
  super.initState();
  profileUser();
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      drawer: Drawer(
        child: Column(
          children: [
                ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🔹 OPEN DRAWER BUTTON
                  // 🔹 OPEN DRAWER BUTTON
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, size: 28),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),

                  const SizedBox(width: 100),

                  // Logo + menu items
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Logo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 100.0),
                          child: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),



            const SizedBox(height: 60),

            // Greeting
            const Center(
              child: Text(
                'HELLO!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),


            ),

            const SizedBox(height: 50),

            // Profile Avatar
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                     //   backgroundColor: Colors.grey.shade300,
                        // Fixed: Proper image display logic
                        backgroundImage:
                        _profileImage != null
                            ? FileImage(
                          _profileImage!,
                        ) // Show picked image
                            : (imageUrl!.isNotEmpty
                            ?   NetworkImage(
                          imageUrl!,
                        ) // Show network image
                            : const AssetImage(
                          'assets/1.jpg',
                        ) // Show default image
                        )
                        as ImageProvider,
                        // Add error handling for network images
                        onBackgroundImageError:
                        imageUrl!.isNotEmpty
                            ? (exception, stackTrace) {
                          print('Error loading image: $exception');
                        }
                            : null,
                      ),

                    ],
                  ),

                  const SizedBox(width: 12),
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

            ),

            const SizedBox(height: 30),

            // Quick Actions
            Container(
              margin: const EdgeInsets.only(top: 120),
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: const [
                      _QuickAction(icon: Icons.receipt, label: 'Bill\nPayments'),
                      SizedBox(width:50),
                      _QuickAction(icon: Icons.credit_card, label: 'Credit\nCard'),
                      SizedBox(width: 50),
                      _QuickAction(icon: Icons.account_balance, label: 'Loan'),
                      SizedBox(width: 50),
                      _QuickAction(icon: Icons.savings, label: 'FD'),

                    ],
                  ),
                ),
              ),
            ),

            // Space so body doesn't hide behind bottom bar
            //  const SizedBox(height:  60),
          ],
        ),
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom:5.0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 50,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Services',
                style: TextStyle(
                  fontSize:25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  children: const [
                    _ServiceItem(label: 'Shopping'),
                    _ServiceItem(label: 'Travel'),
                    _ServiceItem(label: 'Offers'),
                    _ServiceItem(label: 'Property'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

// ================= QUICK ACTION =================
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickAction({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}

// ================= SERVICE ITEM =================
class _ServiceItem extends StatelessWidget {
  final String label;

  const _ServiceItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}
