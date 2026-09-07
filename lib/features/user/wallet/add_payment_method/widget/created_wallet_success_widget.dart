import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/wallet/my_wallet/screen/user_my_wallet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class CreatedWalletSuccessController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(seconds: 3), () {
      Get.to(() => UserMyWallet());
    });
  }
}

class CreatedWalletSuccessWidget extends StatelessWidget {
  const CreatedWalletSuccessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CreatedWalletSuccessController());
    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.white, size: 40),
            ),
            SizedBox(height: 20),

            Text(
              "You have successfully credited to your\n wallet",
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
