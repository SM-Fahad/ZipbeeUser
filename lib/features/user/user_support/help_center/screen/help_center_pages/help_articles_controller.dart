import 'package:ZipBee/features/user/user_support/help_center/model/help_article_model.dart';
import 'package:ZipBee/features/user/user_support/help_center/service/help_center_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class HelpArticlesController extends GetxController {
  final service = HelpCenterService();
  final articles = <HelpArticleModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    try {
      isLoading.value = true;
      final response = await service.fetchHelpArticles();

      if (response != null && response.success) {
        articles.assignAll(response.data);
      } else {
        EasyLoading.showError('Failed to load articles');
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
    await fetchArticles();
  }
}
