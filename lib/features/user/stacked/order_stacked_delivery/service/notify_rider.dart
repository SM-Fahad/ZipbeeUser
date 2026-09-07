import 'dart:convert';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

class NotifyRider {
  static Future<Map<String, dynamic>> notifyRider({
    required String orderId,
    required bool notifyRider,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = ApiEndPoint.notifyOrder.replaceAll('{orderId}', orderId);

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"notify_rider": notifyRider}),
      );

      debugPrint(
        '✅ NOTIFY RIDER RESPONSE: ${response.statusCode}\n${response.body}',
      );

      final decoded = jsonDecode(response.body);

      return {
        'statusCode': response.statusCode,
        'success': decoded['success'] ?? false,
        'body': decoded,
      };
    } catch (e) {
      debugPrint("Error notifying rider: $e");
      return {'statusCode': 500, 'success': false, 'body': {}};
    }
  }

  static Future<Map<String, dynamic>> notifyFavoriteRider({
    required String orderId,
    required bool notifyRider,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = ApiEndPoint.notifyFavoriteRider.replaceAll(
        '{orderId}',
        orderId,
      );

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"notify_rider": notifyRider}),
      );

      debugPrint(
        '✅ NOTIFY FAVORITE RIDER RESPONSE: ${response.statusCode}\n${response.body}',
      );

      final decoded = jsonDecode(response.body);

      return {
        'statusCode': response.statusCode,
        'success': decoded['success'] ?? false,
        'body': decoded,
      };
    } catch (e) {
      debugPrint("Error notifying favorite rider: $e");
      return {'statusCode': 500, 'success': false, 'body': {}};
    }
  }

  static Future<Map<String, dynamic>> raiderConfirmation({
    required String orderId,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = ApiEndPoint.raiderConfirmation(orderId);

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
        '✅ RAIDER CONFIRMATION RESPONSE: ${response.statusCode}\n${response.body}',
      );

      final decoded = jsonDecode(response.body);

      return {
        'statusCode': response.statusCode,
        'success': decoded['success'] ?? false,
        'body': decoded,
      };
    } catch (e) {
      debugPrint("Error raider confirmation: $e");
      return {'statusCode': 500, 'success': false, 'body': {}};
    }
  }

  static Future<Map<String, dynamic>> userConfirmation({
    required String orderId,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = ApiEndPoint.userConfirmation(orderId);

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
        '✅ USER CONFIRMATION RESPONSE: ${response.statusCode}\n${response.body}',
      );

      final decoded = jsonDecode(response.body);

      return {
        'statusCode': response.statusCode,
        'success': decoded['success'] ?? false,
        'body': decoded,
      };
    } catch (e) {
      debugPrint("Error user confirmation: $e");
      return {'statusCode': 500, 'success': false, 'body': {}};
    }
  }
}
