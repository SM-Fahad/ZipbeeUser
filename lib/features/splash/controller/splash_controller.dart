import 'package:ZipBee/core/service/app_http_client.dart';
import 'package:get/get.dart';

import '../../../core/api_end_point/api_end_point.dart';
import '../../../core/shared_prefference_service/shared_pref.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final token = await SharedPreferencesHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      _goToLogin();
      return;
    }

    final isValid = await _validateToken();

    if (isValid) {
      Get.offAllNamed(AppRoutes.getbottomNavbarScreen());
    } else {
      await SharedPreferencesHelper.clearAllData();
      _goToLogin();
    }
  }

  void _goToLogin() {
    Get.offAllNamed(AppRoutes.getOnboardingScreen());
  }

  Future<bool> _validateToken() async {
    try {
      final response = await AppHttpClient.get(
        Uri.parse("${ApiEndPoint.profile}"),
        headers: {
          "Authorization":
              "Bearer ${await SharedPreferencesHelper.getAccessToken()}",
        },
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
