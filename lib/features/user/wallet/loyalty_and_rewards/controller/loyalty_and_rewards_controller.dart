import 'dart:convert';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:ZipBee/features/user/wallet/loyalty_and_rewards/widget/redeem_bottom_shit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LoyaltyAndRewardsController extends GetxController {
  RxInt coin = 0.obs;
  RxDouble dollarValue = 0.0.obs;
  RxList<Map<String, dynamic>> history = <Map<String, dynamic>>[].obs;
  RxBool isHistoryLoading = false.obs;

  int totalCoinForBasePrice = 120;
  double basePrice = 0.0;
  String? userId;

  /// ================= AUTH HEADER =================
  Future<Map<String, String>> _getAuthHeader() async {
    final token = await SharedPreferencesHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  /// ================= LOAD USER POINTS =================
  Future<void> loadUserCoin() async {
    try {
      final headers = await _getAuthHeader();

      final response = await http.get(
        Uri.parse(ApiEndPoint.profile),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];

        userId = data?['id']?.toString();
        coin.value =
            int.tryParse(data?['current_coin_balance']?.toString() ?? '0') ?? 0;

        calculateDollarValue();
        await loadCoinHistory();
      }
    } catch (e) {
      debugPrint("Coin load error: $e");
    }
  }

  Future<void> loadCoinHistory() async {
    try {
      final resolvedUserId =
          userId ?? await SharedPreferencesHelper.getOrExtractUserId();

      if (resolvedUserId == null || resolvedUserId.isEmpty) {
        history.clear();
        return;
      }

      userId = resolvedUserId;
      isHistoryLoading.value = true;

      final headers = await _getAuthHeader();
      final response = await http.get(
        Uri.parse(ApiEndPoint.coinAccHistory(resolvedUserId)),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body['data'] ?? [];

        history.assignAll(
          data.map((item) {
            final record = Map<String, dynamic>.from(item as Map);
            final role = record['role_triggered']?.toString() ?? 'UNKNOWN';
            final type = record['type']?.toString() ?? '';
            final amount =
                int.tryParse(record['coin_acc_amount']?.toString() ?? '0') ?? 0;

            return {
              ...record,
              'title': _formatRole(role),
              'subtitle': _formatType(type, amount),
              'formattedDate': _formatDate(record['created_at']?.toString()),
              'signedAmount': _signedAmount(type, amount),
              'isRedeem': type.toUpperCase() == 'APPLICATION',
            };
          }).toList(),
        );
      } else {
        history.clear();
        debugPrint("Coin history failed: ${response.body}");
      }
    } catch (e) {
      history.clear();
      debugPrint("Coin history error: $e");
    } finally {
      isHistoryLoading.value = false;
    }
  }

  /// ================= FETCH BASE PRICE =================
  Future<void> fetchCoinBasePrice() async {
    try {
      final headers = await _getAuthHeader();

      final response = await http.get(
        Uri.parse(ApiEndPoint.coinBasePrice),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          basePrice = double.tryParse(data['data']?.toString() ?? '0') ?? 0.0;

          calculateDollarValue();
        }
      }
    } catch (e) {
      debugPrint("Base price error: $e");
    }
  }

  /// ================= CALCULATE VALUE =================
  void calculateDollarValue() {
    if (totalCoinForBasePrice > 0 && basePrice > 0) {
      dollarValue.value = (coin.value / totalCoinForBasePrice) * basePrice;
    } else {
      dollarValue.value = 0.0;
    }
  }

  /// ================= REDEEM =================
  Future<void> redeemCoin(int coinToRedeem) async {
    // coin balance 0
    if (coinToRedeem <= 0) {
      EasyLoading.showInfo('No coin to redeem');
      return;
    }

    try {
      EasyLoading.show(status: 'Redeeming...');

      final headers = await _getAuthHeader();

      final response = await http.post(
        Uri.parse('${ApiEndPoint.redeemCoin}?coin=$coinToRedeem'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint('Redeem Coin api response: $data');

        if (data['success'] == true) {
          coin.value -= coinToRedeem;
          calculateDollarValue();
          await loadCoinHistory();
          EasyLoading.showSuccess(data['message'] ?? 'Points redeemed!');
        } else {
          EasyLoading.showError(data['message'] ?? 'Redeem failed');
        }
      } else {
        final data = jsonDecode(response.body);
        EasyLoading.showError(
          data['message'] ?? 'Error ${response.statusCode}',
        );
      }
    } catch (e) {
      EasyLoading.showError('Redeem error: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// ================= UI METHODS =================
  void onBack() => Get.back();

  void showRedeemBottomSheet() {
    Get.bottomSheet(
      RedeemBottomSheet(
        onRedeem: () {
          Get.back();
          redeemCoin(coin.value);
        },
        onCancel: () => Get.back(),
      ),
      isScrollControlled: true,
    );
  }

  void onInfoTap() {
    EasyLoading.showInfo('Loyalty & Rewards Information');
  }

  String _formatRole(String value) {
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _formatType(String type, int amount) {
    final normalized = type.toUpperCase();
    if (normalized == 'APPLICATION') {
      return 'Redeemed $amount coins';
    }
    if (normalized == 'ACCUMULATION') {
      return 'Earned $amount coins';
    }
    return '$amount coins';
  }

  String _signedAmount(String type, int amount) {
    final normalized = type.toUpperCase();
    final prefix = normalized == 'APPLICATION' ? '-' : '+';
    return '$prefix$amount';
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';

    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;

    return DateFormat('dd MMM yyyy, hh:mm a').format(parsed.toLocal());
  }

  @override
  void onInit() {
    super.onInit();
    loadUserCoin();
    fetchCoinBasePrice();
  }
}
