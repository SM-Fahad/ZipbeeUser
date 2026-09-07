import 'package:ZipBee/features/user/stacked/order_stacked_delivery/service/stripe_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:ZipBee/core/constants/stripe_keys.dart';

/// Stripe Payment Sheet Handler
/// Manages initialization and presentation of Stripe Payment Sheet
class StripePaymentSheetHandler {
  static String get _merchantDisplayName => StripeKeys.merchantDisplayName;
  static Map<String, dynamic>? paymentIntent;
  static double _orderAmount = 0.0;

  /// Initialize Stripe Payment Sheet with payment method
  /// Returns true if successful, false otherwise
  static Future<bool> initializePaymentSheet({
    String? publicKey,
    String? merchantDisplayName,
  }) async {
    debugPrint('➡️ Initializing Stripe with public key');
    try {
      // Use provided key or default to configured key
      final key = publicKey ?? StripeKeys.stripePublicKey;

      if (key.isEmpty) {
        debugPrint('❌ Stripe public key is empty');
        return false;
      }

      // Set the publishable key
      Stripe.publishableKey = key;
      debugPrint(
        '✅ Stripe initialized with public key: ${key.substring(0, 10)}...',
      );
      return true;
    } catch (e) {
      debugPrint('❌ Error initializing Stripe: $e');
      return false;
    }
  }

  /// Initialize and present Stripe payment sheet when Place Order is clicked
  static Future<String?> initiatePayment({
    required double amount,
    required int orderId,
  }) async {
    try {
      debugPrint('➡️ Step 1: Initiating Stripe payment for amount: \$$amount');
      _orderAmount = amount;

      EasyLoading.show(status: 'Getting payment details...');

      // Step 1: Get Client Secret from API
      debugPrint('➡️ Step 2: Calling Add Money API');
      debugPrint('➡️ Order ID for payment: $orderId');
      final response = await StripeService.addMoneyToWallet(
        amount: _orderAmount,
        currency: 'sgd',
        orderId: orderId,
      );

      debugPrint('✅ Add Money API Response: ${response['body']}');

      if (!response['success']) {
        debugPrint('❌ API Error: ${response['body']}');
        EasyLoading.showError('Failed to get payment details');
        return null;
      }

      final clientSecret = response['body']['data']?['clientSecret'];

      if (clientSecret == null || clientSecret.isEmpty) {
        debugPrint('❌ Client secret missing from response');
        EasyLoading.showError('Invalid payment response');
        return null;
      }

      debugPrint('✅ Client Secret obtained: $clientSecret');
      debugPrint('✅ Using Stripe Publishable Key: ${StripeKeys.stripePublicKey.substring(0, 20)}...');

      // Step 2: Initialize Payment Sheet
      debugPrint('➡️ Step 3: Initializing Payment Sheet');
      try {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: _merchantDisplayName,
            style: ThemeMode.light,
            appearance: PaymentSheetAppearance(
              colors: PaymentSheetAppearanceColors(primary: Colors.amber),
              shapes: PaymentSheetShape(borderRadius: 16),
            ),
          ),
        );
        debugPrint('✅ Payment Sheet initialized successfully');
      } catch (initError) {
        debugPrint('❌ Payment Sheet init error: $initError');
        EasyLoading.dismiss();
        EasyLoading.showError('Failed to initialize payment: $initError');
        return null;
      }

      EasyLoading.dismiss();

      // Step 3: Present Payment Sheet
      debugPrint('➡️ Step 4: Presenting Payment Sheet to user');
      EasyLoading.show(status: 'Opening payment sheet...');

      try {
        await Stripe.instance.presentPaymentSheet();
      } catch (e) {
        debugPrint('❌ Presentation error: $e');
        EasyLoading.dismiss();
        
        if (e.toString().contains('cancelled')) {
          debugPrint('⚠️ User cancelled payment');
          EasyLoading.showInfo('Payment cancelled');
        } else {
          EasyLoading.showError('Payment sheet error: $e');
        }
        return null;
      }

      debugPrint('✅ Payment Sheet presented and confirmed');
      EasyLoading.dismiss();

      // Step 4: Payment successful
      debugPrint('✅ Payment completed successfully');
      EasyLoading.showSuccess('Payment Successful!');

      // Return payment intent ID as payment method identifier
      final paymentIntentId = paymentIntent?['id'] ?? 'stripe_${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('✅ Payment Intent ID: $paymentIntentId');
      
      return paymentIntentId;
    } on StripeException catch (e) {
      debugPrint('❌ Stripe Exception: ${e.error.localizedMessage}');
      debugPrint('❌ Stripe Error Code: ${e.error.code}');
      debugPrint('❌ Stripe Error Details: ${e.error}');
      EasyLoading.dismiss();
      EasyLoading.showError('Payment failed: ${e.error.localizedMessage}');
      return null;
    } catch (e) {
      debugPrint('❌ Error: $e');
      debugPrint('❌ Error Type: ${e.runtimeType}');
      debugPrint('❌ Error Stacktrace: ${e.toString()}');
      EasyLoading.dismiss();

      if (e.toString().contains('cancelled')) {
        debugPrint('⚠️ User cancelled payment');
        EasyLoading.showInfo('Payment cancelled');
      } else {
        EasyLoading.showError('Payment failed: $e');
      }
      return null;
    }
  }

  /// Don't need processPayment anymore - use initiatePayment directly
}