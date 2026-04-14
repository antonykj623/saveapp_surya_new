
import 'dart:convert';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

import '../../../../../../Check_premiumdates/premiumdate.dart';
import '../../../../../../services/API_services/API_services.dart';
import '../../../home_screen.dart';
import '../password_details/password_details.dart';
import 'EditPasswordManager.dart';
class passwordModel {
  final int? keyid;
  final String title;
  final String uname;
  final String passwd;
  final String website;
  final String remarks;

  passwordModel({
    required this.keyid,
    required this.title,
    required this.uname,
    required this.passwd,
    required this.website,
    required this.remarks,
  });

  // Factory constructor for creating a new instance from a map
  factory passwordModel.fromJson(Map<String, dynamic> json) {
    return passwordModel(
      keyid:json['keyid'],
      title: json['title'],
      uname: json['uname'],
      passwd: json['passwd'],
      website: json['website'],
      remarks: json['remarks'],
    );
  }
  factory passwordModel.fromMap(Map<String, dynamic> map) {
    return passwordModel(
      keyid: map['keyid'] ?? '',
      title: map['title'] ?? '',
      uname: map['uname'] ?? '',
      passwd: map['passwd'] ?? '',
      website: map['website'] ?? '',
      remarks: map['remarks'] ?? '',


    );
  }
  Map<String, dynamic> toMap() {
    return {
      'keyid':keyid,
      'title': title,
      'uname': uname,
      'passwd': passwd,
      'website': website,
      'remarks': remarks,

    };
  }

  // Method to convert instance to map
  Map<String, dynamic> toJson() {
    return {
      'keyid':keyid,
      'title': title,
      'uname': uname,
      'passwd': passwd,
      'website': website,
      'remarks': remarks,
    };
  }

}
class SalesResponse {
  final int status;
  final String currentDate;
  final int premium;
  final String saveTrialStartDate;
  final String trialEndDate;
  final SalesData salesData;

  SalesResponse({
    required this.status,
    required this.currentDate,
    required this.premium,
    required this.saveTrialStartDate,
    required this.trialEndDate,
    required this.salesData,
  });

  factory SalesResponse.fromJson(Map<String, dynamic> json) {
    return SalesResponse(
      status: json["status"] is int
          ? json["status"]
          : int.tryParse(json["status"]?.toString() ?? '') ?? 0,
      currentDate: json["current_date"]?.toString() ?? DateTime.now().toString(),
      premium: int.tryParse(json["premium"]?.toString() ?? '') ?? 0,
      saveTrialStartDate: json["save_trial_start_date"]?.toString() ?? '',
      trialEndDate: json["trialenddate"]?.toString() ?? '',
      salesData: (json["sales_data"] == null || json["sales_data"] == '')
          ? SalesData.empty()
          : SalesData.fromJson(json["sales_data"] as Map<String, dynamic>),
    );
  }
}

class SalesData {
  final int id;
  final String billNoPrefix;
  final String billNo;
  final String regId;
  final String? stateId;
  final String regCode;
  final String productId;
  final String salesType;
  final String salesDate;
  final String expeDate;
  final double amount;
  final String binaryVal;
  final String currency;

  SalesData({
    required this.id,
    required this.billNoPrefix,
    required this.billNo,
    required this.regId,
    this.stateId,
    required this.regCode,
    required this.productId,
    required this.salesType,
    required this.salesDate,
    required this.expeDate,
    required this.amount,
    required this.binaryVal,
    required this.currency,
  });

  // ← Add this factory to provide a safe fallback when sales_data is missing/null
  factory SalesData.empty() {
    return SalesData(
      id: 0,
      billNoPrefix: '',
      billNo: '',
      regId: '',
      stateId: null,
      regCode: '',
      productId: '0',
      salesType: '',
      salesDate: '2000-01-01 00:00:00',
      expeDate: '2000-01-01 00:00:00',
      amount: 0.0,
      binaryVal: '',
      currency: '',
    );
  }

