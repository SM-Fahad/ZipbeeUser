import 'dart:convert';
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OrderService {
  static String _devicePlacedAtIso() {
    final now = DateTime.now();
    return DateTime.utc(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
    ).toIso8601String();
  }

  /// Create an individual order.
  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> body,
      {required String deliveryType}) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = ApiEndPoint.orderCreate;

      debugPrint('➡️ REQUEST URL: $url');
      debugPrint('➡️ REQUEST BODY: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('⬅️ RESPONSE: ${response.statusCode} ${response.body}');

      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      debugPrint('❌ createOrder error: $e');
      return {'statusCode': 500, 'body': {}};
    }
  }

  /// Get order details by id
  static Future<Map<String, dynamic>> getOrder(int id) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = '${ApiEndPoint.baseUrl}/order/$id';

      debugPrint('➡️ REQUEST URL: $url');
      debugPrint('➡️ REQUEST BODY: NONE (GET)');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('⬅️ RESPONSE: ${response.statusCode} ${response.body}');

      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      debugPrint('❌ getOrder error: $e');
      return {'statusCode': 500, 'body': {}};
    }
  }

  /// Place Order
  static Future<Map<String, dynamic>> placeOrder({
    required int orderId,
    required String paymentMethod, // COD | WALLET | ONLINE_PAY
    String? codCollectFrom,
    String? paymentMethodId,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = '${ApiEndPoint.baseUrl}/order/$orderId/place';

      final body = <String, dynamic>{
        'paymentMethod': paymentMethod,
        'placedAt': _devicePlacedAtIso(),
        if (paymentMethod == 'COD' && codCollectFrom != null)
          'codCollectFrom': codCollectFrom,
        if (paymentMethod == 'ONLINE_PAY') ...{
          if (paymentMethodId != null) 'paymentMethodId': paymentMethodId,
          'payType': 'PAYMENT',
        },
      };

      debugPrint('➡️ REQUEST URL: $url');
      debugPrint('➡️ REQUEST BODY: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('⬅️ RESPONSE: ${response.statusCode} ${response.body}');

      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      debugPrint('❌ placeOrder error: $e');
      return {'statusCode': 500, 'body': {}};
    }
  }

  /// Update Order Details
  static Future<Map<String, dynamic>> updateOrderDetails(
      int id, Map<String, dynamic> body) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url =
          ApiEndPoint.orderUpdateDetails.replaceFirst('{id}', id.toString());

      debugPrint('➡️ REQUEST URL: $url');
      debugPrint('➡️ REQUEST BODY: ${jsonEncode(body)}');

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('⬅️ RESPONSE: ${response.statusCode} ${response.body}');

      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      debugPrint('❌ updateOrderDetails error: $e');
      return {'statusCode': 500, 'body': {}};
    }
  }
}
