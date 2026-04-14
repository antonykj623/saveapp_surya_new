class PaymentResponse {
  final bool success;
  final String? message;
  final String? transactionId;
  final String? referenceNumber;
  final String? acknowledgmentNumber;
  final double? amount;
  final String? status;
  final DateTime? timestamp;
  final Map<String, dynamic>? additionalInfo;

  PaymentResponse({
    required this.success,
    this.message,
    this.transactionId,
    this.referenceNumber,
    this.acknowledgmentNumber,
    this.amount,
    this.status,
    this.timestamp,
    this.additionalInfo,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    final bool success =
        json['success'] as bool? ??
            (json['status'] == 'success') || (json['statusCode'] == 200) || false;

    double? amount;
    final amountValue = json['amount'] ?? json['paidAmount'];
    if (amountValue != null) {
      if (amountValue is num) {
        amount = amountValue.toDouble();
      } else if (amountValue is String) {
        amount = double.tryParse(amountValue.replaceAll(',', ''));
      }
    }

    DateTime? timestamp;
    final tsValue = json['timestamp'] ?? json['transactionDate'];
    if (tsValue != null) {
      try {
        timestamp = DateTime.parse(tsValue.toString());
      } catch (_) {}
    }

    return PaymentResponse(
      success: success,
      message: json['message'] as String? ?? json['responseMessage'] as String?,
      transactionId:
      json['transactionId'] as String? ??
          json['txnId'] as String? ??
          json['transactionReferenceId'] as String?,
      referenceNumber:
      json['referenceNumber'] as String? ?? json['refNo'] as String?,
      acknowledgmentNumber:
      json['acknowledgmentNumber'] as String? ?? json['ackNo'] as String?,
      amount: amount,
      status: json['status'] as String? ?? json['paymentStatus'] as String?,
      timestamp: timestamp,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
    );
  }
}