import 'dart:convert';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/service/app_http_client.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:flutter/cupertino.dart';

class DashboardPopupService {
  static Future<Map<String, dynamic>> fetchPopups({
    bool activeOnly = true,
    int limit = 1,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url =
          "${ApiEndPoint.baseUrl}/dashboard-popup?activeOnly=$activeOnly&limit=$limit";

      final response = await AppHttpClient.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      debugPrint('🔍 POPUP API RESPONSE: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('❌ DashboardPopupService Error: $e');
      return {'success': false, 'data': []};
    }
  }

  static Future<Map<String, dynamic>> markPopupAsSeen(int id) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = "${ApiEndPoint.baseUrl}/dashboard-popup/$id/seen";

      final response = await AppHttpClient.post(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      debugPrint('🔍 MARK SEEN API RESPONSE: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('❌ DashboardPopupService markPopupAsSeen Error: $e');
      return {'success': false};
    }
  }
}