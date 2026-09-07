import 'dart:convert';
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CancelOrderService {
  static Future<Map<String, dynamic>> cancelOrder(int orderId, String? reason) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      // URL ডায়নামিক করা হচ্ছে
      final url = ApiEndPoint.cancelOrder.replaceAll('{orderId}', orderId.toString()); 

      // যদি reason নাল (null) বা খালি (empty) হয়, তবে ডিফল্ট মান সেট হবে
      final String finalReason = (reason == null || reason.trim().isEmpty) 
          ? "Hamara Mardi" 
          : reason;

      final response = await http.patch(
        Uri.parse(url), 
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token', 
        }, 
        body: jsonEncode({
          'reason': finalReason
        })
      );

      debugPrint('✅ CANCEL ORDER RESPONSE: ${response.statusCode}\n${response.body}'); 

      final decoded = jsonDecode(response.body);

      return {
        'statusCode': response.statusCode,
        'success': decoded['success'] ?? false,
        'body': decoded
      };
    } catch (e) {
      debugPrint('❌ CancelOrderService.cancelOrder error: $e');
      return {'statusCode': 500, 'success': false, 'body': {}};
    }
  }
}