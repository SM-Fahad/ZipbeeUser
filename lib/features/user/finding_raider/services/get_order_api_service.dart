import 'dart:convert';
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/service/app_http_client.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:flutter/foundation.dart';

class GetOrderApiService {
  static Future<Map<String, dynamic>> fetchOrderDetails(int orderId) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      // URL ডায়নামিক করা হচ্ছে (ধরে নেওয়া হচ্ছে ApiEndPoint এ 'order/{orderId}' আছে)
      final url = ApiEndPoint.getOrder.replaceAll('{orderId}', orderId.toString());

      final response = await AppHttpClient.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('✅ GET ORDER URL: $url');
      debugPrint('✅ GET ORDER RESPONSE: ${response.statusCode} & ✅ Body: ${response.body}');

      final decoded = jsonDecode(response.body);

      return {
        'statusCode': response.statusCode,
        'success': decoded['success'] ?? false,
        'data': decoded['data']
      };
    } catch (e) {
      debugPrint('❌ GetOrderApiService.fetchOrderDetails error: $e');
      return {'statusCode': 500, 'success': false, 'data': null};
    }
  }
}