import 'dart:async';
import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/bottom_navbar/screen/bottom_navbar_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RedeemSuccessController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(seconds: 2), () {
      Get.to(() => BottomNavbarScreen());
    });
  }
}

class RedeemSuccessScreen extends StatelessWidget {
  const RedeemSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RedeemSuccessController());
    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroungColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              "Credits successfully redeemed to\n your wallet",
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontSize: 17,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
