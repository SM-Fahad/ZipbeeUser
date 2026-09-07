import 'dart:convert';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/service/app_http_client.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:flutter/foundation.dart';

class AdsService {
  static Future<List<Map<String, dynamic>>> fetchAds() async {
    final token = await SharedPreferencesHelper.getAccessToken();

    final response = await AppHttpClient.get(
      Uri.parse(ApiEndPoint.homePageAd),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List list = decoded['data']['data'];
      return List<Map<String, dynamic>>.from(list);
    } else {
      throw Exception("Failed to load ads");
    }
  }

  static Future<void> recordImpression(int adId) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = ApiEndPoint.adImpression.replaceAll('{id}', adId.toString());

      final response = await AppHttpClient.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "accept": "*/*",
        },
      );

      if (kDebugMode) {
        debugPrint("Ad impression recorded for $adId: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error recording ad impression for $adId: $e");
      }
    }
  }

  static Future<void> recordClick(int adId) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = ApiEndPoint.adClick.replaceAll('{id}', adId.toString());

      final response = await AppHttpClient.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "accept": "*/*",
        },
      );

      if (kDebugMode) {
        debugPrint("Ad click recorded for $adId: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error recording ad click for $adId: $e");
      }
    }
  }
}