  factory SalesData.fromJson(Map<String, dynamic> json) {
    // Defensive access with fallback values and safe parsing
    final idVal = json["id"];
    final amtVal = json["amt"];

    return SalesData(
      id: idVal is int ? idVal : int.tryParse(idVal?.toString() ?? '') ?? 0,
      billNoPrefix: json["billno_prefix"]?.toString() ?? '',
      billNo: json["bill_no"]?.toString() ?? '',
      regId: json["reg_id"]?.toString() ?? '',
      stateId: json["state_id"]?.toString(),
      regCode: json["reg_code"]?.toString() ?? '',
      productId: json["product_id"]?.toString() ?? '0',
      salesType: json["sales_type"]?.toString() ?? '',
      salesDate: json["sales_date"]?.toString() ?? '2000-01-01 00:00:00',
      expeDate: json["expe_date"]?.toString() ?? '2000-01-01 00:00:00',
      amount: amtVal is double
          ? amtVal
          : double.tryParse(amtVal?.toString() ?? '') ?? 0.0,
      binaryVal: json["binary_val"]?.toString() ?? '',
      currency: json["currency"]?.toString() ?? '',
    );
  }
}

var id;
SalesResponse? premiumData; // Add this variable


Future<SalesResponse> checkPremiumStatus() async {
  final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  final response = await ApiHelper().postApiResponse(
    'checkPremiumDates.php',
    {'timestamp': timestamp},
  );
  final jsonData = jsonDecode(response);

   print("JsonDatas are ....$jsonData");
  return SalesResponse.fromJson(jsonData);

}


bool isSubscriptionActive(SalesResponse data, SalesData data1) {
  final DateTime now = DateTime.parse(data.currentDate);

  // --------------------------------------------------------
  // 1️⃣ TRIAL MODE → id is ZERO or EMPTY AND productId == 2
  // --------------------------------------------------------
  if (data.salesData == null || data.salesData!.id == 0)
  {

    final DateTime trialStart = DateTime.parse(data.saveTrialStartDate);
    final DateTime trialEnd   = DateTime.parse(data.trialEndDate);

    bool isTrialActive =  now.isAfter(trialStart) && now.isBefore(trialEnd);


    print("🟡 Trial Active (ID = 0 & productId = 2): $isTrialActive");
    return isTrialActive;
  }

  // --------------------------------------------------------
  // 2️⃣ PAID SUBSCRIPTION → id != 0
  // --------------------------------------------------------
  if (data.salesData.id != 0 && data1.productId == 2) {
    final DateTime startDate = DateTime.parse(data.salesData.salesDate);
    final DateTime endDate   = DateTime.parse(data.salesData.expeDate);

    bool isPaidActive = now.isAfter(startDate) && now.isBefore(endDate);

    print("🟢 Paid Subscription Active: $isPaidActive");
    return isPaidActive;
  }

  // If nothing matched
  return false;
}
List<String> _filteredItems = [];
TextEditingController _searchController = TextEditingController();

class  listpasswordData extends StatefulWidget {

  const listpasswordData({super.key});

  @override
  State<listpasswordData> createState() => _Home_ScreenState();
}

List<Map<String, dynamic>> _foundUsers = [];

class _Home_ScreenState extends State<listpasswordData> {
  bool isLoading = false;

