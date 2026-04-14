import 'package:flutter/services.dart';

class NativeStorage {
  static const platform = MethodChannel('save_drive/channel');

  static Future<void> saveLogin({
    required int status,
    required String token,
    required String userId,
  }) async {
    await platform.invokeMethod('saveLoginData', {
      "status": status,
      "token": token,
      "userid": userId,
    });
  }

  static Future<Map?> getLogin() async {
    final result = await platform.invokeMethod('getLoginData');
    return result;
  }

  static Future<void> clearLogin() async {
    await platform.invokeMethod('clearLoginData');
  }
}