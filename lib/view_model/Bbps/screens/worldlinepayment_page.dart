import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:new_project_2025/services/API_services/API_services.dart';
import 'package:new_project_2025/view_model/Bbps/screens/paymentresponse_page.dart';
import 'package:new_project_2025/view_model/Bbps/screens/selectproviderPage.dart';
import 'package:weipl_checkout_flutter/weipl_checkout_flutter.dart';

import 'bbpsapiservice.dart';
import 'catogorydatascreen.dart';

class BBPSPaymentScreen extends StatefulWidget {
  final BillerModel biller;
  final String categoryName;
  final Map<String, String> customerParams;
  final double amount;
  final BillFetchResponse? fetchedBill;
  final String customerMobNo;

  const BBPSPaymentScreen({
    Key? key,
    required this.biller,
    required this.categoryName,
    required this.customerParams,
    required this.amount,
    required this.fetchedBill,
    required this.customerMobNo,
  }) : super(key: key);

  @override
  State<BBPSPaymentScreen> createState() => _BBPSPaymentScreenState();
}

class _BBPSPaymentScreenState extends State<BBPSPaymentScreen>
    with TickerProviderStateMixin {
  // ── Worldline SDK ──────────────────────────────────────────────────────────
  final WeiplCheckoutFlutter _wlCheckout = WeiplCheckoutFlutter();

  // ── Animations ─────────────────────────────────────────────────────────────
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  String _statusMsg = 'Initializing…';
  bool _isProcessing = true;
  bool _showSuccess = false;
  bool _showError = false;

  String _transactionId = '';
  String _saltKey = '';

  // ✅ FIX: amount is already in rupees — just format it.
  // NEVER multiply or divide here again.
  late final String _formattedAmount;

  @override
  void initState() {
    super.initState();

    // widget.amount is already in RUPEES (converted in catogorydatascreen.dart)
    _formattedAmount = widget.amount.toStringAsFixed(2);
    print('💳 BBPSPaymentScreen — amount to charge: ₹$_formattedAmount');

    _setupAnimations();

    // ✅ FIX: attach listener BEFORE calling _initPayment so no response is missed
    _wlCheckout.on(
      WeiplCheckoutFlutter.wlResponse,
      _handleResponse,
      _handleError,
    );

    _initPayment();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Animations
  // ─────────────────────────────────────────────────────────────────────────
  void _setupAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )
      ..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )
      ..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );
  }

  void _setStatus(String msg) {
    if (mounted) setState(() => _statusMsg = msg);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Step 1 — Verify user + create DB record
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _initPayment() async {
    try {
      _setStatus('Verifying user details…');

      final ApiHelper api = ApiHelper();
      final String profileRaw = await api.postApiResponse(
          'getUserDetails.php', {});
      final Map profileJson = jsonDecode(profileRaw);

      if (profileJson['status'] != 1 && profileJson['status'] != '1') {
        throw Exception('User verification failed. Please log in again.');
      }

      final data = profileJson['data'];
      final String userId = data['id'].toString();
      final String userMobile = widget.customerMobNo.isNotEmpty
          ? widget.customerMobNo
          : data['mobile'].toString();

      // ✅ FIX: support both 'emailId' and 'email' keys safely
      final String userEmail =
          data['emailId']?.toString() ?? data['email']?.toString() ?? '';

      _setStatus('Creating transaction record…');

      final String customerParamsJson = jsonEncode(widget.customerParams);
      final Map<String, String> txnParams = {
        'timestamp': DateTime
            .now()
            .millisecondsSinceEpoch
            .toString(),
        'user_id': userId,
        'mobile_number': userMobile,
        'billerId': widget.biller.billerId,
        'billerName': widget.biller.billerName,
        'categoryName': widget.categoryName,
        'customer_params': customerParamsJson,
        'amount': _formattedAmount,
        'billID': widget.fetchedBill?.billId ?? '',
        'billNumber': widget.fetchedBill?.billNumber ?? '',
        'status': '2',
        'payment_status': '4',
        'recharge_type': '3',
      };

      final String txnRaw =
      await api.postApiResponse('postBillPaymentData.php', txnParams);
      final Map txnJson = jsonDecode(txnRaw);
      _transactionId = txnJson['id'].toString();
      print('📋 Transaction ID: $_transactionId');

      _setStatus('Setting up secure payment…');

      await _launchWorldlineGateway(email: userEmail, mobile: userMobile);
    } catch (e) {
      _stopAnimations();
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _showError = true;
          _statusMsg = 'Initialization Error';
        });
      }
      _notify(
        'Error: ${e.toString().replaceFirst('Exception: ', '')}',
        isError: true,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Step 2 — Launch Worldline gateway
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _launchWorldlineGateway({
    required String email,
    required String mobile,
  }) async {
    final ApiHelper api = ApiHelper();

    _setStatus('Fetching payment credentials…');

    final String credRaw =
    await api.postApiResponse('getPaymentCredentials.php', {});
    final Map credJson = jsonDecode(credRaw);

    final String customerId = credJson['customerid'].toString();
    final String merchantCode = credJson['merchantcode'].toString();
    _saltKey = credJson['saltkey'].toString();

    // ✅ Hash string — pipe-separated exactly as Worldline spec requires:
    // merchantCode|txnId|amount||customerId|mobile|email||||||||||saltKey
    final String hashInput =
        '$merchantCode|$_transactionId|$_formattedAmount||$customerId|$mobile|$email||||||||||$_saltKey';

    print('🔑 Hash input: $hashInput');

    _setStatus('Generating secure token…');

    final String hashRaw =
    await api.postApiResponse('generateHash.php', {'data': hashInput});
    final Map hashJson = jsonDecode(hashRaw);
    final String token = hashJson['value'].toString();

    print('🔐 Token received: ${token.substring(0, 10)}...');

    _setStatus('Opening payment gateway…');

    // ✅ FIX: correct deviceId casing — 'AndroidSH2' not 'ANDROIDSH2'
    final bool isAndroid =
        Theme
            .of(context)
            .platform == TargetPlatform.android;
    final String deviceId = isAndroid ? 'AndroidSH2' : 'iOSSH2';

    final Map<String, dynamic> options = {
      'features': {
        'enableAbortResponse': true,
        'enableExpressPay': true,
        'enableInstrumentDeRegistration': true,
        'enableMerTxnDetails': true,
      },
      'consumerData': {
        'deviceId': deviceId,
        'token': token,
        'paymentMode': 'all',
        'merchantLogoUrl': 'https://mysaveapp.com/ic_launcher.png',
        'merchantId': merchantCode,
        'currency': 'INR',
        'consumerId': customerId,
        'consumerMobileNo': mobile,
        'consumerEmailId': email,
        'txnId': _transactionId,
        'items': [
          {
            'itemId': 'first',
            // ✅ CRITICAL: amount in items MUST match hash exactly (same string)
            'amount': _formattedAmount,
            'comAmt': '0',
          },
        ],
        'customStyle': {
          'PRIMARY_COLOR_CODE': '#0A5C5A',
          'SECONDARY_COLOR_CODE': '#FFFFFF',
          'BUTTON_COLOR_CODE_1': '#0A5C5A',
          'BUTTON_COLOR_CODE_2': '#FFFFFF',
        },
      },
    };

    _wlCheckout.open(options);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Worldline callbacks
  // ─────────────────────────────────────────────────────────────────────────
  void _handleResponse(dynamic response) {
    _handleWorldlineResponse(response);
  }

  void _handleError(dynamic error) {
    _stopAnimations();
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _showError = true;
        _statusMsg = 'Payment Error';
      });
    }
    _notify('Payment error: ${error.toString()}', isError: true);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Parse Worldline response + verify hash + update DB
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _handleWorldlineResponse(dynamic raw) async {
    _stopAnimations();
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _statusMsg = 'Verifying payment…';
      });
    }

    try {
      final String msg = raw['msg'] as String;

      print('📨 Worldline raw msg: $msg');

      final List<String> parts = msg.split('|');
      if (parts.length < 16) throw Exception('Invalid response format');

      final String txnStatus = parts[0]; // "0300" = success
      final String txnMsg = parts[1]; // "SUCCESS" / "FAILURE"
      final String txnErrMsg = parts[2];
      final String clntTxnRef = parts[3];
      final String tpslBankCd = parts[4];
      final String tpslTxnId = parts[5];
      final String txnAmt = parts[6];
      final String clntRqstMeta = parts[7];
      final String tpslTxnTime = parts[8];
      final String balAmt = parts[9];
      final String cardId = parts[10];
      final String aliasName = parts[11];
      final String bankTransactionId = parts[12];
      final String mandateRegNo = parts[13];
      final String tokenResp = parts[14];
      final String receivedHash = parts[15];

      // ── Verify response hash ──────────────────────────────────────────────
      final String hashData =
          '$txnStatus|$txnMsg|$txnErrMsg|$clntTxnRef|$tpslBankCd|$tpslTxnId|'
          '$txnAmt|$clntRqstMeta|$tpslTxnTime|$balAmt|$cardId|$aliasName|'
          '$bankTransactionId|$mandateRegNo|$tokenResp|$_saltKey';

      final String computedHash =
      sha512.convert(utf8.encode(hashData)).toString();

      final bool hashValid = computedHash == receivedHash;
      debugPrint('🔐 Hash valid: $hashValid');

      // ── Determine success ─────────────────────────────────────────────────
      // ✅ FIX: check BOTH txnStatus AND txnMsg for a true success
      final bool paymentSuccess =
          txnStatus == '0300' && txnMsg.toUpperCase() == 'SUCCESS';
      final String dbStatus = paymentSuccess ? '1' : '0';

      if (mounted) {
        setState(() {
          _showSuccess = paymentSuccess;
          _showError = !paymentSuccess;
          _statusMsg =
          paymentSuccess ? 'Payment Successful!' : 'Payment Failed';
        });
      }

      await _postPaymentResult(
        txnStatus: dbStatus,
        tpslTxnId: tpslTxnId,
        txnAmt: txnAmt,
        tpslTxnTime: tpslTxnTime,
        bankTxnId: bankTransactionId,
        hashValid: hashValid,
      );

      _notify(
        paymentSuccess
            ? '✅ Bill payment of ₹$_formattedAmount successful!'
            : '❌ Payment failed: $txnErrMsg',
        isError: !paymentSuccess,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _showError = true;
          _statusMsg = 'Response Processing Error';
        });
      }
      _notify('Error processing payment response: $e', isError: true);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Post result to your API + BBPS backend
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _postPaymentResult({
    required String txnStatus,
    required String tpslTxnId,
    required String txnAmt,
    required String tpslTxnTime,
    required String bankTxnId,
    required bool hashValid,
  }) async {
    try {
      final ApiHelper api = ApiHelper();

      final Map<String, String> updateParams = {
        'timestamp': DateTime
            .now()
            .millisecondsSinceEpoch
            .toString(),
        'id': _transactionId,
        'status': txnStatus,
        'tpsl_txn_id': tpslTxnId,
        'bank_txn_id': bankTxnId,
        'txn_amt': txnAmt,
        'txn_time': tpslTxnTime,
        'hash_valid': hashValid ? '1' : '0',
      };

      final String updateRaw = await api.postApiResponse(
          'updateBillPaymentStatus.php', updateParams);
      debugPrint('📤 DB update: ${jsonDecode(updateRaw)}');

      if (txnStatus == '1') {
        debugPrint('📤 Calling BBPS makePayment…');
        final PaymentResponse bbpsResponse = await BBPSApiService.makePayment(
          billerId: widget.biller.billerId,
          customerParams: widget.customerParams,
          amount: widget.amount,
          // rupees
          billNumber: widget.fetchedBill?.billNumber,
          billDate: widget.fetchedBill?.billDate,
          dueDate: widget.fetchedBill?.dueDate,
        );
        debugPrint(
            '✅ BBPS response: ${bbpsResponse.success} — ${bbpsResponse
                .message}');
      }
    } catch (e) {
      debugPrint('⚠️ postPaymentResult error (non-blocking): $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────────────────────────────────
  void _stopAnimations() {
    if (_pulseController.isAnimating) _pulseController.stop();
    if (_rotateController.isAnimating) _rotateController.stop();
  }

  void _retry() {
    if (mounted) {
      setState(() {
        _isProcessing = true;
        _showError = false;
        _showSuccess = false;
        _statusMsg = 'Retrying…';
      });
    }
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
    _initPayment();
  }

  void _notify(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor:
        isError ? const Color(0xFFFF5252) : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A5C5A), Color(0xFF1A8C7A), Color(0xFF0D7A68)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildPaymentSummaryCard(),
                          const SizedBox(height: 30),
                          //     if (_isProcessing) _buildProcessingAnimation(),
                          //if (_showSuccess) _buildSuccessAnimation(),
                          // if (_showError) _buildErrorAnimation(),
                          const SizedBox(height: 24),
                          _buildStatusText(),
                          const SizedBox(height: 40),
                          if (!_isProcessing) _buildActionButtons(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bill Payment',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Secure BBPS Transaction',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child:
            const Icon(Icons.security, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Biller Info
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF0A5C5A),
                child: Text(
                  widget.biller.billerName[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.biller.billerName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(widget.categoryName,
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              )
            ],
          ),

          const SizedBox(height: 20),

          /// Details
          ...widget.customerParams.entries.map(
                (e) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildDetailRow(e.key, e.value),
                ),
          ),

          const SizedBox(height: 16),

          /// Payable Box (highlighted)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0A5C5A),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Payable",
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  "₹ $_formattedAmount",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500)),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildProcessingAnimation() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (_, __) =>
          Transform.scale(
            scale: _pulseAnimation.value,
            child: AnimatedBuilder(
              animation: _rotateAnimation,
              builder: (_, __) =>
                  Transform.rotate(
                    angle: _rotateAnimation.value * 6.28318,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Color(0xFF0A5C5A),
                          Color(0xFF1A8C7A),
                          Color(0xFF0D7A68),
                        ]),
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF0A5C5A).withOpacity(0.35),
                              blurRadius: 20,
                              spreadRadius: 5)
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.hourglass_empty,
                            color: Colors.white, size: 50),
                      ),
                    ),
                  ),
            ),
          ),
    );
  }

  Widget _buildSuccessAnimation() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (_, value, __) =>
          Transform.scale(
            scale: value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5)
                ],
              ),
              child: const Center(
                  child: Icon(
                      Icons.check_circle, color: Colors.white, size: 60)),
            ),
          ),
    );
  }

  Widget _buildErrorAnimation() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.bounceOut,
      builder: (_, value, __) =>
          Transform.scale(
            scale: value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252),
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFFFF5252).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5)
                ],
              ),
              child: const Center(
                  child: Icon(
                      Icons.error_outline, color: Colors.white, size: 60)),
            ),
          ),
    );
  }

  Widget _buildStatusText() {
    IconData icon;
    Color color;

    if (_isProcessing) {
      icon = Icons.sync;
      color = Colors.blue;
    } else if (_showSuccess) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else {
      icon = Icons.cancel;
      color = Colors.red;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 40),
        ),
        const SizedBox(height: 16),

        Text(
          _statusMsg,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),

        const SizedBox(height: 8),

        Text(
          _isProcessing
              ? 'Processing your payment securely...'
              : _showSuccess
              ? 'Payment completed successfully'
              : 'Payment failed. Please try again.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Widget _buildStatusText() {
  //   final Color color = _isProcessing
  //       ? const Color(0xFF0A5C5A)
  //       : _showSuccess
  //       ? const Color(0xFF4CAF50)
  //       : const Color(0xFFFF5252);
  //
  //   return Column(
  //     children: [
  //       Text(
  //         _statusMsg,
  //         style: TextStyle(
  //             fontSize: 18, fontWeight: FontWeight.bold, color: color),
  //         textAlign: TextAlign.center,
  //       ),
  //       const SizedBox(height: 8),
  //       Text(
  //         _isProcessing
  //             ? 'Please wait while we process your bill payment securely…'
  //             : _showSuccess
  //             ? 'Your bill has been paid successfully via BBPS!'
  //             : 'There was an issue processing your payment.',
  //         style: TextStyle(fontSize: 14, color: Colors.grey[600]),
  //         textAlign: TextAlign.center,
  //       ),
  //     ],
  //   );
  // }
  Widget _buildActionButtons() {
    if (_showSuccess) {
      return ElevatedButton(
        onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text("Back to Home", style: TextStyle(fontSize: 16)),
      );
    }

    if (_showError) {
      return Column(
        children: [
          ElevatedButton(
            onPressed: _retry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A5C5A),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("Retry Payment",
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          )
        ],
      );
    }

    return const SizedBox();
  }
}