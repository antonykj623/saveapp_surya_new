//
// import 'dart:convert';
// import 'package:crypto/crypto.dart';
// import 'package:flutter/material.dart';
// import 'package:new_project_2025/view_model/Bbps/screens/selectproviderPage.dart';
// import 'package:weipl_checkout_flutter/weipl_checkout_flutter.dart';
//
// import 'package:new_project_2025/services/API_services/API_services.dart';
//
// import 'bbpsapiservice.dart';
// import 'catogorydatascreen.dart';
//
// class BBPSPaymentScreen extends StatefulWidget {
//   final double amount;
//   final BillerModel biller;
//   final String categoryName;
//   final Map<String,String> customerParams;
//
//   final BillFetchResponse? fetchedBill;
//   final String customerMobNo;
//
//   const BBPSPaymentScreen({
//     super.key,
//     required this.biller,
//     required this.categoryName,
//     required this.customerParams,
//     required this.amount,
//     required this.fetchedBill,
//     required this.customerMobNo,
//   });
//
//   @override
//   State<BBPSPaymentScreen> createState() => _BBPSPaymentScreenState();
// }
//
// class _BBPSPaymentScreenState extends State<BBPSPaymentScreen> {
//
//   final WeiplCheckoutFlutter _wlCheckout = WeiplCheckoutFlutter();
//
//   bool processing = true;
//   bool success = false;
//   bool error = false;
//
//   String status = "Initializing Payment...";
//   String transactionId = "";
//   String saltKey = "";
//   String _statusMsg = 'Initializing…';
//   @override
//   void initState() {
//     super.initState();
//
//       _wlCheckout.on(
//    WeiplCheckoutFlutter.wlResponse,
//       _handleResponse,
//        _handleError,
//   );
//
//     initPayment();
//   }
//
//   /// ---------------------------------------
//   /// INITIAL PAYMENT FLOW
//   /// ---------------------------------------
//   void _setStatus(String msg) => setState(() => _statusMsg = msg);
//
//   Future<void> initPayment() async {
//
//     try {
//
//       setState(() {
//         status = "Verifying user...";
//       });
//
//       ApiHelper api = ApiHelper();
//
//       final profileRaw = await api.postApiResponse(
//         "getUserDetails.php",
//         {},
//       );
//
//       final profile = jsonDecode(profileRaw);
//
//       if (profile["status"] != 1 && profile["status"] != "1") {
//         throw Exception("User verification failed");
//       }
//
//       final data = profile["data"];
//
//       String userId = data["id"].toString();
//       String email = data["email"] ?? "";
//       String mobile = widget.customerMobNo;
//
//       /// -----------------------------
//       /// Create transaction in DB
//       /// -----------------------------
//       setState(() {
//         status = "Creating transaction...";
//       });
//
//       final txnRaw = await api.postApiResponse(
//         "postBillPaymentData.php",
//         {
//           "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
//           "user_id": userId,
//           "mobile_number": mobile,
//           "billerId": widget.biller.billerId,
//           "billerName": widget.biller.billerName,
//           "categoryName": widget.categoryName,
//           "customer_params": jsonEncode(widget.customerParams),
//           "amount": widget.amount.toStringAsFixed(2),
//           "billID": widget.fetchedBill?.billId ?? "",
//           "billNumber": widget.fetchedBill?.billNumber ?? "",
//           "status": "2",
//           "payment_status": "4",
//           "recharge_type": "3",
//         },
//       );
//
//       final txnJson = jsonDecode(txnRaw);
// print("final jsondata $txnJson");
//       transactionId = txnJson["id"].toString();
//       print("final transactionid $transactionId");
//       await _launchWorldlineGateway(
//         userId: userId,
//         email: email,
//         mobile: mobile, amount: widget.amount.toString(), txnId: transactionId,
//       );
//
//     } catch(e) {
//
//       setState(() {
//         processing = false;
//         error = true;
//         status = e.toString();
//       });
//
//     }
//   }
//
//   /// ---------------------------------------
//   /// WORLDLINE GATEWAY
//   /// ---------------------------------------
//   ///
//   Future<void> _launchWorldlineGateway({
//     required String userId,
//     required String email,
//     required String mobile,
//     required String amount,
//     required String txnId,
//   }) async {
//     final ApiHelper api = ApiHelper();
//
//     // ── 3a: Get merchant credentials ─────────────────────────────────────
//     _setStatus('Fetching payment credentials…');
//
//
//     final String credRaw = await api.postApiResponse(
//       'getPaymentCredentials.php',
//       {},
//     );
//     final Map credJson = jsonDecode(credRaw);
//
//     final String customerId   = credJson['customerid'];
//     final String merchantCode = credJson['merchantcode'];
//     saltKey  = credJson['saltkey'];
//
//     final String hashInput =
//         '$merchantCode|$txnId|$amount||$customerId|$mobile|$email||||||||||$saltKey';
//
//     _setStatus('Generating secure token…');
//
//     final String hashRaw = await api.postApiResponse(
//       'generateHash.php',
//       {'data': hashInput},
//     );
//     final Map hashJson = jsonDecode(hashRaw);
//     final String token = hashJson['value'];
//
//     _setStatus('Opening payment gateway…');
//
//     final Map<String, dynamic> options = {
//       'features': {
//         'enableAbortResponse'           : true,
//         'enableExpressPay'              : true,
//         'enableInstrumentDeRegistration': true,
//         'enableMerTxnDetails'           : true,
//       },
//       'consumerData': {
//         'deviceId'          :'ANDROIDSH2',   // use iOSSH2 for iOS
//         'token'             : token,
//         'paymentMode'       : 'all',
//         'merchantLogoUrl'   : 'https://mysaveapp.com/ic_launcher.png',
//         'merchantId'        : merchantCode,
//         'currency'          : 'INR',
//         'consumerId'        : customerId,
//         'consumerMobileNo'  : mobile,
//         'consumerEmailId'   : email,
//         'txnId'             : txnId,
//         'items'             : [
//           {'itemId': 'bbps_payment', 'amount': amount, 'comAmt': '0'},
//         ],
//         'customStyle': {
//           'PRIMARY_COLOR_CODE'   : '#0A5C5A',
//           'SECONDARY_COLOR_CODE' : '#FFFFFF',
//           'BUTTON_COLOR_CODE_1'  : '#0A5C5A',
//           'BUTTON_COLOR_CODE_2'  : '#FFFFFF',
//         },
//       },
//     };
//
//     _wlCheckout.open(options);
//   }
//
//   /// ---------------------------------------
//   /// HANDLE PAYMENT RESPONSE
//   /// ---------------------------------------
//   Future<void> _handleResponse(dynamic res) async {
//
//     try {
//
//       final msg = res["msg"];
//
//       List parts = msg.split("|");
//
//       if(parts.length < 16){
//         throw Exception("Invalid response");
//       }
//
//       String txnStatus = parts[0];
//       String txnMsg = parts[1];
//       String txnErr = parts[2];
//       String bankTxnId = parts[12];
//       String tpslTxnId = parts[5];
//       String txnTime = parts[8];
//       String amount = parts[6];
//       String receivedHash = parts[15];
//
//       /// Hash verify
//       final hashData =
//           "${parts.sublist(0,15).join("|")}|$saltKey";
// print("hash datas are $hashData");
//       final computedHash =
//       sha512.convert(utf8.encode(hashData)).toString();
//
//       bool hashValid = computedHash == receivedHash;
//
//       bool paymentSuccess = txnStatus == "0300";
//
//       setState(() {
//         processing = false;
//         success = paymentSuccess;
//         error = !paymentSuccess;
//         status = paymentSuccess
//             ? "Payment Successful"
//             : "Payment Failed";
//       });
//
//       await updateDB(
//         paymentSuccess,
//         bankTxnId,
//         tpslTxnId,
//         txnTime,
//         amount,
//         hashValid,
//       );
//
//     } catch(e){
//
//       setState(() {
//         processing = false;
//         error = true;
//         status = "Response error";
//       });
//
//     }
//   }
//
//   void _handleError(dynamic err){
//
//     setState(() {
//       processing = false;
//       error = true;
//       status = "Payment error";
//     });
//
//   }
//
//   /// ---------------------------------------
//   /// UPDATE DB + BBPS PAYMENT
//   /// ---------------------------------------
//   Future<void> updateDB(
//       bool success,
//       String bankTxnId,
//       String tpslTxnId,
//       String txnTime,
//       String amount,
//       bool hashValid,
//       ) async {
//
//     try{
//
//       ApiHelper api = ApiHelper();
//
//       await api.postApiResponse(
//         "updateBillPaymentStatus.php",
//         {
//           "id": transactionId,
//           "status": success ? "1" : "0",
//           "bank_txn_id": bankTxnId,
//           "tpsl_txn_id": tpslTxnId,
//           "txn_time": txnTime,
//           "txn_amt": amount,
//           "hash_valid": hashValid ? "1":"0",
//         },
//       );
//
//       /// call BBPS if success
//       if(success){
//
//
//         await BBPSApiService.makePayment (
//           billerId: widget.biller.billerId,
//           customerParams: widget.customerParams,
//           amount: widget.amount,
//           billNumber: widget.fetchedBill?.billNumber,
//           billDate: widget.fetchedBill?.billDate,
//           dueDate: widget.fetchedBill?.dueDate,
//         );
//
//       }
//
//     }catch(e){
//       debugPrint("DB update error $e");
//     }
//   }
//
//   /// ---------------------------------------
//   /// UI
//   /// ---------------------------------------
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//
//       appBar: AppBar(
//         title: const Text("Processing Payment"),
//         backgroundColor: const Color(0xFF0A5C5A),
//       ),
//
//       body: Center(
//
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//
//             if(processing)
//               const CircularProgressIndicator(),
//
//             const SizedBox(height:20),
//
//             Text(
//               status,
//               style: const TextStyle(
//                 fontSize:18,
//                 fontWeight:FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//
//             const SizedBox(height:30),
//
//             if(success)
//               ElevatedButton(
//                 onPressed: (){
//                   Navigator.popUntil(context, (r)=>r.isFirst);
//                 },
//                 child: const Text("Back Home"),
//               ),
//
//             if(error)
//               ElevatedButton(
//                 onPressed: (){
//                   setState(() {
//                     processing=true;
//                     error=false;
//                   });
//                   initPayment();
//                 },
//                 child: const Text("Retry Payment"),
//               )
//
//           ],
//         ),
//
//       ),
//     );
//   }
// }
//
//
