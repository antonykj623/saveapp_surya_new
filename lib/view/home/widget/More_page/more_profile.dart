class DSTResponse {
  final int status;
  final String message;
  final DSTData data;

  DSTResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DSTResponse.fromJson(Map<String, dynamic> json) {
    return DSTResponse(
      status: json['status'],
      message: json['message'],
      data: DSTData.fromJson(json['data']),
    );
  }
}

class DSTData {
  final String id;
  final String position;
  final String positionDownlineSetupDefault;
  final String positionNext;
  final String binaryLeft;
  final String binaryRight;
  final String binaryMatched;
  final String carryLeft;
  final String memberStatus;
  final String carryRight;
  final String binaryAmt;
  final String referralCommissionAmt;
  final String levelAmt;
  final String achievementAmt;

  DSTData({
    required this.id,
    required this.position,
    required this.positionDownlineSetupDefault,
    required this.positionNext,
    required this.binaryLeft,
    required this.binaryRight,
    required this.binaryMatched,
    required this.carryLeft,
    required this.memberStatus,
    required this.carryRight,
    required this.binaryAmt,
    required this.referralCommissionAmt,
    required this.levelAmt,
    required this.achievementAmt,
  });

  factory DSTData.fromJson(Map<String, dynamic> json) {
    return DSTData(
      id: json['id'],
      position: json['position'],
      positionDownlineSetupDefault: json['position_downline_setup_default'],
      positionNext: json['position_next'],
      binaryLeft: json['binary_left'],
      binaryRight: json['binary_right'],
      binaryMatched: json['binary_matched'],
      carryLeft: json['carry_left'],
      memberStatus: json['member_status'],
      carryRight: json['carry_right'],
      binaryAmt: json['binary_amt'],
      referralCommissionAmt: json['referral_commission_amt'],
      levelAmt: json['level_amt'],
      achievementAmt: json['achievement_amt'],
    );
  }
}