import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/refer_and_earn/how_it_work/controller/how_it_work_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HowItWorksController());

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroungColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "How it works",
          style: getTextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.black54),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "1. Share Your Referral Code or link",
              style: getTextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Invite your friends by sharing your unique referral link or code",
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 30),

            Text(
              "2. Friends Sign Up and Take Their First Order",
              style: getTextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "When a friend sign-up using your code and complete their first order, you both earn rewards",
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 30),

            Text(
              "3. Earn Order Credits",
              style: getTextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "For every successful referral, you receive 20 credits towards your next order. Your friend also receives 20 credits as a welcome bonus",
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Spacer(),

            // CustomButton(
            //   label: "Redeem credits to wallet",
            //   onPressed: () {
            //     Get.to(() => RedeemSuccessScreen());
            //   },
            //   color: AppColors.primaryButtonColor,
            //   textColor: AppColors.primaryFontColor,
            // ),
            SizedBox(height: 140),
          ],
        ),
      ),
    );
  }
}
