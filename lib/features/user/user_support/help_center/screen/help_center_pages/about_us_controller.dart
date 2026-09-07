import 'package:ZipBee/features/user/user_support/help_center/model/about_us_model.dart';
import 'package:ZipBee/features/user/user_support/help_center/service/help_center_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class AboutUsController extends GetxController {
  final service = HelpCenterService();
  final aboutUsData = <AboutUsModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAboutUs();
  }

  Future<void> fetchAboutUs() async {
    try {
      isLoading.value = true;
      final response = await service.fetchAboutUs();

      if (response != null && response.success) {
        aboutUsData.assignAll(response.data);
      } else {
        EasyLoading.showError('Failed to load About Us');
      }
    } catch (e) {
      print('Exception: $e');
      EasyLoading.showError('Something went wrong');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await fetchAboutUs();
  }
}
