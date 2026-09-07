import 'dart:convert';
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/service/app_http_client.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:flutter/foundation.dart';

class PriorityOrderService {
  /// Add Priority Order (POST)
  static Future<Map<String, dynamic>> addPriorityOrder({
    required int orderId,
    required double amount,
    String payType = "WALLET",
    String? paymentMethodId,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = "${ApiEndPoint.baseUrl}/order/$orderId/priority-order";

      final Map<String, dynamic> requestBody = {
        "payType": payType,
        "amount": amount,
        if (paymentMethodId != null && paymentMethodId.isNotEmpty)
          "paymentMethodId": paymentMethodId,
      };

      debugPrint('🚀 ADD PRIORITY ORDER REQUEST URL: $url');
      debugPrint('📦 REQUEST BODY: ${jsonEncode(requestBody)}');

      final response = await AppHttpClient.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('✅ ADD PRIORITY ORDER RESPONSE CODE: ${response.statusCode}');
      debugPrint('📄 RESPONSE BODY: ${response.body}');

      final decoded = jsonDecode(response.body);
      final message = _extractMessage(decoded);

      return {
        'statusCode': response.statusCode,
        'success': decoded['success'] ?? false,
        'message': message,
        'data': decoded['data'],
        'body': decoded,
      };
    } catch (e) {
      debugPrint('❌ PriorityOrderService Add Error: $e');
      return {
        'statusCode': 500,
        'success': false,
        'message': e.toString(),
        'body': {},
      };
    }
  }

  /// Alias for backward compatibility
  static Future<Map<String, dynamic>> makePriorityOrder({
    required int orderId,
    required double amount,
    String payType = "WALLET",
    String? paymentMethodId,
  }) =>
      addPriorityOrder(
        orderId: orderId,
        amount: amount,
        payType: payType,
        paymentMethodId: paymentMethodId,
      );

  /// Update Priority Order (PATCH)
  static Future<Map<String, dynamic>> updatePriorityOrder({
    required int orderId,
    required double amount,
    String payType = "WALLET",
    String? paymentMethodId,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = "${ApiEndPoint.baseUrl}/order/$orderId/priority-order";

      final Map<String, dynamic> requestBody = {
        "payType": payType,
        "amount": amount,
        if (paymentMethodId != null && paymentMethodId.isNotEmpty)
          "paymentMethodId": paymentMethodId,
      };

      debugPrint('🚀 UPDATE PRIORITY ORDER REQUEST URL: $url');
      debugPrint('📦 REQUEST BODY: ${jsonEncode(requestBody)}');

      final response = await AppHttpClient.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('✅ UPDATE PRIORITY ORDER RESPONSE CODE: ${response.statusCode}');
      debugPrint('📄 RESPONSE BODY: ${response.body}');

      final decoded = jsonDecode(response.body);
      final message = _extractMessage(decoded);

      return {
        'statusCode': response.statusCode,
        'success': decoded['success'] ?? false,
        'message': message,
        'data': decoded['data'],
        'body': decoded,
      };
    } catch (e) {
      debugPrint('❌ PriorityOrderService Update Error: $e');
      return {
        'statusCode': 500,
        'success': false,
        'message': e.toString(),
        'body': {},
      };
    }
  }

  /// Cancel Priority Order (DELETE)
  static Future<Map<String, dynamic>> cancelPriorityOrder({
    required int orderId,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = "${ApiEndPoint.baseUrl}/order/$orderId/priority-order";

      debugPrint('🚀 CANCEL PRIORITY ORDER REQUEST URL: $url');

      final response = await AppHttpClient.delete(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('✅ CANCEL PRIORITY ORDER RESPONSE CODE: ${response.statusCode}');
      debugPrint('📄 RESPONSE BODY: ${response.body}');

      final decoded = jsonDecode(response.body);
      final message = _extractMessage(decoded);

      return {
        'statusCode': response.statusCode,
        'success': decoded['success'] ?? false,
        'message': message,
        'data': decoded['data'],
        'body': decoded,
      };
    } catch (e) {
      debugPrint('❌ PriorityOrderService Cancel Error: $e');
      return {
        'statusCode': 500,
        'success': false,
        'message': e.toString(),
        'body': {},
      };
    }
  }

  static String _extractMessage(dynamic decoded) {
    if (decoded is Map && decoded['message'] != null) {
      if (decoded['message'] is List) {
        return (decoded['message'] as List).isNotEmpty
            ? (decoded['message'] as List)[0].toString()
            : 'Unknown message';
      }
      return decoded['message'].toString();
    }
    return 'Unknown message';
  }
}