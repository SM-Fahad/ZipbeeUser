import 'dart:convert';
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Destination2Service {
  static Future<Map<String, dynamic>> createDestination(
      Map<String, dynamic> body) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      final response = await http.post(
        Uri.parse('${ApiEndPoint.baseUrl}/destination'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint(
          'CREATE DEST RESPONSE: ${response.statusCode} ${response.body}');

      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      debugPrint('DestinationService error: $e');
      return {'statusCode': 500, 'body': {}};
    }
  }
}
