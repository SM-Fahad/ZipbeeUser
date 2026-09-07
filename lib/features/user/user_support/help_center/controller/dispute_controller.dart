import 'dart:convert';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:ZipBee/features/user/user_support/help_center/controller/create_dispute_controller.dart';
import 'package:ZipBee/features/user/user_support/help_center/widgets/create_dispute_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DisputeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxList<Map<String, dynamic>> disputes = <Map<String, dynamic>>[].obs;
  final RxInt totalCount = 0.obs;
  final RxInt currentPage = 1.obs;
  final int limit = 10;
  bool hasMore = true;

  @override
  void onInit() {
    super.onInit();
    fetchDisputes();
  }

  Future<void> fetchDisputes({
    bool showLoader = true,
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (isLoadingMore.value || isLoading.value || !hasMore) {
        return;
      }
      isLoadingMore.value = true;
    } else {
      if (isLoading.value) return;
      if (showLoader) {
        isLoading.value = true;
      }
      currentPage.value = 1;
      hasMore = true;
      disputes.clear();
    }

    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        disputes.clear();
        totalCount.value = 0;
        EasyLoading.showError('Access token not found');
        return;
      }

      final pageToLoad = loadMore ? currentPage.value + 1 : 1;
      final uri = Uri.parse(
        ApiEndPoint.disputesPaginated(page: pageToLoad, limit: limit),
      );

      final response = await http.get(
        uri,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>? ?? {};
        final items = (data['data'] as List<dynamic>? ?? [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        final meta = data['meta'] as Map<String, dynamic>? ?? {};
        final totalPages = (meta['totalPages'] as num?)?.toInt() ?? 1;
        final page = (meta['page'] as num?)?.toInt() ?? pageToLoad;

        currentPage.value = page;
        if (loadMore) {
          disputes.addAll(items);
        } else {
          disputes.assignAll(items);
        }
        totalCount.value = (meta['total'] as num?)?.toInt() ?? items.length;
        hasMore = currentPage.value < totalPages;
        return;
      }

      if (!loadMore) {
        disputes.clear();
        totalCount.value = 0;
      }
      EasyLoading.showError(body['message']?.toString() ?? 'Failed to load disputes');
    } catch (e) {
      if (!loadMore) {
        disputes.clear();
        totalCount.value = 0;
      }
      debugPrint('Dispute fetch error: $e');
      EasyLoading.showError('Something went wrong');
    } finally {
      if (loadMore) {
        isLoadingMore.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  Future<void> refreshDisputes() async {
    await fetchDisputes(showLoader: false);
  }

  Future<void> loadMoreDisputes() async {
    await fetchDisputes(loadMore: true, showLoader: false);
  }

  Future<void> openCreateDispute() async {
    if (Get.isRegistered<CreateDisputeController>()) {
      Get.delete<CreateDisputeController>(force: true);
    }
    final created = await Get.to<bool>(() => const CreateDisputeScreen());
    if (created == true) {
      await fetchDisputes(showLoader: false);
    }
  }
}
