import 'package:http/http.dart' as http;
import 'package:new_project_2025/view_model/Bbps/screens/paymentresponse_page.dart';
 import 'dart:convert';

import '../models/catogory_model.dart';

/// BBPS API Service
/// Handles all API calls to the BBPS backend
class BBPSApiService {
  // Base configuration
  static const String baseUrl = 'https://bbps-staging.digiledge.in';
  static const String apiKey = 'b8rFeserZ7GnUEPW2Z5eLkauqqGhJq';
  static const String agentId = 'FE41FE16MOBU00000001';
  static const String tenantId = 'FE41';

  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      'x-digiledge-key': apiKey,
      'agentId': agentId,
      'tenantId': tenantId,
    };
  }

  static Future<PaymentResponse> makePayment({
    required String billerId,
    required Map<String, String> customerParams,
    required double amount,
    String? billNumber,
    String? billDate,
    String? dueDate,
  }) async {
    try {
      final requestBody = {
        'billerId': billerId,
        ...customerParams,
        'amount': amount.toString(),
        if (billNumber != null) 'billNumber': billNumber,
        if (billDate != null) 'billDate': billDate,
        if (dueDate != null) 'dueDate': dueDate,
      };

      final uri = Uri.parse('$baseUrl/agent/bbps/pay-bill');

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💳 Making Payment');
      print('Body: ${jsonEncode(requestBody)}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('Response: ${response.statusCode}');
      print('Data: ${response.body}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PaymentResponse.fromJson(json);
      } else {
        String errorMessage = 'Payment failed';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage =
              errorJson['message'] ??
                  errorJson['error'] ??
                  errorJson['errorMessage'] ??
                  errorMessage;
        } catch (_) {
          errorMessage = response.body;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ makePayment error → $e');
      rethrow;
    }
  }


  // Future<void> makeBBPSPayment({
  //   required String billId,
  //   required double amount,
  // }) async {
  //
  //   final url = Uri.parse(
  //     "https://bbps-staging.digiledge.in/agent/bbps/pay-bill",
  //   );
  //
  //   try {
  //
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         "Content-Type": "application/json",
  //         "tenantId": "FE41",
  //         "agentId": "FE41FE16MOBU00000001",
  //         "x-digiledge-key": "b8rFeserZ7GnUEPW2Z5eLkauqqGhJq",
  //       },
  //       body: jsonEncode({
  //         "billId": billId,
  //         "amount": amount
  //       }),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       print("✅ BBPS Payment Success: $data");
  //     } else {
  //       print("❌ BBPS Payment Failed: ${response.body}");
  //     }
  //
  //   } catch (e) {
  //     print("⚠️ BBPS Payment Exception: $e");
  //   }
  // }

  /// Fetch all categories from the API
  /// Returns a list of CategoryModel objects
   static Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agent/cou-master/masters/categories-master?tenantId=$tenantId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['categoryRespList'] != null) {
          List<CategoryModel> categories = [];
          for (var item in jsonData['categoryRespList']) {
            categories.add(CategoryModel.fromJson(item));
          }
          return categories;
        }
        return [];
      } else {
        throw Exception('Failed to load categories. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

// TODO: Add more API methods here as needed
// Example:
// static Future<BillerModel> getBillers(String categoryId) async { ... }
// static Future<PaymentResponse> makePayment(PaymentRequest request) async { ... }
}