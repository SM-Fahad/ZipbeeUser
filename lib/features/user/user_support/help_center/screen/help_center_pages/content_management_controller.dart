import 'package:ZipBee/features/user/user_support/help_center/model/content_management_model.dart';
import 'package:ZipBee/features/user/user_support/help_center/service/help_center_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class ContentManagementController extends GetxController {
  final service = HelpCenterService();
  final contentList = <ContentManagementModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchContentManagement();
  }

  Future<void> fetchContentManagement() async {
    try {
      isLoading.value = true;
      final response = await service.fetchContentManagement();

      if (response != null && response.success) {
        contentList.assignAll(response.data);
      } else {
        EasyLoading.showError('Failed to load content');
      }
    } catch (e) {
      print('Exception: $e');
      EasyLoading.showError('Something went wrong');
    } finally {
      isLoading.value = false;
    }
  }

  String? getContentByType(String contentType) {
    try {
      final item = contentList.firstWhere(
        (element) =>
            element.contentType.toUpperCase() == contentType.toUpperCase(),
      );
      return item.description;
    } catch (e) {
      return null;
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await fetchContentManagement();
  }
}
