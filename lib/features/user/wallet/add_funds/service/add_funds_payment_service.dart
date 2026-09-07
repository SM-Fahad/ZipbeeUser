import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';

class AddFundsPaymentService {
  static Future<Map<String, dynamic>> addMoneyToWallet({
    required double amount,
    required String paymentMethodId,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      final url = Uri.parse(ApiEndPoint.addMoneyDirect);

      final body = {
        'amount': amount,
        'paymentMethodId': paymentMethodId,
        'currency': 'sgd',
        'payType': 'ADD_MONEY',
      };

      debugPrint('➡️ AddMoney URL: $url');
      debugPrint('➡️ Body: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('📡 Response: ${response.statusCode}');
      debugPrint(response.body);

      final decoded = jsonDecode(response.body);

      return {
        'statusCode': response.statusCode,
        'success': decoded['success'] ?? false,
        'body': decoded,
      };
    } catch (e) {
      debugPrint("❌ AddFundsPaymentService Error: $e");
      return {'success': false, 'body': {}};
    }
  }
}
