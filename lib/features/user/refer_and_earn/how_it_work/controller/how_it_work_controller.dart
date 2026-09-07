import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class HowItWorksController extends GetxController {
  void redeemCredits() {
    if (kDebugMode) {
      print("Credits redeemed to wallet!");
    }
  }
}
