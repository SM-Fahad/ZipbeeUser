import 'dart:convert';
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class OrderControllerExpress extends GetxController {
  final logger = Logger();

  // --- State Variables ---
  final redeemCoins = false.obs;
  final favoriteRiders = false.obs;
  final isLoading = false.obs;
  final lastOrderData = <String, dynamic>{}.obs;

  final promoController = TextEditingController();

  String get subtotal =>
      "S\$${double.tryParse(lastOrderData['total_fee']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}";
  String get redeemedAmount =>
      "-S\$${double.tryParse(lastOrderData['redeemed_coins']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}";
  String get totalAmount =>
      "S\$${double.tryParse(lastOrderData['total_cost']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}";

  void toggleRedeemCoins(bool value) {
    redeemCoins.value = value;
    redeemCoinApi();
  }

  void toggleFavoriteRiders(bool value) {
    favoriteRiders.value = value;
  }

  Future<void> fetchOrderById(int orderId) async {
    try {
      isLoading.value = true;
      final token = await SharedPreferencesHelper.getToken();

      final url = ApiEndPoint.orderEstimate.replaceAll(
        "{id}",
        orderId.toString(),
      );

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        lastOrderData.value = data['data'] ?? {};
        // ignore: invalid_use_of_protected_member
        logger.i("Fetched order: ${lastOrderData.value}");
      } else {
        logger.e("Fetch order API error: ${response.body}");
      }
    } catch (e) {
      logger.e("Fetch order exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> redeemCoinApi() async {
    try {
      isLoading.value = true;
      final token = await SharedPreferencesHelper.getToken();

      final body = {"redeem_coin": redeemCoins.value};
      final response = await http.post(
        Uri.parse(ApiEndPoint.redeemCoin),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        lastOrderData.value = data['data'];
        logger.i("Redeem coin response updated order data");
      }
    } catch (e) {
      logger.e("Redeem coin exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> confirmOrder(int orderId) async {
    try {
      isLoading.value = true;
      final token = await SharedPreferencesHelper.getToken();

      final response = await http.post(
        Uri.parse(ApiEndPoint.orderEstimate),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "redeem_coin": redeemCoins.value,
          "notify_favorite_raider": favoriteRiders.value,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        lastOrderData.value = data['data'] ?? {};
        logger.i("Order confirmed successfully");
        return true;
      } else {
        logger.e("Confirm order error: ${response.body}");
        return false;
      }
    } catch (e) {
      logger.e("Confirm order exception: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    promoController.dispose();
    super.onClose();
  }
}
