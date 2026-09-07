import 'dart:convert';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/service/app_http_client.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:flutter/foundation.dart';

class ShareRewardService {
  static Future<Map<String, dynamic>> share() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      final response = await AppHttpClient.post(
        Uri.parse(ApiEndPoint.shareReward),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
        '✅ SHARE REWARD RESPONSE: ${response.statusCode}\n${response.body}',
      );

      final decoded = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{};

      return {
        'statusCode': response.statusCode,
        'success': decoded['success'] ?? response.statusCode < 400,
        'body': decoded,
      };
    } catch (e) {
      debugPrint('❌ ShareRewardService.share error: $e');
      return {'statusCode': 500, 'success': false, 'body': {}};
    }
  }
}
