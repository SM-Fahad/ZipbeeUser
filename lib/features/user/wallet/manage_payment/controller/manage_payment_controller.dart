import 'package:flutter/material.dart';
import 'package:ZipBee/features/user/wallet/manage_payment/service/wallet_payment_method_service.dart';
import 'package:ZipBee/features/user/wallet/manage_payment/model/payment_card_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:ZipBee/core/constants/stripe_keys.dart';

class ManagePaymentController extends GetxController {
  /// Loading State
  RxBool isAddingCard = false.obs;
  RxBool isFetchingCards = false.obs;
  RxInt deletingCardId = 0.obs;

  /// Card State
  RxBool hasCard = false.obs;
  RxString last4 = "".obs;
  RxString defaultStripeMethodId = "".obs;
  RxList<PaymentCardModel> savedCards = <PaymentCardModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initStripe();
    fetchSavedCard();
  }

  /// ===============================
  /// INIT STRIPE
  /// ===============================
  void _initStripe() {
    Stripe.publishableKey = StripeKeys.stripePublicKey;
    Stripe.instance.applySettings();
  }

  /// ===============================
  /// FETCH SAVED CARD FROM BACKEND
  /// ===============================
  Future<void> fetchSavedCard() async {
    try {
      isFetchingCards.value = true;
      final result = await WalletPaymentMethodService.getSavedCards();

      if (result['success'] == true && result['body'] is List) {
        final cards = (result['body'] as List)
            .whereType<Map<String, dynamic>>()
            .map(PaymentCardModel.fromJson)
            .toList();

        savedCards.assignAll(cards);

        final PaymentCardModel? primaryCard =
            cards
                .where((card) => card.isDefault)
                .cast<PaymentCardModel?>()
                .firstOrNull ??
            cards.firstOrNull;

        hasCard.value = primaryCard != null;
        last4.value = primaryCard?.last4 ?? "";
        defaultStripeMethodId.value = primaryCard?.stripeMethodId ?? "";
      } else {
        _clearCardState();
      }
    } catch (e) {
      _clearCardState();
    } finally {
      isFetchingCards.value = false;
    }
  }

  Future<void> refreshScreen() async {
    await fetchSavedCard();
  }

  void _clearCardState() {
    savedCards.clear();
    hasCard.value = false;
    last4.value = "";
    defaultStripeMethodId.value = "";
  }

  /// ===============================
  /// ADD NEW CARD
  /// ===============================
  Future<bool> onAddPayment() async {
    if (isAddingCard.value) return false;

    try {
      isAddingCard.value = true;
      EasyLoading.show(status: "Preparing payment method...");

      // Ensure Stripe publishable key is configured
      final pubKey = StripeKeys.stripePublicKey;
      if (pubKey.isNotEmpty) {
        Stripe.publishableKey = pubKey;
        await Stripe.instance.applySettings();
      }

      /// 1️⃣ Create SetupIntent
      final setupResult = await WalletPaymentMethodService.createSetupIntent();

      if (setupResult['success'] != true) {
        EasyLoading.dismiss();
        EasyLoading.showError(
          setupResult['body']?['message']?.toString() ?? "Setup failed",
        );
        return false;
      }

      final String? clientSecret = setupResult['body']?['clientSecret'] ??
          setupResult['body']?['data']?['clientSecret'];

      if (clientSecret == null || clientSecret.isEmpty) {
        EasyLoading.dismiss();
        EasyLoading.showError("Invalid client secret");
        return false;
      }

      debugPrint(
        "➡️ Client secret received: ${clientSecret.substring(0, 15)}...",
      );

      /// 2️⃣ Init PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: clientSecret,
          merchantDisplayName: StripeKeys.merchantDisplayName,
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(primary: Colors.amber),
          ),
        ),
      );

      EasyLoading.dismiss();

      /// 3️⃣ Show PaymentSheet
      debugPrint("➡️ Presenting Stripe Payment Sheet");
      await Stripe.instance.presentPaymentSheet();
      debugPrint("✅ Stripe Payment Sheet completed");

      /// 4️⃣ Retrieve SetupIntent
      final setupIntent = await Stripe.instance.retrieveSetupIntent(
        clientSecret,
      );

      final paymentMethodId = setupIntent.paymentMethodId;

      if (paymentMethodId.isEmpty) {
        EasyLoading.showError("Payment method not found");
        return false;
      }

      debugPrint("➡️ Saving card paymentMethodId: $paymentMethodId");

      /// 5️⃣ Save Card to Backend
      final result = await WalletPaymentMethodService.saveCard(
        paymentMethodId: paymentMethodId,
      );

      if (result['success'] != true) {
        EasyLoading.showError(
          result['body']?['message'] ?? "Failed to save card",
        );
        return false;
      }

      await fetchSavedCard();
      EasyLoading.showSuccess("Card added successfully");
      return true;
    } on StripeException catch (e) {
      EasyLoading.dismiss();
      if (e.error.code == FailureCode.Canceled) {
        debugPrint("⚠️ Stripe setup cancelled by user");
        EasyLoading.showInfo("Card setup cancelled");
      } else {
        debugPrint("❌ Stripe Exception: ${e.error.localizedMessage}");
        EasyLoading.showError(e.error.localizedMessage ?? "Payment cancelled");
      }
      return false;
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint("❌ Error in onAddPayment: $e");
      EasyLoading.showError("Something went wrong");
      return false;
    } finally {
      isAddingCard.value = false;
    }
  }

  Future<void> deleteCard(PaymentCardModel card) async {
    if (deletingCardId.value == card.id) return;

    try {
      deletingCardId.value = card.id;
      EasyLoading.show(status: "Deleting card...");

      final result = await WalletPaymentMethodService.deleteSavedCard(card.id);

      if (result['success'] != true) {
        EasyLoading.showError(
          result['body']?['message'] ?? "Failed to delete card",
        );
        return;
      }

      await fetchSavedCard();
      EasyLoading.showSuccess(
        result['body']?['message']?.toString() ?? "Card deleted successfully",
      );
    } catch (e) {
      EasyLoading.showError("Failed to delete card");
    } finally {
      deletingCardId.value = 0;
      EasyLoading.dismiss();
    }
  }

  /// ===============================
  /// STRIPE TILE TAP
  /// ===============================
  void onStripeTap() {
    if (!hasCard.value) {
      onAddPayment();
    }
  }
}
