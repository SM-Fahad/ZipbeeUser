import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:ZipBee/core/constants/stripe_keys.dart';

class AddFundsStripePaymentHandler {
  static Future<bool> presentPaymentSheet({
    required String clientSecret, required double amount,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters:
            SetupPaymentSheetParameters(
          paymentIntentClientSecret:
              clientSecret,
          merchantDisplayName:
              StripeKeys.merchantDisplayName,
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      EasyLoading.showError(
          e.error.localizedMessage ??
              "Payment failed");
      return false;
    } catch (e) {
      EasyLoading.showError(
          "Payment failed");
      return false;
    }
  }

  static Future<dynamic> initializeStripe() async {}
}
