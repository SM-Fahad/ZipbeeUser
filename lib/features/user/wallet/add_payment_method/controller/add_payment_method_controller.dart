import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:ZipBee/core/constants/stripe_keys.dart';
import 'package:ZipBee/features/user/wallet/add_payment_method/service/wallet_payment_service.dart';

class AddPaymentMethodController extends GetxController {
  final String clientSecret;

  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();
  final nameController = TextEditingController();

  var isButtonEnabled = false.obs;
  var isProcessing = false.obs;

  AddPaymentMethodController({required this.clientSecret});

  @override
  void onInit() {
    cardNumberController.addListener(_validate);
    expiryController.addListener(_validate);
    cvvController.addListener(_validate);
    nameController.addListener(_validate);
    _initializeStripe();
    super.onInit();
  }

  /// Initialize Stripe with public key
  void _initializeStripe() {
    try {
      debugPrint('➡️ Initializing Stripe with public key');
      Stripe.publishableKey = StripeKeys.stripePublicKey;
      debugPrint('✅ Stripe initialized');
    } catch (e) {
      debugPrint('❌ Error initializing Stripe: $e');
    }
  }

  void _validate() {
    if (cardNumberController.text.length >= 8 &&
        expiryController.text.isNotEmpty &&
        cvvController.text.length >= 3 &&
        nameController.text.isNotEmpty) {
      isButtonEnabled.value = true;
    } else {
      isButtonEnabled.value = false;
    }
  }

  /// Save card with Stripe and API
  Future<void> saveCard() async {
    if (!isButtonEnabled.value) {
      EasyLoading.showError('Please fill all card details');
      return;
    }

    try {
      isProcessing.value = true;
      EasyLoading.show(status: 'Setting up payment method...');

      debugPrint('➡️ Step 1: Opening Stripe Payment Sheet');

      // Step 1: Initialize and present Stripe payment sheet
      // The clientSecret will be used by Stripe to create the payment method
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: clientSecret,
          merchantDisplayName: StripeKeys.merchantDisplayName,
          style: ThemeMode.light,
        ),
      );

      debugPrint('✅ Payment Sheet initialized');
      EasyLoading.dismiss();
      EasyLoading.show(status: 'Confirming payment method...');

      // Step 2: Present the payment sheet to user
      final result = await Stripe.instance.presentPaymentSheet();

      if (result == null) {
        debugPrint('❌ Payment sheet dismissed');
        EasyLoading.dismiss();
        EasyLoading.showError('Payment setup cancelled');
        isProcessing.value = false;
        return;
      }

      debugPrint('✅ Payment method created successfully');

      // Step 3: Get payment method details from Stripe response
      // Extract payment method info from Stripe
      final paymentMethod = await _extractPaymentMethodInfo();

      if (paymentMethod == null) {
        debugPrint('❌ Could not extract payment method info');
        EasyLoading.dismiss();
        EasyLoading.showError('Failed to retrieve payment method');
        isProcessing.value = false;
        return;
      }

      debugPrint('➡️ Step 2: Saving card to backend');
      debugPrint('Payment Method ID: ${paymentMethod['paymentMethodId']}');

      // Step 4: Save card to backend API
      final saveResult = await WalletPaymentService.saveCard(
        paymentMethodId: paymentMethod['paymentMethodId'],
        cardHolderName: nameController.text,
        lastFourDigits: paymentMethod['lastFourDigits'],
        cardBrand: paymentMethod['cardBrand'],
      );

      if (!saveResult['success']) {
        EasyLoading.dismiss();
        EasyLoading.showError(
          saveResult['body']['message'] ?? 'Failed to save card',
        );
        isProcessing.value = false;
        return;
      }

      debugPrint('✅ Card saved successfully');
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Payment method added successfully');

      // Delay and go back to previous screen
      await Future.delayed(Duration(seconds: 1));
      Get.back();
    } catch (e) {
      debugPrint('❌ Error in saveCard: $e');
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to save card: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  /// Extract payment method information from Stripe
  /// In a real implementation, this would be called from the backend
  /// after confirming the setup intent
  Future<Map<String, dynamic>?> _extractPaymentMethodInfo() async {
    try {
      // Note: In production, you would retrieve this from your backend
      // after confirming the SetupIntent. For now, we'll use a placeholder
      // The backend should return paymentMethodId after confirming the setup intent.
      
      // This is a temporary implementation - the backend will handle this
      return {
        'paymentMethodId': 'pm_placeholder', // Backend will provide actual ID
        'lastFourDigits': cardNumberController.text.substring(
          cardNumberController.text.length - 4,
        ),
        'cardBrand': _detectCardBrand(cardNumberController.text),
      };
    } catch (e) {
      debugPrint('Error extracting payment method info: $e');
      return null;
    }
  }

  /// Detect card brand from card number
  String _detectCardBrand(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'VISA';
    if (cardNumber.startsWith('5')) return 'MASTERCARD';
    if (cardNumber.startsWith('3')) return 'AMEX';
    return 'UNKNOWN';
  }

  @override
  void onClose() {
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    nameController.dispose();
    super.onClose();
  }
}
