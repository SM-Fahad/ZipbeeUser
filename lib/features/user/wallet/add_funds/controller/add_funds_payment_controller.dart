import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ZipBee/features/user/wallet/add_funds/service/add_funds_payment_service.dart';
import 'package:ZipBee/features/user/wallet/add_funds/service/preset_amounts_cache_service.dart';

class AddFundsPaymentController extends GetxController {
  final RxBool isLoading = false.obs;

  Future<void> processWalletTopUp({
    required double amount,
    required String paymentMethodId,
    required Function onPaymentSuccess,
  }) async {
    if (amount <= 0) {
      EasyLoading.showError('Please enter a valid amount');
      return;
    }

    isLoading.value = true;

    try {
      EasyLoading.show(status: 'Processing payment...');
      debugPrint('➡️ Initiating wallet top-up: \$${amount}');

      final response = await AddFundsPaymentService.addMoneyToWallet(
        amount: amount,
        paymentMethodId: paymentMethodId,
      );

      if (!response['success']) {
        EasyLoading.dismiss();
        EasyLoading.showError(
          response['body']?['message']?.toString() ?? 'Add fund failed',
        );
        return;
      }

      debugPrint('✅ Wallet top-up successful');
      await PresetAmountsCacheService.addAmount(amount);
      EasyLoading.dismiss();
      onPaymentSuccess();
    } catch (e) {
      debugPrint('❌ processWalletTopUp error: $e');
      EasyLoading.showError('Payment failed: $e');
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }
}
