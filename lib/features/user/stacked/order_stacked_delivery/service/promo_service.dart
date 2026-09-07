import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';

class PromoService {
  static Future<Map<String, String>> _headers() async {
    final token = await SharedPreferencesHelper.getAccessToken();

    return {
      'accept': '*/*',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> applyPromo({
    required int orderId,
    required String promoCode,
  }) async {
    try {
      final url = '${ApiEndPoint.baseUrl}/order/$orderId/apply-discount';

      final response = await http.post(
        Uri.parse(url),
        headers: await _headers(),
        body: jsonEncode({
          "promoCode": promoCode,
        }),
      );

      debugPrint(
          '✅ APPLY PROMO RESPONSE: ${response.statusCode}\n${response.body}');

      final decoded = jsonDecode(response.body);

      return {
        'statusCode': response.statusCode,
        'success': decoded['success'] ?? false,
        'body': decoded,
      };
    } catch (e) {
      debugPrint('❌ PromoService.applyPromo error: $e');
      return {'statusCode': 500, 'success': false, 'body': {}};
    }
  }

  static Future<Map<String, dynamic>> applyCoins({
    required int orderId,
    required int coinsAmount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiEndPoint.baseUrl}/order/$orderId/apply-discount'),
        headers: await _headers(),
        body: jsonEncode({
          "useCoins": true,
          "coinsAmount": coinsAmount,
        }),
      );

      debugPrint(
        '✅ APPLY COINS RESPONSE: ${response.statusCode}\n${response.body}',
      );

      final decoded = jsonDecode(response.body);

      return {
        'statusCode': response.statusCode,
        'success': decoded['success'] ?? false,
        'body': decoded,
      };
    } catch (e) {
      debugPrint('❌ PromoService.applyCoins error: $e');
      return {'statusCode': 500, 'success': false, 'body': {}};
    }
  }

  static Future<Map<String, dynamic>> removeDiscount({
    required int orderId,
    required String type,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiEndPoint.removeDiscount(orderId: orderId, type: type)),
        headers: await _headers(),
      );

      debugPrint(
        '✅ REMOVE DISCOUNT [$type] RESPONSE: ${response.statusCode}\n${response.body}',
      );

      final decoded = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{};

      return {
        'statusCode': response.statusCode,
        'success': decoded['success'] ?? (response.statusCode == 200),
        'body': decoded,
      };
    } catch (e) {
      debugPrint('❌ PromoService.removeDiscount error: $e');
      return {'statusCode': 500, 'success': false, 'body': {}};
    }
  }
}
