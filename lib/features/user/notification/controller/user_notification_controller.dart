import 'dart:convert';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/features/user/chat/screen/chat_screen.dart';
import 'package:ZipBee/features/user/finding_raider/services/get_order_api_service.dart';
import 'package:ZipBee/features/user/notification/model/notification1_model.dart';
import 'package:ZipBee/features/user/notification/screen/promotion_details_screen.dart';
import 'package:ZipBee/features/user/order/active_order_details/screen/active_order_details_screen.dart';
import 'package:ZipBee/features/user/order/model/order_model.dart';
import 'package:ZipBee/features/user/user_support/help_center/screen/help_center_pages/dispute_screen.dart';
import 'package:ZipBee/features/user/wallet/loyalty_and_rewards/screen/loyalty_and_rewards_screen.dart';
import 'package:ZipBee/features/user/wallet/my_wallet/screen/user_my_wallet.dart';
import 'package:ZipBee/core/service/app_http_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../../../core/shared_prefference_service/shared_pref.dart';

class UserNotificationController extends GetxController {
  final RxInt selectNotificationListIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isMarkingRead = false.obs;
  final RxInt page = 1.obs;
  final int limit = 10;
  bool hasMore = true;

  final RxList<Notification1Model> notificationList =
      <Notification1Model>[].obs;

  final notificationTabs = ["Notification", "Promotion"];

  @override
  void onInit() {
    super.onInit();
    debugPrint("Controller initialized");
    fetchNotifications();
  }

  /// ================= FETCH =================
  Future<void> fetchNotifications({bool loadMore = false}) async {
    if (isLoading.value || (!hasMore && loadMore)) return;

    isLoading.value = true;

    try {
      if (loadMore) {
        page.value++;
      } else {
        page.value = 1;
        hasMore = true;
        notificationList.clear();
      }

      final token = await SharedPreferencesHelper.getAccessToken();
      final currentUserId = await SharedPreferencesHelper.getOrExtractUserId();

      if (token == null || token.isEmpty) {
        EasyLoading.showError('Token not found');
        return;
      }

      final category = selectedCategory;

      final uri = Uri.parse(
        "${ApiEndPoint.notification}"
        "?category=$category"
        "&page=${page.value}"
        "&limit=$limit",
      );

      final response = await AppHttpClient.get(
        uri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List list = decoded['data']?['data'] ?? [];
        final items = list
            .map((e) {
              final map = Map<String, dynamic>.from(e as Map);
              map['_current_user_id'] = currentUserId;
              return Notification1Model.fromJson(map);
            })
            .where((item) => item.isActive)
            .toList();

        final int total = decoded['data']?['total'] ?? 0;
        hasMore = page.value * limit < total;

        notificationList.addAll(items);
      } else {
        if (loadMore) page.value--;
        EasyLoading.showError('Failed (${response.statusCode})');
      }
    } catch (e, s) {
      if (loadMore) page.value--;
      EasyLoading.showError(e.toString());
      debugPrint("Exception in fetchNotifications: $e\nStackTrace: $s");
    } finally {
      isLoading.value = false;
    }
  }

  String get selectedCategory =>
      selectNotificationListIndex.value == 0 ? 'NOTIFICATION' : 'PROMOTION';

  /// ================= CHANGE TAB =================
  void changeTab(int index) {
    if (selectNotificationListIndex.value != index) {
      selectNotificationListIndex.value = index;
      fetchNotifications();
    }
  }

  Future<void> onNotificationTap(Notification1Model item) async {
    if (!item.isRead && !isMarkingRead.value) {
      await markAsRead(item.id);
    }

    if (item.category.toUpperCase() == 'PROMOTION') {
      Get.to(() => PromotionDetailsScreen(item: item));
      return;
    }

    switch (item.type.toUpperCase()) {
      case 'FUNDS_FAILURE':
      case 'FUNDS_CREDITED':
        Get.to(() => UserMyWallet());
        return;
      case 'COIN_CREDITED':
      case 'COIN_REDEEMED':
        Get.to(() => const LoyaltyAndRewardsScreen());
        return;
      case 'ORDER_UPDATE':
        if ((item.orderId ?? '').isEmpty) {
          EasyLoading.showInfo('Order details not available');
          return;
        }

        Get.to(
          () => ActiveOrderDetailsScreen(order: _buildNotificationOrder(item)),
        );
        return;
      case 'DISPUTE_RESOLVED':
        Get.to(() => const DisputeScreen());
        return;
      case 'NEW_MESSAGE':
        if ((item.orderId ?? '').isEmpty) {
          EasyLoading.showInfo('Order details not available');
          return;
        }

        final ordId = int.tryParse(item.orderId!);
        if (ordId == null) {
          EasyLoading.showInfo('Invalid order ID');
          return;
        }

        EasyLoading.show(status: 'Loading chat...');
        try {
          final response = await GetOrderApiService.fetchOrderDetails(ordId);
          if (response['success'] == true && response['data'] != null) {
            final order = OrderModel.fromJson(response['data']);
            if (order.assignRiderUserId == null) {
              EasyLoading.showError('Rider not assigned');
              return;
            }
            Get.to(
              () => const ChatScreen(),
              arguments: {
                "receiverId": order.assignRiderUserId.toString(),
                "senderName": order.assignRiderName,
                "orderId": order.orderId,
                "totalCost": order.total.toStringAsFixed(2),
                "vehicleType": order.vehicleType,
                "assignRiderPhone": order.assignRiderPhone,
              },
            );
          } else {
            EasyLoading.showError('Failed to fetch order details');
          }
        } catch (e) {
          EasyLoading.showError('An error occurred');
          debugPrint('Error on notification tap: $e');
        } finally {
          EasyLoading.dismiss();
        }
        return;
      default:
        return;
    }
  }

