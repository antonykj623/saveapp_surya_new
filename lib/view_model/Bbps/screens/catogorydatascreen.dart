import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:new_project_2025/view_model/Bbps/screens/selectproviderPage.dart';
import 'package:new_project_2025/view_model/Bbps/screens/worldlinepayment_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catogoryapi.dart';
import 'globalvariable.dart';


/// ==========================
/// MODELS
/// ==========================

class ApiResponse {
  final List<CustomParamResp> customParamResp;

  ApiResponse({required this.customParamResp});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      customParamResp: (json['customParamResp'] as List)
          .map((e) => CustomParamResp.fromJson(e))
          .toList(),
    );
  }
 }
class BillFetchResponse {
  final bool success;
  final String? message;
  final String? billId;
  final String? billNumber;
  final String? billDate;
  final String? dueDate;
  final double? billAmount;
  final String? consumerName;
  final String? billPeriod;
  final Map<String, dynamic>? additionalInfo;

  BillFetchResponse({
    required this.success,
    this.message,
    this.billId,
    this.billNumber,
    this.billDate,
    this.dueDate,
    this.billAmount,
    this.consumerName,
    this.billPeriod,
    this.additionalInfo,
  });

  factory BillFetchResponse.fromJson(Map<String, dynamic> json) {
    final billerResp = json['billerResponse'] as Map<String, dynamic>? ?? {};
    final genericResp = json['genericResponse'] as Map<String, dynamic>?;

    final bool success =
        genericResp?['status'] == 'Success' ||
            genericResp?['statusCode'] == '200' ||
            json['status'] == 'BILL_FETCH_SUCCESS' ||
            (json['success'] as bool? ?? false);

    final String? billId =
        json['billId'] as String? ?? billerResp['billId'] as String?;

    print('🔑 Extracted billId: $billId');
    // ── Amount  ────────────────────────────────────────────────────────────
    double? amount;
    final amountRaw = billerResp['amount'] ?? json['amount'];
    if (amountRaw != null) {
      if (amountRaw is num) {
        amount = amountRaw.toDouble() / 100;
      } else if (amountRaw is String) {
        final parsed = double.tryParse(amountRaw.replaceAll(',', ''));
        if (parsed != null) amount = parsed / 100; // ✅ paise → rupees
      }
    }
    print('💰 Raw amount value : $amountRaw');
    print('💰 Converted amount : ₹$amount');

    Map<String, dynamic>? additionalInfoMap;
    final rawAdditional = json['additionalInfo'];
    if (rawAdditional is List) {
      additionalInfoMap = {
        for (var item in rawAdditional)
          if (item is Map && item['name'] != null)
            item['name'].toString(): item['value']?.toString() ?? '',
      };
    } else if (rawAdditional is Map) {
      additionalInfoMap = Map<String, dynamic>.from(rawAdditional);
    }

    return BillFetchResponse(
      success: success,
      billId: billId,
      message:
      genericResp?['message'] as String? ??
          json['message'] as String? ??
          json['responseMessage'] as String?,
      billNumber:
      billerResp['billNumber'] as String? ??
          json['billNumber'] as String? ??
          json['billNo'] as String?,
      billDate:
      billerResp['billDate'] as String? ??
          json['billDate'] as String? ??
          json['billGenerationDate'] as String?,
      dueDate:
      billerResp['dueDate'] as String? ??
          json['dueDate'] as String? ??
          json['billDueDate'] as String?,
      billAmount: amount,
      consumerName:
      billerResp['customerName'] as String? ??
          json['consumerName'] as String? ??
          json['customerName'] as String? ??
          json['name'] as String?,
      billPeriod:
      billerResp['billPeriod'] as String? ??
          json['billPeriod'] as String? ??
          json['billingPeriod'] as String?,
      additionalInfo: additionalInfoMap,
    );
  }
}
// class BillFetchResponse {
//   final GenericResponse? genericResponse;
//   final String? billId;
//   final String? billNumber;
//   final String? billDate;
//   final String? dueDate;
//   final dynamic billerResponse;
//   final dynamic additionalInfo;
//   final dynamic customerParams;
//   final dynamic billerResponseList;
//
//   BillFetchResponse({
//     this.genericResponse,
//     this.billId,
//     this.billerResponse,
//     this.additionalInfo,
//     this.customerParams,
//     this.billerResponseList, this.billNumber, this.billDate, this.dueDate,
//   });
//
//   /// FROM JSON
//   factory BillFetchResponse.fromJson(Map<String, dynamic> json) {
//     return BillFetchResponse(
//       genericResponse: json['genericResponse'] != null
//           ? GenericResponse.fromJson(json['genericResponse'])
//           : null,
//       billId: json['billId'],
//       billerResponse: json['billerResponse'],
//       additionalInfo: json['additionalInfo'],
//       customerParams: json['customerParams'],
//       billerResponseList: json['billerResponseList'],
//     );
//   }
//
//   /// TO JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'genericResponse': genericResponse?.toJson(),
//       'billId': billId,
//       'billerResponse': billerResponse,
//       'additionalInfo': additionalInfo,
//       'customerParams': customerParams,
//       'billerResponseList': billerResponseList,
//     };
//   }
//
//   /// COPY WITH
//   BillFetchResponse copyWith({
//     GenericResponse? genericResponse,
//     String? billId,
//     dynamic billerResponse,
//     dynamic additionalInfo,
//     dynamic customerParams,
//     dynamic billerResponseList,
//   }) {
//     return BillFetchResponse(
//       genericResponse: genericResponse ?? this.genericResponse,
//       billId: billId ?? this.billId,
//       billerResponse: billerResponse ?? this.billerResponse,
//       additionalInfo: additionalInfo ?? this.additionalInfo,
//       customerParams: customerParams ?? this.customerParams,
//       billerResponseList: billerResponseList ?? this.billerResponseList,
//     );
//   }
// }

