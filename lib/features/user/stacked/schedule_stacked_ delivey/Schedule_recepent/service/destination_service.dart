import 'dart:convert';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DestinationService {
  static Future<Map<String, dynamic>> createDestination(Map<String, dynamic> body) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      final response = await http.post(
        Uri.parse(ApiEndPoint.createDestination),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('✅ CREATE DESTINATION RESPONSE: ${response.statusCode}\n${response.body}');

      final decoded = jsonDecode(response.body);
      return {
        'statusCode': response.statusCode,
        'success': decoded['success'] ?? false,
        'body': decoded,
      };
    } catch (e) {
      debugPrint('❌ DestinationService.createDestination error: $e');
      return {'statusCode': 500, 'success': false, 'body': {}};
    }
  }

  /// Link a destination to an order
  static Future<Map<String, dynamic>> addDestinationToOrder({
    required int orderId,
    required int destinationId,
    required String stopType,
  }) async {
    try {
      debugPrint('DestinationService.addDestinationToOrder orderId: $orderId, destinationId: $destinationId, stopType: $stopType');
      final token = await SharedPreferencesHelper.getAccessToken();

      final url = Uri.parse(
        '${ApiEndPoint.addDestinationToOrder.replaceAll('{orderId}', orderId.toString())}'
        '?destination_id=$destinationId&stop_type=$stopType'
      );

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('✅ ADD DESTINATION TO ORDER RESPONSE: ${response.statusCode}\n${response.body}');

      final decoded = jsonDecode(response.body);
      return {
        'statusCode': response.statusCode,
        'success': decoded['success'] ?? false,
        'body': decoded,
      };
    } catch (e) {
      debugPrint('❌ DestinationService.addDestinationToOrder error: $e');
      return {'statusCode': 500, 'success': false, 'body': {}};
    }
  }
}