  OrderModel _buildNotificationOrder(Notification1Model item) {
    return OrderModel(
      orderId: item.orderId ?? '',
      status: item.title,
      date: item.date,
      pickupAddress: '',
      senderName: '',
      dropOffAddress: '',
      deliveryLocation: '',
      vehicleType: '',
      total: 0,
      showReceipt: false,
      scheduledTime: '',
      createdAt: '',
      updatedAt: '',
      paymentType: '',
      routeType: '',
    );
  }

  Future<void> markAsRead(String notificationId) async {
    isMarkingRead.value = true;
    try {
      debugPrint("markAsRead called for notificationId: $notificationId");
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError('Token not found');
        debugPrint("markAsRead aborted: token not found");
        return;
      }

      final uri = Uri.parse(ApiEndPoint.notificationMarkAsRead(notificationId));
      debugPrint("markAsRead PATCH URL: $uri");

      final response = await AppHttpClient.patch(
        uri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );
      debugPrint(
        "markAsRead response -> status: ${response.statusCode}, body: ${response.body}",
      );

      if (response.statusCode == 200) {
        final index = notificationList.indexWhere(
          (element) => element.id == notificationId,
        );
        if (index != -1) {
          notificationList[index] = notificationList[index].copyWith(
            isRead: true,
          );
          notificationList.refresh();
        }
      }
    } catch (e) {
      debugPrint("Error marking as read: $e");
    } finally {
      isMarkingRead.value = false;
    }
  }

  /// ================= CONFIRM DELETE =================
  void confirmDelete(String notificationID) {
    debugPrint("Confirm delete called for ID: $notificationID");

    Get.defaultDialog(
      title: "Delete Notification",
      middleText: "Are you sure you want to delete this notification?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Get.theme.colorScheme.onPrimary,
      onConfirm: () {
        Get.back();
        debugPrint("User confirmed delete for ID: $notificationID");
        deleteNotification(notificationID);
      },
    );
  }

  /// ================= DELETE API =================
  Future<void> deleteNotification(String notificationID) async {
    debugPrint("Delete notification called for ID: $notificationID");

    try {
      EasyLoading.show(status: "Deleting...");
      debugPrint("EasyLoading shown");

      final token = await SharedPreferencesHelper.getAccessToken();
      debugPrint("Token fetched for delete: $token");

      if (token == null || token.isEmpty) {
        EasyLoading.showError("Token not found");
        debugPrint("Token not found, exiting delete");
        return;
      }

      final uri = Uri.parse(
        ApiEndPoint.deleteNotificationById(notificationID),
      );

      debugPrint("DELETE request URL: $uri");

      final response = await AppHttpClient.delete(
        uri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      debugPrint(
        "DELETE response. Status: ${response.statusCode}, Body: ${response.body}",
      );

      final responseBody = response.body.isNotEmpty
          ? json.decode(response.body) as Map<String, dynamic>
          : null;
      final requestSucceeded =
          response.statusCode == 200 ||
          response.statusCode == 204 ||
          responseBody?['success'] == true;

      if (requestSucceeded) {
        notificationList.removeWhere((element) => element.id == notificationID);
        EasyLoading.showSuccess("Deleted successfully");
        debugPrint("Notification removed from list: $notificationID");
      } else {
        final errorMessage =
            responseBody?['message']?.toString() ??
            "Delete failed (${response.statusCode})";
        EasyLoading.showError(errorMessage);
        debugPrint("Delete failed with status: ${response.statusCode}");
      }
    } catch (e, s) {
      EasyLoading.showError(e.toString());
      debugPrint("Exception in deleteNotification: $e\nStackTrace: $s");
    } finally {
      EasyLoading.dismiss();
      debugPrint("EasyLoading dismissed after delete");
    }
  }
}