  List<passwordModel> docLinks = [];
  int currentYear = DateTime.now().year;
  void _loadData() async {
    final rawData = await DatabaseHelper().fetchAllpassData();
    List<passwordModel> loadedLinks = [];
    for (var entry in rawData) {
      final keyId = entry['keyid'];
      final jsonString = entry['data'];

      try {
        final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
        decodedMap['keyid'] = keyId; // Add keyId
        loadedLinks.add(passwordModel.fromMap(decodedMap));
      } catch (e) {
        print("Error decoding JSON: $e");
      }
    }

    setState(() {
      docLinks = loadedLinks;
    });
  }
  Future<void> loadPremium() async {
    premiumData = await checkPremiumStatus();

    print("PREMIUM DATA LOADED $premiumData");
  }
  @override
  initState() {
    super.initState();
    _loadData();
    loadPremium();
  }
  void showPremiumEndedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Premium Expired"),
          content: Text("Your premium has ended. Please update to continue."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
  Future<void> _handleDelete(int keyid) async {
    setState(() => isLoading = true);
    await Future.delayed(Duration.zero);
    await DatabaseHelper().deleteByFieldId('TABLE_PASSWORD', keyid);
    _loadData();
    await Future.delayed(Duration(seconds: 2));

    setState(() => isLoading = false);
  }

  String name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: Stack(
        children: [
          Column(
            children: [
              Container(

                width: double.infinity,
                padding:  EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical:10,),
                decoration:  BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFF093fb)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                   //   onTap: () => Navigator.pop(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top:28.0),
                            child: Container(
                            //  padding: EdgeInsets.only(top: 5),
                              height: 35, width: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.arrow_back, color: Colors.white),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => SaveApp()), // Your new home screen
                                        (Route<dynamic> route) => false, // Predicate to remove all previous routes
                                  );

                                 // Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 25.0),
                            child: Text(
                              ' Password Manager',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),

                  ],
                ),
              ),
              Expanded(
                child:

                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(

                    // decoration: BoxDecoration(
                    //   gradient: LinearGradient(
                    //     colors: [
                    //       Colors.blue,           // Start with white
                    //       Color(0xFFCFD1EE),      // Light BlueGrey (BlueGrey[100])
                    //     ], // white to BlueGrey[100] // BlueGrey[700] to BlueGrey[100]
                    //     //   colors: [Color(0xFF001010), Color(0xFF70e2f5)],
                    //     begin: Alignment.topCenter,
                    //     end: Alignment.bottomCenter,
                    //   ),
                    //   borderRadius: BorderRadius.circular(20),
                    // ),
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: DatabaseHelper().getAllData('TABLE_PASSWORD'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        final items = snapshot.data ?? [];
                        print("Items areeeee$items");

                        if (items.isEmpty) {
                          return const Center(child: Text("No documents found"));
                        }

                        return ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final keyId = item['keyid']; // <-- Get correct keyid directly
                            final dataJson = jsonDecode(item['data'] ?? '{}');

                            return GestureDetector(
                              onTap: () async {
                                final passwordItem = passwordModel.fromMap({
                                  'keyid': keyId,
                                  'title': dataJson['title'] ?? '',
                                  'uname': dataJson['uname'] ?? '',
                                  'passwd': dataJson['passwd'] ?? '',
                                  'website': dataJson['website'] ?? '',
                                  'remarks': dataJson['remarks'] ?? '',
                                });

                                // Navigate to EditPasswordPage (you need to modify EditPasswordPage to accept passwordModel)
                             // final result =  await Navigator.push(
                             //      context,
                             //      MaterialPageRoute(
                             //        builder: (context) => EditPasswordPage(entry: passwordItem ),
                             //      ),
                             //    );

                                if ( premiumData?.salesData.productId == "2" ) {

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditPasswordPage(entry: passwordItem ),
                                    ),
                                  );
                                  // Refresh the data if update was successful
                                 // _loadData();
                                  // optional, depending on your logic
                                }
                                else{
                                  showPremiumEndedDialog(context);
                                }
                              },
                              child: Card(
                                elevation: 5,
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Title: ${dataJson['title'] ?? 'N/A'}",
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text("Username: ${dataJson['uname'] ?? 'N/A'}",
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () async {
                                              if (keyId != null) {
                                                await _handleDelete(keyId);
                                              }
                                            },
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),



                            );
                          },
                        );

                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),

      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 40.0,bottom: 50),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            Spacer(),
            Spacer(),
            Spacer(),
            Spacer(),
            Spacer(),
            Spacer(),
            Spacer(),
            Container(
              height: 65,

              child: FloatingActionButton(
                backgroundColor: Colors.red,
                tooltip: 'Increment',
                shape: const CircleBorder(),
                onPressed: () {

                  final bool active = isSubscriptionActive(
                    premiumData!,
                    premiumData!.salesData,
                  );

                  if (active) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddPasswordPage()),
                    );
                  } else {
                    showPremiumEndedDialog(context);
                  }


                },
                child: const Icon(Icons.add, color: Colors.white, size: 25),
              ),
            ),
            //  Text('Home'),
            Spacer(),
          ],
        ),
      ),
    );

    //  return   Placeholder();
  }
}



