import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/common/widgets/custom_button.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/refer_and_earn/your_rewards/controller/your_rewards_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class YourRewardsScreen extends StatelessWidget {
  const YourRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final YourRewardsController ctrl = Get.put(
      YourRewardsController(
        initialCredits:
            Get.arguments != null && Get.arguments['totalCredits'] != null
            ? Get.arguments['totalCredits'] as int
            : 0,
        referCode:
            Get.arguments != null && Get.arguments['referralCode'] != null
            ? Get.arguments['referralCode'] as String
            : null,
        initialRewardMoney:
            Get.arguments != null && Get.arguments['rewardMoney'] != null
            ? Get.arguments['rewardMoney'] as int
            : 0,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroungColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Your Rewards",
          style: getTextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.info_outline, color: Colors.grey),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: Column(
          children: [
            SizedBox(height: 10),
            Obx(
              () => Column(
                children: [
                  Text(
                    'Total credits earned',
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${ctrl.totalCredits.value}',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '= \$${ctrl.rewardInDollar.toStringAsFixed(2)}',
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 6),
                  // Text(
                  //   '= \$${(ctrl.rewardMoney.value ).toStringAsFixed(2)}',
                  //   style: getTextStyle(
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.w600,
                  //     color: Colors.black54,
                  //   ),
                  // ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'For every successful referral, you receive 20 credits\n'
              'towards your next order',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Referral History',
                style: getTextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: ctrl.referralHistory.length,
                  itemBuilder: (context, index) {
                    final item = ctrl.referralHistory[index];
                    final isLast = index == ctrl.referralHistory.length - 1;

                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 26,
                              horizontal: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['username'] ?? '',
                                  style: getTextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'You earned on ${item['date'] ?? ''}',
                                  style: getTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Container(height: 1, color: Colors.grey.shade300),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 10),
            CustomButton(
              label: "Redeem credits to wallet",
              onPressed: () async {
                await ctrl.redeemCredits();
              },
              color: AppColors.primaryButtonColor,
              textColor: AppColors.primaryFontColor,
            ),
            SizedBox(height: 110),
          ],
        ),
      ),
    );
  }
}
