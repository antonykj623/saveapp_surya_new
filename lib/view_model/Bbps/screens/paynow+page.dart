import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BillDetailsCard extends StatefulWidget {
  const BillDetailsCard({super.key});

  @override
  State<BillDetailsCard> createState() => _BillDetailsCardState();
}

class _BillDetailsCardState extends State<BillDetailsCard> {

  Map<String, dynamic>? billData;
  bool showBillCard = false;

  @override
  void initState() {
    super.initState();
    getBillDetails();
  }

  /// API CALL
  Future<void> getBillDetails() async {

    /// Example API
    var response = await http.get(
        Uri.parse("https://yourapi.com/getBill")
    );

    if (response.statusCode == 200) {

      var data = jsonDecode(response.body);

      setState(() {
        billData = {
          "Consumer Name": data["consumerName"],
          "Bill Number": data["billNumber"],
          "Bill Date": data["billDate"],
          "Due Date": data["dueDate"],
          "Billing Period": data["billingPeriod"],
          "Bill Amount": data["billAmount"],
          "Biller Unique Number": data["billerUniqueNumber"]
        };

        showBillCard = true;
      });

    }
  }

  Widget buildRow(String title, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
              color: isAmount ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[200],

      body: Center(
        child: showBillCard
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// BILL CARD
            Container(
              width: 320,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffe8f5e9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Bill Details",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10),

                  buildRow("Consumer Name", billData!["Consumer Name"]),
                  buildRow("Bill Number", billData!["Bill Number"]),
                  buildRow("Bill Date", billData!["Bill Date"]),
                  buildRow("Due Date", billData!["Due Date"]),
                  buildRow("Billing Period", billData!["Billing Period"]),

                  const Divider(),

                  buildRow(
                    "Bill Amount",
                    "₹ ${billData!["Bill Amount"]}",
                    isAmount: true,
                  ),

                  const Divider(),

                  buildRow(
                    "Biller Unique Number",
                    billData!["Biller Unique Number"],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// PAY NOW BUTTON
            SizedBox(
              width: 180,
              height: 45,
              child: ElevatedButton(
                onPressed: () {

                  print("Payment Started");

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "PAY NOW",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            )
          ],
        )
            : const CircularProgressIndicator(),
      ),
    );
  }
}