class GenericResponse {
  final String? message;
  final String? remarks;
  final String? status;
  final int? statusCode;

  GenericResponse({
    this.message,
    this.remarks,
    this.status,
    this.statusCode,
  });

  /// FROM JSON
  factory GenericResponse.fromJson(Map<String, dynamic> json) {
    return GenericResponse(
      message: json['message'],
      remarks: json['remarks'],
      status: json['status'],
      statusCode: json['statusCode'] is int
          ? json['statusCode']
          : int.tryParse(json['statusCode']?.toString() ?? ''),
    );
  }

  /// TO JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'remarks': remarks,
      'status': status,
      'statusCode': statusCode,
    };
  }

  /// COPY WITH
  GenericResponse copyWith({
    String? message,
    String? remarks,
    String? status,
    int? statusCode,
  }) {
    return GenericResponse(
      message: message ?? this.message,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
    );
  }
}
class CustomParamResp {
  final String customParamName;

  final String dataType;
  final bool optional;
  final int minLength;
  final int maxLength;
  final String regex;
  final bool visibility;
  final dynamic values;

  CustomParamResp({
    required this.customParamName,
    required this.dataType,
    required this.optional,
    required this.minLength,
    required this.maxLength,
    required this.regex,
    required this.visibility,
    this.values,
  });

  factory CustomParamResp.fromJson(Map<String, dynamic> json) {
    return CustomParamResp(
      customParamName: json['customParamName'] ?? '',
      dataType: json['dataType'] ?? '',
      optional: json['optional'] ?? false,
      minLength: json['minLength'] ?? 0,
      maxLength: json['maxLength'] ?? 0,
      regex: json['regex'] ?? '',
      visibility: json['visibility'] ?? true,
      values: json['values'],
    );
  }
}

/// ==========================
/// DYNAMIC FORM PAGE
/// ==========================

class DynamicCustomFormPage extends StatefulWidget {
  final ApiResponse apiResponse;
  final String billerid;
  final String catname;
  final String billername;

  const DynamicCustomFormPage({super.key, required this.apiResponse, required this.billerid, required this.catname,required this.billername});

  @override
  State<DynamicCustomFormPage> createState() =>
      _DynamicCustomFormPageState();
}



