import 'dart:convert';
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class YourRewardsService {
  static Future<Map<String, dynamic>> fetchBasePrice() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final headers = <String, String>{'accept': '*/*'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.get(
        Uri.parse(ApiEndPoint.coinBasePrice),
        headers: headers,
      );
      debugPrint('BASE PRICE RESPONSE: ${response.body}');
      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      debugPrint('YourRewardsService.fetchBasePrice error: $e');
      return {'statusCode': 500, 'body': {}};
    }
  }

  static Future<Map<String, dynamic>> redeemPoint({required int coin}) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      // Swagger shows referloyality/redeem-point expects query param `point`
      final url = Uri.parse('${ApiEndPoint.redeemPoint}?point=$coin');
      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      };
      final response = await http.post(url, headers: headers);

      debugPrint('REDEEM COIN REQUEST: $url');
      debugPrint('REDEEM COIN RESPONSE: ${response.body}');

      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      debugPrint('YourRewardsService.redeemCoin error: $e');
      return {'statusCode': 500, 'body': {}};
    }
  }

  static Future<Map<String, dynamic>> fetchReferralHistory({
    required String referCode,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiEndPoint.referLoyalty}?refer_code=$referCode',
      );
      final token = await SharedPreferencesHelper.getAccessToken();
      final headers = <String, String>{'accept': '*/*'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.get(url, headers: headers);
      debugPrint('REFERRAL HISTORY REQUEST: $url');
      debugPrint('REFERRAL HISTORY RESPONSE: ${response.body}');

      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      debugPrint('YourRewardsService.fetchReferralHistory error: $e');
      return {'statusCode': 500, 'body': {}};
    }
  }
}
