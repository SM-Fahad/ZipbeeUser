import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';

class WalletPaymentMethodService {
  /// ==============================
  /// CREATE SETUP INTENT
  /// ==============================
  static Future<Map<String, dynamic>> createSetupIntent() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = Uri.parse(ApiEndPoint.createSetupIntent);

      debugPrint("➡️ CREATE SETUP INTENT URL: $url");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      debugPrint("✅ RESPONSE: ${response.statusCode} | ${response.body}");

      final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      return {
        "success": response.statusCode == 200 || response.statusCode == 201,
        "body": decoded,
      };
    } catch (e) {
      debugPrint("❌ createSetupIntent error: $e");
      return {
        "success": false,
        "body": {"message": "Server error"},
      };
    }
  }

  /// ==============================
  /// SAVE CARD
  /// ==============================
  static Future<Map<String, dynamic>> saveCard({
    required String paymentMethodId,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = Uri.parse(ApiEndPoint.saveCard);

      debugPrint("➡️ SAVE CARD URL: $url");
      debugPrint("➡️ PAYMENT METHOD ID: $paymentMethodId");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode({"paymentMethodId": paymentMethodId}),
      );

      debugPrint("✅ RESPONSE: ${response.statusCode} | ${response.body}");

      final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      return {
        "success": response.statusCode == 200 || response.statusCode == 201,
        "body": decoded,
      };
    } catch (e) {
      debugPrint("❌ saveCard error: $e");
      return {
        "success": false,
        "body": {"message": "Server error"},
      };
    }
  }

  /// ==============================
  /// GET SAVED CARD
  /// ==============================
  static Future<Map<String, dynamic>> getSavedCard() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = Uri.parse(ApiEndPoint.getSavedCard);

      debugPrint("➡️ GET SAVED CARD URL: $url");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      debugPrint("✅ RESPONSE: ${response.statusCode} | ${response.body}");

      final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      return {"success": response.statusCode == 200, "body": decoded};
    } catch (e) {
      debugPrint("❌ getSavedCard error: $e");
      return {
        "success": false,
        "body": {"message": "Server error"},
      };
    }
  }

  /// ==============================
  /// GET SAVED CARDS
  /// ==============================
  static Future<Map<String, dynamic>> getSavedCards() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = Uri.parse(ApiEndPoint.walletCards);

      debugPrint("➡️ GET SAVED CARDS URL: $url");

      final response = await http.get(
        url,
        headers: {
          "accept": "*/*",
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      debugPrint("✅ RESPONSE: ${response.statusCode} | ${response.body}");

      final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : [];

      return {"success": response.statusCode == 200, "body": decoded};
    } catch (e) {
      debugPrint("❌ getSavedCards error: $e");
      return {"success": false, "body": <dynamic>[]};
    }
  }

  /// ==============================
  /// DELETE SAVED CARD
  /// ==============================
  static Future<Map<String, dynamic>> deleteSavedCard(int cardId) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = Uri.parse(ApiEndPoint.walletCardById(cardId));

      debugPrint("➡️ DELETE CARD URL: $url");

      final response = await http.delete(
        url,
        headers: {
          "accept": "*/*",
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      debugPrint("✅ RESPONSE: ${response.statusCode} | ${response.body}");

      final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      return {
        "success": response.statusCode == 200 || response.statusCode == 204,
        "body": decoded,
      };
    } catch (e) {
      debugPrint("❌ deleteSavedCard error: $e");
      return {
        "success": false,
        "body": {"message": "Server error"},
      };
    }
  }
}