class _DynamicCustomFormPageState
    extends State<DynamicCustomFormPage> {
  final Map<String, dynamic> userInputs = {};
  final Map<String, TextEditingController> controllers = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? billData;

  bool loading = false;
  bool showBillCard = false;
  @override
  void initState() {
    super.initState();
//print(widget.apiResponse.customParamResp);
    for (var param in widget.apiResponse.customParamResp) {
      if (!param.visibility) continue;

      if (_isTextType(param)) {
        controllers[param.customParamName] =
            TextEditingController(
                text: param.values?.toString() ?? '');
      }

      userInputs[param.customParamName] =
          param.values ?? _defaultValue(param.dataType);
      print( param.values);
    }
  }
  String? billId1;

  Future<String?> fetchBillByIdPost({

    required String tenantId,
    required String billerId,
    required String billerName,
    required String billerCategory,
    required String paymentChannel,
  }) async
  {


    final url = Uri.parse(
      "https://bbps-staging.digiledge.in/agent/bill-payment-new/couapp/bills/fetch",
    );
    List<Map<String, dynamic>> buildCustomerTags() {
      return widget.apiResponse.customParamResp
          .where((param) => param.visibility)
          .map((param) {
        return {
          "name": param.customParamName,
          "value": userInputs[param.customParamName]?.toString() ?? ""
        };
      }).toList();
    }

    try {
      print(jsonEncode(buildCustomerTags()));
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "tenantId": "FE41",
          "agentId": "FE41FE16MOBU00000001",
          "x-digiledge-key": "b8rFeserZ7GnUEPW2Z5eLkauqqGhJq",

          // If required:
          // "Authorization": "Bearer YOUR_TOKEN",
        },
        body: jsonEncode({
          "tenantId": tenantId,
          "billerId": billerId,
          "billerName": billerName,
          "billerCategory": billerCategory,
          "macAdress": "ddc60054-4f14-44cc-b504-85b77c882fa8",
          "customerMobNo": "9747497967",
          "remitterName": "Antony jackson",
          "paymentChannel":"Mobile (Pre-login)",
          "customerParamsRequest": {
            "tags":buildCustomerTags()
           //  [
           //    {
           //      "name": ""
           //      "value":"9910606584"
           // //"value": "${controllers.values}"
           //    }
           //  ]
          },
          "deviceBlockTags": [
            {
              "name": "IP",
              "value": "192.168.1.25"
            },
            {
              "name": "IMEI",
              "value": "286139785555"
            },
            {
              "name": "OS",
              "value": "Android"
            },
            {
              "name": "APP",
              "value": "SAVE APP"
            }
          ],
          "remitterIdentity": [
            {
              "name": "AADHAAR",
              "value": "9183 0074 1256"
            },
            {
              "name": "PAN",
              "value": "AAAPA1234A"
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Success Response: $data");
        final billResponse = BillFetchResponse.fromJson(data);
        print("Success billResponse : $billResponse");
       return billResponse.billId;


      } else {
        print("Error Code: ${response.statusCode}");
        print("Error Body: ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> pollBillStatus(String billId) async {

    const int maxRetries = 10;
    const int delaySeconds = 3;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {

      final billData = await getBillByBillId(billId);

      if (billData == null) {
        await Future.delayed(Duration(seconds: delaySeconds));
        continue;
      }

      String status =
      (billData['genericResponse']?['status'] ?? "").toUpperCase();

      print("Attempt $attempt -> Status: $status");

      if (status == "SUCCESS") {
        print("✅ Bill fetched successfully");
        return billData;
      }

      if (status == "FAILED") {
        print("❌ Bill fetch failed");
        return billData;
      }

      if (status == "INPROGRESS") {
        print("⏳ Bill still processing...");
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }

    print("⏱ Timeout reached");
    return null;
  }

  Future<Map<String, dynamic>?> getBillByBillId(String billId) async {
    print("Fetching bill with ID: $billId");


    setState(() {
      loading = true;
      showBillCard = false;
    });
    // Get token from SharedPreferences
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? token = prefs.getString('token');
   // print("Token: $token");

    // Construct URL with billId as query parameter
    final url = Uri.parse(
        "https://bbps-staging.digiledge.in/agent/bill-payment-new/couapp/bills/fetch/byId?billId=$billId"
    );
    print("Request URL: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "tenantId": "FE41",
          "agentId": "FE41FE16MOBU00000001",
          "x-digiledge-key": "b8rFeserZ7GnUEPW2Z5eLkauqqGhJq",
          // if (token != null) "Authorization": "Bearer $token",
        },
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {

          return decoded;
        } else {
          print("Unexpected response format: not a Map");
          return null;
        }
      } else {
        print("Failed to fetch bill. Status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception occurred: $e");
      return null;
    }
  }
  bool _isTextType(CustomParamResp param) {
    final type = param.dataType.toLowerCase();
    return type == 'string' ||
        type == 'numeric' ||
        type == 'number';
  }

  dynamic _defaultValue(String type) {
    switch (type.toLowerCase()) {
      case 'boolean':
        return false;
      case 'numeric':
      case 'number':
      case 'string':
        return '';
      default:
        return null;
    }
  }

  @override
  void dispose() {
    for (var c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// ==========================
  /// BILL CARD UI
  /// ==========================
  Widget buildRow(String title, dynamic value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Title
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),

          const SizedBox(width: 10),

          /// Value
          Expanded(
            flex: 6,
            child: Text(
              value?.toString() ?? "-",
              textAlign: TextAlign.right,
              softWrap: true,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isAmount ? FontWeight.bold : FontWeight.w500,
                color: isAmount ? Colors.green : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget buildBillCard() {

    if (billData == null) return const SizedBox();

    final response = billData?['billerResponse'] ?? {};

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Row(
            children: [
              Icon(Icons.receipt_long, color: Colors.green),
              SizedBox(width: 8),
              Text(
                "Bill Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          buildRow("Consumer Name", response['customerName']),
          buildRow("Bill Number", response['billNumber']),
          buildRow("Bill Date", response['billDate']),
          buildRow("Due Date", response['dueDate']),
          buildRow("Bill Period", response['billPeriod']),

          const Divider(),

          buildRow(
            "Bill Amount",
            "₹ ${response['amount']}",
            isAmount: true,
          ),

          const SizedBox(height: 10),


          buildRow(
            "Bill Unique Number",
            billData?['billId'],
          ),
        ],
      ),
    );
  }
  Future<void> makeBBPSPayment({
    required String billId,
    required double amount,
  }) async {

    final url = Uri.parse(
      "https://bbps-staging.digiledge.in/agent/bbps/pay-bill",
    );

    try {

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "tenantId": "FE41",
          "agentId": "FE41FE16MOBU00000001",
          "x-digiledge-key": "b8rFeserZ7GnUEPW2Z5eLkauqqGhJq",
        },
        body: jsonEncode({
          "billId": billId,
          "amount": amount
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ BBPS Payment Success: $data");
      } else {
        print("❌ BBPS Payment Failed: ${response.body}");
      }

    } catch (e) {
      print("⚠️ BBPS Payment Exception: $e");
    }
  }
  Future<void> payBill() async {


final response2 = billData?['billerResponse'] ?? {};



    if (response2.statusCode == 200) {
      print("Success paymentgateway response is : ${response2.body}");
    } else {
      print("Failed: ${response2.body}");
    }
  }
  Widget payButton() {

    if (billData == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: SizedBox(
        height: 50,
        width: double.infinity,




    child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),

          onPressed: () {
    final response = billData?['billerResponse'] ?? {};
    BillFetchResponse fetchedBill = BillFetchResponse(
      billId: billData?['billId'],
      billNumber: response['billNumber'],
      billDate: response['billDate'],
      dueDate: response['dueDate'],success: true,
    );
    Map<String,String> customerParams = {};
    userInputs.forEach((key, value) {
      customerParams[key] = value.toString();
    });
    print("PAY BUTTON CLICKED"); // 👈 Add this


            double amount = (double.tryParse(response['amount'].toString()) ?? 0) / 100;
            print("Proceed to Payment");
            print("Amount sent to Worldline: $amount");


            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BBPSPaymentScreen(
                  biller: BillerModel(
                    billerId: widget.billerid,
                    billerName: widget.billername, billerCategory: '', billerCoverage: '', paymentAmountExactness: '', billerIcon: '',
                  ),
                  categoryName: widget.catname,
                  customerParams: customerParams,
                  amount: amount,
                  fetchedBill: fetchedBill,
                  customerMobNo: "9747497967",
                ),
              ),
            );
          },
          child: const Text(
            "PAY NOW",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
  /// ==========================
  /// UI
  /// ==========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: Text("${widget.catname}")),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// Category Title
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.blue,
                child: Text(
                  widget.catname,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Dynamic Fields List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: widget.apiResponse.customParamResp.length,
                itemBuilder: (context, index) {

                  final param = widget.apiResponse.customParamResp[index];

                  if (!param.visibility) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildDynamicField(param),
                  );
                },
              ),

              const SizedBox(height: 10),

              /// Fetch Bill Button
              ElevatedButton(
                onPressed: () async {

                  setState(() {
                    loading = true;
                  });

                  billId1 = await fetchBillByIdPost(
                    tenantId: "FE41",
                    billerId: widget.billerid,
                    billerName: widget.billername,
                    billerCategory: widget.catname,
                    paymentChannel: "Mobile (Pre-login)",
                  );

                  if (billId1 != null) {

                    final fullData = await pollBillStatus(billId1!);

                    if (fullData != null) {

                      setState(() {
                        billData = fullData;
                        showBillCard = true;
                        loading = false;
                      });

                    } else {

                      setState(() {
                        loading = false;
                      });

                    }
                  }
                },
                child: const Text("Fetch Bill"),
              ),

              const SizedBox(height: 20),

              /// Loading
              if (loading)
                const CircularProgressIndicator(),

              /// Bill Card
              if (showBillCard) buildBillCard(),

              /// Pay Button
              if (showBillCard) payButton(),

              const SizedBox(height: 30),

            ],
          ),
        ),
      ),
    );
  }

  /// ==========================
  /// UNIVERSAL FIELD BUILDER
  /// ==========================

  Widget _buildDynamicField(CustomParamResp param) {
    final type = param.dataType.toLowerCase();

    /// 🔹 DROPDOWN (if API sends list values)
    if (param.values is List &&
        (type == 'string' || type == 'numeric')) {
      final List listValues = param.values;

      return DropdownButtonFormField(
        decoration: InputDecoration(
          labelText: param.customParamName,
          border: const OutlineInputBorder(),
        ),
        items: listValues
            .map((e) => DropdownMenuItem(
          value: e,
          child: Text(e.toString()),
        ))
            .toList(),
        onChanged: (value) {
          userInputs[param.customParamName] = value;
        },
        validator: (value) {
          if (!param.optional && value == null) {
            return "${param.customParamName} is required";
          }
          return null;
        },
      );
    }

    /// 🔹 BOOLEAN
    if (type == 'boolean') {
      return SwitchListTile(
        title: Text(param.customParamName),
        value:
        userInputs[param.customParamName] ?? false,
        onChanged: (val) {
          setState(() {
            userInputs[param.customParamName] = val;
          });
        },
      );
    }

    /// 🔹 TEXT / NUMERIC
    return TextFormField(
      controller: controllers[param.customParamName],
      keyboardType:
      (type == 'numeric' || type == 'number')
          ? TextInputType.number
          : TextInputType.text,
      inputFormatters:
      (type == 'numeric' || type == 'number')
          ? [FilteringTextInputFormatter.digitsOnly]
          : [],
      maxLength:
      param.maxLength > 0 ? param.maxLength : null,
      decoration: InputDecoration(
        labelText: param.customParamName,
        border: const OutlineInputBorder(),
        counterText: "",
      ),
      validator: (value) {
        if (!param.optional &&
            (value == null || value.isEmpty)) {
          return "${param.customParamName} is required";
        }

        if (param.minLength > 0 &&
            value!.length < param.minLength) {
          return "Minimum ${param.minLength} characters required";
        }

        if (param.regex.isNotEmpty) {
          final regExp = RegExp(param.regex);
          if (!regExp.hasMatch(value!)) {
            return "Invalid ${param.customParamName}";
          }
        }

        return null;
      },
      onChanged: (value) {
        userInputs[param.customParamName] = value;
      },
    );
  }

  /// ==========================
  /// SUBMIT
  /// ==========================

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      print("Submitted Data:");


      // userInputs.forEach((key, value) {
      //   print("$key : $value");
      // });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Form Submitted Successfully")),
      );
    }
  }
}
