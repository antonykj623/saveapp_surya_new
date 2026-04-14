import 'package:new_project_2025/view_model/Bbps/screens/selectproviderPage.dart';

class BillerMasterResp {
  final GeneralResp? generalResp;
  final List<BillerModel>? billerResp;

  BillerMasterResp({this.generalResp, this.billerResp});

  factory BillerMasterResp.fromJson(Map<String, dynamic> json) {
    return BillerMasterResp(
      generalResp: json['generalResp'] != null
          ? GeneralResp.fromJson(json['generalResp'])
          : null,
      billerResp: json['billerResp'] != null
          ? List<BillerModel>.from(
          json['billerResp'].map((x) => BillerModel.fromJson(x)))
          : [],
    );
  }
}

class GeneralResp {
  final String? statusCode;
  final String? message;

  GeneralResp({this.statusCode, this.message});

  factory GeneralResp.fromJson(Map<String, dynamic> json) {
    return GeneralResp(
      statusCode: json['statusCode']?.toString(),
      message: json['message']?.toString(),
    );
  }
}
