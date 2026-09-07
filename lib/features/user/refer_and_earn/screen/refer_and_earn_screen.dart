import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/common/widgets/custom_button.dart';
import 'package:ZipBee/features/user/refer_and_earn/controller/refer_and_earn_controller.dart';
import 'package:ZipBee/features/user/refer_and_earn/widget/refar_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:share_plus/share_plus.dart';
import '../../../../core/utils/constants/app_colors.dart';

class ReferAndEarnScreen extends StatelessWidget {
  ReferAndEarnScreen({super.key});

  final ReferAndEarnController ctrl = Get.put(ReferAndEarnController());

  @override
  Widget build(BuildContext context) {
    final padding = 20.0;

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Refer & Earn',
          style: getTextStyle(
            fontSize: 20,
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 6),
              Text(
                'Invite friends to and earn rewards for every\nsign-up',
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 18),

              // referral card
              ReferralCard(ctrl: ctrl),

              SizedBox(height: 22),

              GestureDetector(
                onTap: ctrl.openRewards,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Rewards',
                              style: getTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Track the rewards you have earned from\nsuccessful referrals',

                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[700]),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),

              GestureDetector(
                onTap: ctrl.openHowItWorks,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How It Works',
                              style: getTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Step-by-step explanation Of how our\nreferral program works',

                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[700]),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 110),
              // Invite friends button
              CustomButton(
                label: "Invite friends",
                onPressed: () {
                  final String message =
                      "Hey! Join this amazing app and earn rewards.\n\n"
                      "Use my referral link:\n${ctrl.referralLink.value}";

                  Share.share(message, subject: "Invite to our app");
                },
                color: AppColors.primaryButtonColor,
                textColor: AppColors.primaryFontColor,
              ),

              SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
