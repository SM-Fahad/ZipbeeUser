import 'dart:convert';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;



class ResetPasswordController extends GetxController {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  RxString email = ''.obs;
  RxString phone = ''.obs;
  RxBool isLoading = false.obs;

  var hideNew = true.obs;
  var hideConfirm = true.obs;

  void toggleNew() => hideNew.value = !hideNew.value;
  void toggleConfirm() => hideConfirm.value = !hideConfirm.value;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    email.value = args['email'] ?? '';
    phone.value = args['phone'] ?? '';
  }

  Future<void> createNewPassword() async {
    final password = newPasswordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      _error("Password fields cannot be empty");
      return;
    }

    if (password != confirm) {
      _error("Passwords do not match");
      return;
    }

    if (password.length < 6) {
      _error("Password must be at least 6 characters");
      return;
    }

    isLoading.value = true;

    final body = {
      "newPassword": password,
      if (email.value.isNotEmpty) "email": email.value,
      if (phone.value.isNotEmpty) "phone": phone.value,
    };

    debugPrint("RESET PASSWORD BODY => $body");

    try {
      final response = await http.post(
        Uri.parse(ApiEndPoint.resetPass),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final responseBody = jsonDecode(response.body);
      debugPrint("RESET PASSWORD RESPONSE => $responseBody");

      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.showSuccess(responseBody['message'] ?? 'Password reset successfully');

        Get.offAllNamed(AppRoutes.loginScreen);
      } else {
        _error(responseBody['message'] ?? "Something went wrong");
      }
    } catch (e) {
      debugPrint("RESET PASSWORD ERROR => $e");
      _error("Failed to reset password");
    } finally {
      isLoading.value = false;
    }
  }

  void _error(String msg) {
    EasyLoading.showError(msg);
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
