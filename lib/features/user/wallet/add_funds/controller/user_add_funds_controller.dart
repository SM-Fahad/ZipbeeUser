import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:ZipBee/core/constants/stripe_keys.dart';
import 'package:ZipBee/features/user/wallet/add_funds/service/preset_amounts_cache_service.dart';
import 'package:ZipBee/features/user/wallet/add_funds/service/add_funds_payment_service.dart';
import 'package:ZipBee/features/user/wallet/add_payment_method/service/wallet_payment_service.dart';
import 'package:ZipBee/features/user/wallet/manage_payment/model/payment_card_model.dart';
import 'package:ZipBee/features/user/wallet/manage_payment/service/wallet_payment_method_service.dart';

class UserAddFundsController extends GetxController {
  final RxList<double> presetAmounts = <double>[10, 20, 40, 100].obs;
  final RxInt selectedIndex = 0.obs;

  final TextEditingController customAmountController = TextEditingController();
  final RxDouble selectedAmount = 10.0.obs;

  final RxBool isStripeSelected = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isAddingPaymentMethod = false.obs;
  final RxBool isFetchingCards = false.obs;
  final RxBool showPaymentMethodForm = false.obs;

  /// 🔹 Saved Cards State
  final RxList<PaymentCardModel> savedCards = <PaymentCardModel>[].obs;
  final RxString selectedStripeMethodId = ''.obs;
  final RxInt selectedCardId = 0.obs;

  bool get isAddButtonEnabled =>
      selectedAmount.value > 0 &&
      isStripeSelected.value &&
      selectedStripeMethodId.value.isNotEmpty;

  bool get hasSavedCard => savedCards.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    Stripe.publishableKey = StripeKeys.stripePublicKey;
    _loadCachedPresetAmounts();
    fetchSavedCards();
  }

  // ================= LOAD CACHE =================

  Future<void> _loadCachedPresetAmounts() async {
    final cached = await PresetAmountsCacheService.getCachedAmounts();
    presetAmounts.assignAll(cached);

    if (cached.isNotEmpty) {
      selectedAmount.value = cached.first;
      selectedIndex.value = 0;
    }
  }

  // ================= PRESET =================

  void onPresetTap(int index) {
    selectedIndex.value = index;
    customAmountController.clear();
    selectedAmount.value = presetAmounts[index];
  }

  void onCustomAmountChanged(String value) {
    selectedIndex.value = -1;
    selectedAmount.value = double.tryParse(value) ?? 0;
  }

  // ================= ADD TO CACHE =================

  Future<void> onAddToCache() async {
    final amount = double.tryParse(customAmountController.text) ?? 0;

    if (amount <= 0) {
      EasyLoading.showError("Enter valid amount");
      return;
    }

    await PresetAmountsCacheService.addAmount(amount);
    await _loadCachedPresetAmounts();

    customAmountController.clear();
    selectedIndex.value = presetAmounts.indexOf(amount);
    selectedAmount.value = amount;

    EasyLoading.showSuccess("Amount added");
  }

  // ================= STRIPE =================

  void onToggleStripe() {
    isStripeSelected.toggle();
  }

  void togglePaymentMethodForm() {
    showPaymentMethodForm.toggle();
  }

  Future<void> fetchSavedCards() async {
    try {
      isFetchingCards.value = true;
      final result = await WalletPaymentMethodService.getSavedCards();

      if (result['success'] == true && result['body'] is List) {
        final cards = (result['body'] as List)
            .whereType<Map<String, dynamic>>()
            .map(PaymentCardModel.fromJson)
            .toList();

        savedCards.assignAll(cards);

        final primaryCard =
            cards.where((card) => card.isDefault).firstOrNull ??
            cards.firstOrNull;

        if (primaryCard != null) {
          selectedCardId.value = primaryCard.id;
          selectedStripeMethodId.value = primaryCard.stripeMethodId;
          isStripeSelected.value = true;
        } else {
          selectedCardId.value = 0;
          selectedStripeMethodId.value = '';
        }
      } else {
        savedCards.clear();
        selectedCardId.value = 0;
        selectedStripeMethodId.value = '';
      }
    } catch (_) {
      savedCards.clear();
      selectedCardId.value = 0;
      selectedStripeMethodId.value = '';
    } finally {
      isFetchingCards.value = false;
    }
  }

  void selectSavedCard(PaymentCardModel card) {
    selectedCardId.value = card.id;
    selectedStripeMethodId.value = card.stripeMethodId;
    isStripeSelected.value = true;
  }

  // ================= ADD PAYMENT METHOD =================

  Future<void> addPaymentMethod() async {
    try {
      isAddingPaymentMethod.value = true;
      EasyLoading.show(status: 'Opening Stripe...');

      final setupResult = await WalletPaymentService.createSetupIntent();

      final clientSecret = setupResult['body']?['clientSecret'];

      if (clientSecret == null || clientSecret.isEmpty) {
        EasyLoading.dismiss();
        EasyLoading.showError("Invalid setup intent");
        return;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: clientSecret,
          merchantDisplayName: StripeKeys.merchantDisplayName,
          style: ThemeMode.light,
        ),
      );

      EasyLoading.dismiss();

      /// 🔥 Show Stripe bottom sheet
      await Stripe.instance.presentPaymentSheet();

      /// 🔥 Get SetupIntent result
      final setupIntent = await Stripe.instance.retrieveSetupIntent(
        clientSecret,
      );

      final paymentMethodId = setupIntent.paymentMethodId;

      if (paymentMethodId.isEmpty) {
        EasyLoading.showError("Failed to get payment method");
        return;
      }

      /// 🔥 Save card to backend
      final saveResult = await WalletPaymentService.saveCard(
        paymentMethodId: paymentMethodId,
        cardHolderName: null,
        lastFourDigits: null,
        cardBrand: null,
      );

      if (!saveResult['success']) {
        EasyLoading.showError("Failed to save card");
        return;
      }

      await fetchSavedCards();
      showPaymentMethodForm.value = false;

      EasyLoading.showSuccess("Card added successfully");
    } catch (e) {
      EasyLoading.showError("Stripe error: $e");
    } finally {
      isAddingPaymentMethod.value = false;
    }
  }

  // ================= ADD FUNDS =================

  Future<void> onAddFunds() async {
    if (!isAddButtonEnabled) {
      EasyLoading.showError("Select amount and card");
      return;
    }

    try {
      isLoading.value = true;
      EasyLoading.show(status: "Processing payment...");

      final response = await AddFundsPaymentService.addMoneyToWallet(
        amount: selectedAmount.value,
        paymentMethodId: selectedStripeMethodId.value,
      );

      if (response['success'] != true) {
        EasyLoading.dismiss();
        EasyLoading.showError(
          response['body']?['message']?.toString() ?? "Add fund failed",
        );
        return;
      }

      EasyLoading.dismiss();
      EasyLoading.showSuccess(
        response['body']?['message']?.toString() ?? "Funds added!",
      );

      await PresetAmountsCacheService.addAmount(selectedAmount.value);
      await _loadCachedPresetAmounts();

      Get.back();
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError("Payment failed");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    customAmountController.dispose();
    super.onClose();
  }
}
