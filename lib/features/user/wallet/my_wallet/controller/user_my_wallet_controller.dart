import 'dart:convert';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/shared_prefference_service/shared_pref.dart';
import '../../../home/controller/profile_controller.dart';

class UserMyWalletController extends GetxController with WidgetsBindingObserver {
  final UserProfileController profileCtrl = Get.put(UserProfileController());
  var selectFundsOrRedeen = 0.obs;
  var isLoading = false.obs;

  RxDouble currentBalance = 0.0.obs;
  var recentTransactionList = <Map<String, dynamic>>[].obs;
  var showAllTransactions = false.obs;

  String? userId;
  bool _isProfileAndWalletLoading = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadProfileAndWallet();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadProfileAndWallet();
    }
  }

  /// ================= PROFILE + BALANCE =================
  Future<void> loadProfileAndWallet() async {
    if (_isProfileAndWalletLoading) return;

    try {
      _isProfileAndWalletLoading = true;
      isLoading.value = true;

      final token = await SharedPreferencesHelper.getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse(ApiEndPoint.profile),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];

        userId = data?['id']?.toString();

        final balance =
            double.tryParse(data?['currentWalletBalance']?.toString() ?? '0') ??
                0.0;
        currentBalance.value = balance;
        profileCtrl.walletBalance.value = balance;
        profileCtrl.availablePoints.value = int.tryParse(data?['current_coin_balance']?.toString() ?? '0') ?? 0;

        await loadWalletHistory();
      } else {
        debugPrint("Profile failed: ${response.body}");
      }
    } catch (e) {
      debugPrint("Profile error: $e");
    } finally {
      _isProfileAndWalletLoading = false;
      isLoading.value = false;
    }
  }

  bool _isRouteListenerRegistered = false;

  void registerRouteListener(BuildContext context) {
    if (_isRouteListenerRegistered) return;

    final route = ModalRoute.of(context);
    if (route != null) {
      _isRouteListenerRegistered = true;
      route.secondaryAnimation?.addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          debugPrint("UserMyWallet: Popped back to this screen! Reloading...");
          loadProfileAndWallet();
        }
      });
    }
  }

  /// ================= WALLET HISTORY =================
  Future<void> loadWalletHistory({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getToken();
      if (token == null || userId == null) return;

      isLoading.value = true;

      /// 🔥 FIXED PART HERE
      String baseUrl = ApiEndPoint.walletHistory.replaceAll(
        "{userId}",
        userId!,
      );

      String url = "$baseUrl?page=$page&limit=$limit";

      if (type != null) {
        url += "&type=$type";
      }

      debugPrint("Wallet URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> dataList = body['data'] ?? [];

        recentTransactionList.clear();
        showAllTransactions.value = false;

        for (var item in dataList) {
          final isCredit = item['type']?.toString().toLowerCase() == "credit";

          recentTransactionList.add({
            "title": item['transactionType'] ?? "Transaction",
            "orderId": item['transactionId'] ?? "",
            "message": item['message'],
            "amount": "${isCredit ? "+" : "-"} ${item['amount'] ?? "0"}",
            "isCredit": isCredit,
            "status": item['status'] ?? "",
            "createdAt": item['createdAt'] ?? "",
          });
        }

        debugPrint("Transactions loaded: ${recentTransactionList.length}");
      } else {
        debugPrint("Wallet history failed: ${response.body}");
      }
    } catch (e) {
      debugPrint("Wallet history error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
