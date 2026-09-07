import 'dart:convert';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/service/app_http_client.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileController extends GetxController {
  final userName = 'Good Morning!'.obs;
  final walletBalance = 0.0.obs;
  final availablePoints = 0.obs;

  @override
  void onInit() {
    fetchUserProfile();
    super.onInit();
  }

  Future<void> fetchUserProfile() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final response = await AppHttpClient.get(
        Uri.parse(ApiEndPoint.profile),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final data = body['data'];
          _updateProfileData(data);
        }
      }
    } catch (e) {
      debugPrint("PROFILE ERROR: $e");
    }
  }

  void _updateProfileData(Map<String, dynamic> data) {
    userName.value = "${_getGreeting()} ${data['username'] ?? ''}";
    walletBalance.value = double.tryParse(data['currentWalletBalance'].toString()) ?? 0;
    availablePoints.value = int.tryParse(data['current_coin_balance'].toString()) ?? 0;
  }

  String _getGreeting() {
  final hour = DateTime.now().hour;
  
  // 6:00 AM to 11:59 AM
  if (hour >= 6 && hour < 12) {
    return "Good Morning!";
  }
  // 12:00 PM to 4:59 PM
  if (hour >= 12 && hour < 17) {
    return "Good Afternoon!";
  }
  // 5:00 PM to 9:59 PM
  if (hour >= 17 && hour < 22) {
    return "Good Evening!";
  }
  // 10:00 PM to 5:59 AM
  return "Good Night!";
}
}