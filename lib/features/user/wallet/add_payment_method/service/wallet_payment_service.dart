import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';

/// Service for wallet payment methods (card setup and saving)
class WalletPaymentService {
  /// Create setup intent to initialize Stripe payment
  /// Returns clientSecret for Stripe Payment Sheet
  static Future<Map<String, dynamic>> createSetupIntent() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      final url = Uri.parse(ApiEndPoint.createSetupIntent);

      debugPrint('➡️ Create Setup Intent POST URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
        '✅ CREATE SETUP INTENT RESPONSE: ${response.statusCode}\n${response.body}',
      );

      final decoded = jsonDecode(response.body);
      return {
        'statusCode': response.statusCode,
        'success': response.statusCode == 200 || response.statusCode == 201,
        'body': decoded,
      };
    } catch (e) {
      debugPrint('❌ WalletPaymentService.createSetupIntent error: $e');
      return {'statusCode': 500, 'success': false, 'body': {}};
    }
  }

  /// Save card after successful payment method creation
  /// Requires paymentMethodId from Stripe
  static Future<Map<String, dynamic>> saveCard({
    required String paymentMethodId,
    required String? cardHolderName,
    required String? lastFourDigits,
    required String? cardBrand,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      final url = Uri.parse(ApiEndPoint.saveCard);

      final body = {
        'paymentMethodId': paymentMethodId,
        if (cardHolderName != null) 'cardHolderName': cardHolderName,
        if (lastFourDigits != null) 'lastFourDigits': lastFourDigits,
        if (cardBrand != null) 'cardBrand': cardBrand,
      };

      debugPrint(
        '➡️ Save Card POST body: $body and URL: $url',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint(
        '✅ SAVE CARD RESPONSE: ${response.statusCode}\n${response.body}',
      );

      final decoded = jsonDecode(response.body);
      return {
        'statusCode': response.statusCode,
        'success': response.statusCode == 200 || response.statusCode == 201,
        'body': decoded,
      };
    } catch (e) {
      debugPrint('❌ WalletPaymentService.saveCard error: $e');
      return {'statusCode': 500, 'success': false, 'body': {}};
    }
  }
}
