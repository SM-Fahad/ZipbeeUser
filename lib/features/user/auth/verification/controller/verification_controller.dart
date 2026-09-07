import 'dart:async';
import 'package:ZipBee/features/user/auth/login/auth_service/auth_service.dart';
import 'package:ZipBee/features/user/auth/login/controller/login_signup_controller.dart';
import 'package:ZipBee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';


class VerificationController extends GetxController {
  // ------------------- OTP Input Controllers -------------------
  final List<TextEditingController> pinControllers =
      List.generate(4, (_) => TextEditingController());

  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  RxString otp = ''.obs;
  RxInt secondsLeft = 50.obs;
  RxBool isVerifying = false.obs;

  // ------------------- User Info -------------------
  RxString phone = ''.obs;
  RxString email = ''.obs;

  // Mode: 'login' or 'signup'
  RxString mode = 'signup'.obs;

  Timer? timer;

  bool get canResend => secondsLeft.value == 0;
  bool get canVerify => otp.value.length == 4 && !isVerifying.value;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;

    if (args != null) {
      if (args.containsKey('phone')) phone.value = args['phone'];
      if (args.containsKey('email')) email.value = args['email'];
      if (args.containsKey('mode')) mode.value = args['mode'];
    }

    for (var c in pinControllers) {
      c.addListener(_onPinsChanged);
    }

    _startTimer();
  }

  void _onPinsChanged() {
    otp.value = pinControllers.map((c) => c.text).join();
  }

  void _startTimer({int from = 50}) {
    timer?.cancel();
    secondsLeft.value = from;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft.value == 0) {
        t.cancel();
      } else {
        secondsLeft.value--;
      }
    });
  }

  // ------------------- Resend OTP -------------------
  Future<void> resendCode() async {
    if (!canResend) return;

    _startTimer(from: 50);

    try {
      await AuthService.verifyOtp(
        email: email.value,
        otp: "0000", // server expects a POST, but resend may require separate API
      );

      EasyLoading.showSuccess('OTP sent again');
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }

  // ------------------- Verify OTP -------------------
  Future<void> verifyCode() async {
    if (!canVerify) return;

    isVerifying.value = true;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final result = await AuthService.verifyOtp(
        email: email.value,
        otp: otp.value,
      );

      Get.back(); // close loader

      if (result['statusCode'] == 201 || result['statusCode'] == 200) {
        // Login or Signup redirect
        if (mode.value == 'login') {
          Get.offAllNamed(AppRoutes.bottomNavbarScreen);
          EasyLoading.showSuccess('Login OTP Verified');
        } else if (mode.value == 'forgot_password') {
          Get.offNamed(
            AppRoutes.resetPasswordScreen,
            arguments: {"email": email.value},
          );
          EasyLoading.showSuccess('OTP Verified. Please reset your password.');
        } else {
          EasyLoading.showSuccess('Signup Successful! Please login.');
          
          if (Get.isRegistered<LoginSignupController>()) {
            Get.find<LoginSignupController>().isLogin.value = true;
          }

          Get.offAllNamed(AppRoutes.loginScreen);
        }
      } else {
        EasyLoading.showError(result['body']['message'] ?? 'Error');
      }
    } catch (e) {
      Get.back();
      EasyLoading.showError(e.toString());
    } finally {
      isVerifying.value = false;
    }
  }

  // ------------------- Handle OTP Input -------------------
  void onPinChanged(String value, int index) {
    if (value.length > 1) {
      final last = value.substring(value.length - 1);
      pinControllers[index].text = last;
      pinControllers[index].selection =
          TextSelection.collapsed(offset: last.length);
    }
    if (value.isNotEmpty && index < focusNodes.length - 1) {
      focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  void clearPins() {
    for (var c in pinControllers) c.clear();
    focusNodes[0].requestFocus();
  }

  @override
  void onClose() {
    timer?.cancel();
    for (var c in pinControllers) {
      c.removeListener(_onPinsChanged);
      c.dispose();
    }
    for (var f in focusNodes) f.dispose();
    super.onClose();
  }
}
