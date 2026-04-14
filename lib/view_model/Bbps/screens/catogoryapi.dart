// // File: lib/view/home/widget/BBBS/BBPSPaymentScreen.dart
// //
// // ✅ Worldline (WeiplCheckoutFlutter) payment integration for BBPS Bill Payment
// //    Modelled exactly after DthPaymentScreen pattern.
// //
// // Flow:
// //  1. Screen opens  →  _initPayment() called
// //  2. Profile API   →  get user email + mobile
// //  3. PostTransaction API → create DB record, get transaction_id
// //  4. GetPaymentCredentials → merchantCode, customerId, saltKey
// //  5. GenerateHash  →  hash string computed server-side
// //  6. wlCheckoutFlutter.open(options) → Worldline SDK opens
// //  7. responseCallback → parse msg, dual-verify hash, update DB
//
// import 'dart:collection';
// import 'dart:convert';
// import 'package:crypto/crypto.dart'; // add: crypto: ^3.0.3 in pubspec
// import 'package:flutter/material.dart';
// import 'package:new_project_2025/services/API_services/API_services.dart';
// import 'package:new_project_2025/view_model/Bbps/screens/paymentresponse_page.dart';
// import 'package:new_project_2025/view_model/Bbps/screens/selectproviderPage.dart';
// import 'package:weipl_checkout_flutter/weipl_checkout_flutter.dart';
//
// import 'bbpsapiservice.dart';
// import 'catogorydatascreen.dart';
//
// // ─────────────────────────────────────────────────────────────────────────────
// //  Widget
// // ─────────────────────────────────────────────────────────────────────────────
// class BBPSPaymentScreen extends StatefulWidget {
//   /// Biller details
//   final BillerModel biller;
//
//   /// Category (Electricity, Gas, Water …)
//   final String categoryName;
//
//   /// Customer params submitted on BillDetailsPage (e.g. {"Consumer Number":"12345"})
//   final Map<String, String> customerParams;
//
//   /// Amount to pay (in rupees, e.g. 249.00)
//   final double amount;
//
//   /// Fetched bill details (may be null for QuickPay / ValidatePay billers)
//   final BillFetchResponse? fetchedBill;
//   final CustomParamResp? custname;
//
//   /// Logged-in user's mobile number (passed from BillDetailsPage)
//   final String customerMobNo;
//
//   const BBPSPaymentScreen({
//     Key? key,
//     required this.biller,
//     required this.categoryName,
//     required this.customerParams,
//     required this.amount,
//     required this.fetchedBill,
//     required this.customerMobNo, this.custname,
//   }) : super(key: key);
//
//   @override
//   State<BBPSPaymentScreen> createState() => _BBPSPaymentScreenState();
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// //  State
// // ─────────────────────────────────────────────────────────────────────────────
// class _BBPSPaymentScreenState extends State<BBPSPaymentScreen>
//     with TickerProviderStateMixin {
//   // ── Worldline SDK ──────────────────────────────────────────────────────────
//   final WeiplCheckoutFlutter _wlCheckout = WeiplCheckoutFlutter();
//
//   // ── Animations ──────────────────────────────────────────────────────────────
//   late AnimationController _pulseController;
//   late AnimationController _rotateController;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _rotateAnimation;
//
//   // ── UI State ────────────────────────────────────────────────────────────────
//   String _statusMsg = 'Initializing…';
//   bool _isProcessing = true;
//   bool _showSuccess = false;
//   bool _showError = false;
//
//   // ── Transaction meta (populated during init) ────────────────────────────────
//   String _transactionId = '';
//   String _saltKey = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     _initPayment();
//
//     // Register SDK callbacks
//     _wlCheckout.on(
//       WeiplCheckoutFlutter.wlResponse,
//       _handleResponse,
//       _handleError,
//     );
//   }
//
//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _rotateController.dispose();
//     super.dispose();
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   //  Animation helpers
//   // ─────────────────────────────────────────────────────────────────────────
//   void _setupAnimations() {
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     )..repeat(reverse: true);
//
//     _rotateController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2000),
//     )..repeat();
//
//     _pulseAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.2,
//     ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
//
//     _rotateAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));
//   }
//
//   void _setStatus(String msg) => setState(() => _statusMsg = msg);
//
//   Future<void> _initPayment() async {
//     try {
//       _setStatus('Verifying user details…');
//
//       final ApiHelper api = ApiHelper();
//       final String profileRaw = await api.postApiResponse('getUserDetails.php', {});
//       final Map profileJson = jsonDecode(profileRaw);
//
//       if (profileJson['status'] != 1 && profileJson['status'] != '1') {
//         throw Exception('User verification failed. Please log in again.');
//       }
//
//       final data = profileJson['data'];
//       final String userId    = data['id'].toString();
//       final String userMobile = widget.customerMobNo.isNotEmpty
//           ? widget.customerMobNo
//           : data['mobile'].toString();
//       final String userEmail  = data['emailId']?.toString() ?? data['email']?.toString() ?? '';
//
//       // ── Step 2: Create DB transaction record ──────────────────────────────
//       _setStatus('Creating transaction record…');
//
//       final String customerParamsJson = jsonEncode(widget.customerParams);
//       final Map<String, String> txnParams = {
//         'timestamp'      : DateTime.now().millisecondsSinceEpoch.toString(),
//         'user_id'        : userId,
//         'mobile_number'  : userMobile,
//         'billerId'       : widget.biller.billerId,
//         'billerName'     : widget.biller.billerName,
//         'categoryName'   : widget.categoryName,
//         'customer_params': customerParamsJson,
//         'amount'         : widget.amount.toStringAsFixed(2),
//         'billID'         : widget.fetchedBill?.billId ?? '',
//         'billNumber'     : widget.fetchedBill?.billNumber ?? '',
//         'status'         : '2',          // pending
//         'payment_status' : '4',          // initiated
//         'recharge_type'  : '3',          // BBPS
//       };
//
//       final String txnRaw = await api.postApiResponse(
//         'postBillPaymentData.php',
//         txnParams,
//       );
//       final Map txnJson = jsonDecode(txnRaw);
//       _transactionId = txnJson['id'].toString();
//
//       _setStatus('Setting up secure payment…');
//       await _launchWorldlineGateway(
//         userId   : userId,
//         email    : userEmail,
//         mobile   : userMobile,
//         amount   : widget.amount.toStringAsFixed(2),
//         txnId    : _transactionId,
//       );
//     } catch (e) {
//       _pulseController.stop();
//       _rotateController.stop();
//       setState(() {
//         _isProcessing = false;
//         _showError    = true;
//         _statusMsg    = 'Initialization Error';
//       });
//       _notify('Error: ${e.toString().replaceFirst('Exception: ', '')}', isError: true);
//     }
//   }
//
//
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
//     _saltKey                  = credJson['saltkey'];
//
//     final String hashInput =
//         '$merchantCode|$txnId|$amount||$customerId|$mobile|$email||||||||||$_saltKey';
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
//         'deviceId'          : 'ANDROIDSH2',   // use iOSSH2 for iOS
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
//   // ─────────────────────────────────────────────────────────────────────────
//   //  SDK Callbacks
//   // ─────────────────────────────────────────────────────────────────────────
//   void _handleResponse(dynamic response) {
//     _handleWorldlineResponse(response);
//   }
//
//   void _handleError(dynamic error) {
//     _pulseController.stop();
//     _rotateController.stop();
//     setState(() {
//       _isProcessing = false;
//       _showError    = true;
//       _statusMsg    = 'Payment Error';
//     });
//     _notify('Payment error: ${error.toString()}', isError: true);
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   //  Parse Worldline response + dual-verify hash + update DB
//   // ─────────────────────────────────────────────────────────────────────────
//   Future<void> _handleWorldlineResponse(dynamic raw) async {
//     _pulseController.stop();
//     _rotateController.stop();
//     setState(() {
//       _isProcessing = false;
//       _statusMsg    = 'Verifying payment…';
//     });
//
//     try {
//       final String msg           = raw['msg'] as String;
//       final String merchantCode  = raw['merchant_code'] as String? ?? '';
//
//       // msg format (pipe-separated, 16 fields):
//       // txn_status|txn_msg|txn_err_msg|clnt_txn_ref|tpsl_bank_cd|tpsl_txn_id|
//       // txn_amt|clnt_rqst_meta|tpsl_txn_time|bal_amt|card_id|alias_name|
//       // BankTransactionID|mandate_reg_no|token|hash
//       final List<String> parts = msg.split('|');
//       if (parts.length < 16) throw Exception('Invalid response format');
//
//       final String txnStatus        = parts[0];   // "0300" = success
//       final String txnMsg           = parts[1];   // "SUCCESS" / "FAILURE"
//       final String txnErrMsg        = parts[2];
//       final String clntTxnRef       = parts[3];   // our txnId
//       final String tpslBankCd       = parts[4];
//       final String tpslTxnId        = parts[5];
//       final String txnAmt           = parts[6];
//       final String clntRqstMeta     = parts[7];
//       final String tpslTxnTime      = parts[8];
//       final String balAmt           = parts[9];
//       final String cardId           = parts[10];
//       final String aliasName        = parts[11];
//       final String bankTransactionId= parts[12];
//       final String mandateRegNo     = parts[13];
//       final String tokenResp        = parts[14];
//       final String receivedHash     = parts[15];
//
//       // ── Dual-verification: recompute hash ─────────────────────────────
//       // Spec: same fields used in request + SALT, then SHA512
//       final String hashData =
//           '$txnStatus|$txnMsg|$txnErrMsg|$clntTxnRef|$tpslBankCd|$tpslTxnId|'
//           '$txnAmt|$clntRqstMeta|$tpslTxnTime|$balAmt|$cardId|$aliasName|'
//           '$bankTransactionId|$mandateRegNo|$tokenResp|$_saltKey';
//
//       final String computedHash = sha512
//           .convert(utf8.encode(hashData))
//           .toString();
//
//       final bool hashValid = computedHash == receivedHash;
//       debugPrint('🔐 Hash valid: $hashValid');
//       // NOTE: For production, perform this verification server-side.
//
//       // ── Determine payment status ───────────────────────────────────────
//       bool paymentSuccess = false;
//       String dbStatus     = '0';   // 0=failed, 1=success, 2=pending
//
//       if (txnStatus == '0300' && txnMsg.toUpperCase() == 'SUCCESS') {
//         paymentSuccess = true;
//         dbStatus       = '1';
//       }
//
//       setState(() {
//         _showSuccess = paymentSuccess;
//         _showError   = !paymentSuccess;
//         _statusMsg   = paymentSuccess ? 'Payment Successful!' : 'Payment Failed';
//       });
//
//       // ── Notify BBPS backend about payment + update DB ─────────────────
//       await _postPaymentResult(
//         txnStatus    : dbStatus,
//         tpslTxnId    : tpslTxnId,
//         txnAmt       : txnAmt,
//         tpslTxnTime  : tpslTxnTime,
//         bankTxnId    : bankTransactionId,
//         hashValid    : hashValid,
//       );
//
//       // ── Show result snackbar ──────────────────────────────────────────
//       _notify(
//         paymentSuccess
//             ? '✅ Bill payment of ₹${widget.amount.toStringAsFixed(2)} successful!'
//             : '❌ Payment failed: $txnErrMsg',
//         isError: !paymentSuccess,
//       );
//     } catch (e) {
//       setState(() {
//         _showError = true;
//         _statusMsg = 'Response Processing Error';
//       });
//       _notify('Error processing payment response: $e', isError: true);
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   //  Post payment result back to your API + BBPS backend
//   // ─────────────────────────────────────────────────────────────────────────
//   Future<void> _postPaymentResult({
//     required String txnStatus,
//     required String tpslTxnId,
//     required String txnAmt,
//     required String tpslTxnTime,
//     required String bankTxnId,
//     required bool   hashValid,
//   }) async {
//     try {
//       final ApiHelper api = ApiHelper();
//
//       // 1️⃣  Update your internal transaction record
//       final Map<String, String> updateParams = {
//         'timestamp'    : DateTime.now().millisecondsSinceEpoch.toString(),
//         'id'           : _transactionId,
//         'status'       : txnStatus,        // 1=success, 0=failed
//         'tpsl_txn_id'  : tpslTxnId,
//         'bank_txn_id'  : bankTxnId,
//         'txn_amt'      : txnAmt,
//         'txn_time'     : tpslTxnTime,
//         'hash_valid'   : hashValid ? '1' : '0',
//       };
//
//       // ✅ Replace with your actual status update endpoint
//       final String updateRaw = await api.postApiResponse(
//         'updateBillPaymentStatus.php',
//         updateParams,
//       );
//       debugPrint('📤 DB update: ${jsonDecode(updateRaw)}');
//
//       // 2️⃣  If payment succeeded, also call BBPS makePayment
//       if (txnStatus == '1') {
//         debugPrint('📤 Calling BBPS makePayment after successful Worldline txn…');
//         final PaymentResponse bbpsResponse = await BBPSApiService.makePayment(
//           billerId      : widget.biller.billerId,
//           customerParams: widget.customerParams,
//           amount        : widget.amount,
//           billNumber    : widget.fetchedBill?.billNumber,
//           billDate      : widget.fetchedBill?.billDate,
//           dueDate       : widget.fetchedBill?.dueDate,
//         );
//         debugPrint('✅ BBPS payment response: ${bbpsResponse.success} — ${bbpsResponse.message}');
//       }
//     } catch (e) {
//       // Non-blocking — log but do not rethrow
//       debugPrint('⚠️ postPaymentResult error (non-blocking): $e');
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   //  Retry
//   // ─────────────────────────────────────────────────────────────────────────
//   void _retry() {
//     setState(() {
//       _isProcessing = true;
//       _showError    = false;
//       _showSuccess  = false;
//       _statusMsg    = 'Retrying…';
//     });
//     _pulseController.repeat(reverse: true);
//     _rotateController.repeat();
//     _initPayment();
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   //  Snackbar helper
//   // ─────────────────────────────────────────────────────────────────────────
//   void _notify(String message, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               isError ? Icons.error_outline : Icons.check_circle,
//               color: Colors.white,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor:
//         isError ? const Color(0xFFFF5252) : const Color(0xFF4CAF50),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 4),
//       ),
//     );
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   //  BUILD
//   // ─────────────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Color(0xFF0A5C5A), Color(0xFF1A8C7A), Color(0xFF0D7A68)],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               _buildAppBar(),
//               Expanded(
//                 child: Container(
//                   margin: const EdgeInsets.only(top: 20),
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFF8FAFC),
//                     borderRadius: BorderRadius.only(
//                       topLeft:  Radius.circular(30),
//                       topRight: Radius.circular(30),
//                     ),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: const BorderRadius.only(
//                       topLeft:  Radius.circular(30),
//                       topRight: Radius.circular(30),
//                     ),
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         children: [
//                           const SizedBox(height: 20),
//                           _buildPaymentSummaryCard(),
//                           const SizedBox(height: 30),
//                           if (_isProcessing) _buildProcessingAnimation(),
//                           if (_showSuccess)  _buildSuccessAnimation(),
//                           if (_showError)    _buildErrorAnimation(),
//                           const SizedBox(height: 24),
//                           _buildStatusText(),
//                           const SizedBox(height: 40),
//                           if (!_isProcessing) _buildActionButtons(),
//                           const SizedBox(height: 24),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── App Bar ───────────────────────────────────────────────────────────────
//   Widget _buildAppBar() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               width: 45,
//               height: 45,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(15),
//                 border: Border.all(color: Colors.white.withOpacity(0.3)),
//               ),
//               child: const Icon(
//                 Icons.arrow_back_ios_new,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Bill Payment',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     'Secure BBPS Transaction',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.9),
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             width: 45,
//             height: 45,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: const Icon(Icons.security, color: Colors.white, size: 24),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Payment summary card ──────────────────────────────────────────────────
//   Widget _buildPaymentSummaryCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Biller header
//           Row(
//             children: [
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF0A5C5A), Color(0xFF1A8C7A)],
//                   ),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Center(
//                   child: Text(
//                     widget.biller.billerName.isNotEmpty
//                         ? widget.biller.billerName[0].toUpperCase()
//                         : 'B',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.biller.billerName,
//                       style: const TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF1F2937),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       widget.categoryName,
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 24),
//           Container(height: 1, color: Colors.grey[200]),
//           const SizedBox(height: 20),
//
//           // Customer params
//           ...widget.customerParams.entries.map(
//                 (e) => Padding(
//               padding: const EdgeInsets.only(bottom: 12),
//               child: _buildDetailRow(e.key, e.value),
//             ),
//           ),
//
//           // Bill details if available
//           if (widget.fetchedBill != null) ...[
//             if (widget.fetchedBill!.customerParams!= null)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: _buildDetailRow(
//                   'Consumer Name',
//                   widget.custname!.customParamName!,
//                 ),
//               ),
//             if (widget.fetchedBill!.billNumber != null)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: _buildDetailRow(
//                   'Bill Number',
//                   widget.fetchedBill!.billNumber!,
//                 ),
//               ),
//             if (widget.fetchedBill!.dueDate != null)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child:
//                 _buildDetailRow('Due Date', widget.fetchedBill!.dueDate!),
//               ),
//           ],
//
//           const SizedBox(height: 8),
//
//           // Amount highlight
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF0A5C5A), Color(0xFF1A8C7A)],
//               ),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Total Payable',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Text(
//                   '₹ ${widget.amount.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 13,
//             color: Colors.grey[600],
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         Flexible(
//           child: Text(
//             value,
//             textAlign: TextAlign.right,
//             style: const TextStyle(
//               fontSize: 13,
//               color: Color(0xFF1F2937),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ── Animations ────────────────────────────────────────────────────────────
//   Widget _buildProcessingAnimation() {
//     return AnimatedBuilder(
//       animation: _pulseAnimation,
//       builder: (_, __) => Transform.scale(
//         scale: _pulseAnimation.value,
//         child: AnimatedBuilder(
//           animation: _rotateAnimation,
//           builder: (_, __) => Transform.rotate(
//             angle: _rotateAnimation.value * 6.28318,
//             child: Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF0A5C5A), Color(0xFF1A8C7A), Color(0xFF0D7A68)],
//                 ),
//                 borderRadius: BorderRadius.circular(60),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFF0A5C5A).withOpacity(0.35),
//                     blurRadius: 20,
//                     spreadRadius: 5,
//                   ),
//                 ],
//               ),
//               child: const Center(
//                 child: Icon(Icons.hourglass_empty, color: Colors.white, size: 50),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSuccessAnimation() {
//     return TweenAnimationBuilder<double>(
//       duration: const Duration(milliseconds: 1000),
//       tween: Tween(begin: 0.0, end: 1.0),
//       curve: Curves.elasticOut,
//       builder: (_, value, __) => Transform.scale(
//         scale: value,
//         child: Container(
//           width: 120,
//           height: 120,
//           decoration: BoxDecoration(
//             color: const Color(0xFF4CAF50),
//             borderRadius: BorderRadius.circular(60),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFF4CAF50).withOpacity(0.3),
//                 blurRadius: 20,
//                 spreadRadius: 5,
//               ),
//             ],
//           ),
//           child: const Center(
//             child: Icon(Icons.check_circle, color: Colors.white, size: 60),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildErrorAnimation() {
//     return TweenAnimationBuilder<double>(
//       duration: const Duration(milliseconds: 800),
//       tween: Tween(begin: 0.0, end: 1.0),
//       curve: Curves.bounceOut,
//       builder: (_, value, __) => Transform.scale(
//         scale: value,
//         child: Container(
//           width: 120,
//           height: 120,
//           decoration: BoxDecoration(
//             color: const Color(0xFFFF5252),
//             borderRadius: BorderRadius.circular(60),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFFFF5252).withOpacity(0.3),
//                 blurRadius: 20,
//                 spreadRadius: 5,
//               ),
//             ],
//           ),
//           child: const Center(
//             child: Icon(Icons.error_outline, color: Colors.white, size: 60),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatusText() {
//     final Color color = _isProcessing
//         ? const Color(0xFF0A5C5A)
//         : _showSuccess
//         ? const Color(0xFF4CAF50)
//         : const Color(0xFFFF5252);
//
//     return Column(
//       children: [
//         Text(
//           _statusMsg,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 8),
//         Text(
//           _isProcessing
//               ? 'Please wait while we process your bill payment securely…'
//               : _showSuccess
//               ? 'Your bill has been paid successfully via BBPS!'
//               : 'There was an issue processing your payment.',
//           style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildActionButtons() {
//     if (_showSuccess) {
//       return SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF4CAF50),
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             elevation: 0,
//           ),
//           child: const Text(
//             'Back to Home',
//             style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
//           ),
//         ),
//       );
//     }
//
//     if (_showError) {
//       return Column(
//         children: [
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _retry,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF0A5C5A),
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 elevation: 0,
//               ),
//               child: const Text(
//                 'Retry Payment',
//                 style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             width: double.infinity,
//             child: TextButton(
//               onPressed: () => Navigator.pop(context),
//               style: TextButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       );
//     }
//
//     return const SizedBox.shrink();
//   }
// }