import 'dart:convert';
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/service/app_http_client.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:flutter/foundation.dart';

class ChatApiService {
  static String get chatHistory => ApiEndPoint.chatHistory;

  static Future<Map<String, dynamic>?> getChatHistoryData({
    required String receiverId,
    required String orderId,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      final response = await AppHttpClient.post(
        Uri.parse(chatHistory),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"otherUserId": receiverId, "orderId": orderId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['data'] is Map<String, dynamic>) {
          return data['data'];
        }
        return {'messages': data['data']['messages'] ?? []};
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("❌ User getChatHistoryData error: $e");
      return null;
    }
  }

  static Future<List<dynamic>?> getChatHistory({
    required String receiverId,
    required String orderId,
  }) async {
    try {
      final data = await getChatHistoryData(
        receiverId: receiverId,
        orderId: orderId,
      );
      return data?['messages'] as List<dynamic>?;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> markAsRead(String conversationId) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = ApiEndPoint.chatMarkAsRead(conversationId);

      final response = await AppHttpClient.patch(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("❌ User markAsRead REST error: $e");
      return false;
    }
  }
}
