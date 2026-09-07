import 'dart:convert';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;


class ForgotPasswordController extends GetxController {
  final inputController = TextEditingController();
  var isButtonEnabled = false.obs;

  void onInputChanged(String value) {
    bool isEmail = GetUtils.isEmail(value);
    bool isPhone = GetUtils.isPhoneNumber(value) && value.length >= 8;
    isButtonEnabled.value = isEmail || isPhone;
  }

  Future<void> sendOtp() async {
    if (!isButtonEnabled.value) return;

    final String input = inputController.text.trim();
    Map<String, dynamic> body;

    if (GetUtils.isEmail(input)) {
      body = {"email": input};
    } else {
      body = {"phone": input};
    }

    debugPrint("SEND OTP BODY => $body");

    try {
      final response = await http.post(
        Uri.parse(ApiEndPoint.forgetPass),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final responseBody = jsonDecode(response.body);
      debugPrint("SEND OTP RESPONSE => $responseBody");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Navigate to OTP verification screen
        // Get.to(() => ForgetVerificationScreen());
        Get.toNamed(
          AppRoutes.verificationScreen,
          arguments: {
            ...body,
            "mode": "forgot_password",
          },
        );
      } else {
        EasyLoading.showError(responseBody['message'] ?? "Something went wrong");
      }
    } catch (e) {
      debugPrint("SEND OTP ERROR => $e");
      EasyLoading.showError("Failed to send OTP");
    }
  }

  @override
  void onClose() {
    inputController.dispose();
    super.onClose();
  }
}
