
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/dynamic_extensions.dart';
import 'package:http/http.dart' as http;
 import 'package:new_project_2025/view_model/Bbps/screens/selectproviderPage.dart';

import 'catogoryapi.dart';
import 'catogorycard.dart';
import 'catogorydatascreen.dart';

class ElectricityScreen extends StatefulWidget {
  final String biller;
  final String billid;
  final String categoryName;
  final String categoryId;

  const ElectricityScreen({
    Key? key,
    required this.categoryName,
    this.categoryId = '', required this.biller, required this.billid,
  }) : super(key: key);

  @override
  State<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends State<ElectricityScreen> {
  String? selectedProvider;
  @override
  void initState() {
    super.initState();
    selectedProvider = widget.biller.isNotEmpty ? widget.biller : null;
  }

Future<ApiResponse> fetchData() async {
  final response = await http.get(
    Uri.parse("https://bbps-staging.digiledge.in/agent/cou-master/masters/customerParam?billerId=${widget.billid}"),
  );

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    print("json datas are ${jsonData.toString()}");
    return ApiResponse.fromJson(jsonData);
  } else {
    throw Exception("Failed to load data");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(''),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset(
              'assets/Bill_pay.png',
              height: 54,
              width: 54,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.payment, size: 32, color: Colors.blue);
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Category TextField (Read-only)
            TextField(
              controller: TextEditingController(text: widget.categoryName),
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Category",
                labelStyle: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),




            const SizedBox(height: 16),

            // Biller Selection
            InkWell(
              onTap: () async {
                // Navigate to Select Provider Page
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BillerPaginationScreen(cat: widget.categoryName,),
                  ),
                );

                // Handle the returned provider
                if (result != null) {
                  print("result is $result");
                  setState(() {
                    selectedProvider = result.toString();
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Biller",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedProvider ?? "Select a Provider",
                            style: TextStyle(
                              color: selectedProvider != null
                                  ? Colors.black87
                                  : Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 125),

            // Get Details Button
            Center(
              child: SizedBox(
                width: 250,
                height: 48,
                child: ElevatedButton(
                  onPressed: selectedProvider != null
                      ? () async{
                    final response = await fetchData();
                    print(" response is ${response}");
                    Navigator.push(context,
                    MaterialPageRoute(
                      builder: (context) =>
                      DynamicCustomFormPage(apiResponse: response, billerid: widget.billid, catname: widget.categoryName,billername:widget.biller,)
                    //  CustomParamPage(customParams: [],billid: widget.billid,),

                    ) );

                    // Handle get details

                    print('Biller id is : ${widget.billid}');
                    print('Getting details for: $selectedProvider');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Getting details for $selectedProvider',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // TODO: Navigate to bill details or fetch bill info
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A5C5A),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "GET DETAILS",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
