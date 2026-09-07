import 'package:ZipBee/features/user/wallet/loyalty_and_rewards/screen/loyalty_and_rewards_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/common/styles/global_text_style.dart';
import '../../../../../core/common/widgets/custom_app_bar_user.dart';
import '../../../../../core/utils/constants/app_colors.dart';
import '../../../../../routes/app_routes.dart';
import '../../../home/controller/profile_controller.dart';
import '../controller/user_my_wallet_controller.dart';

class MyWalletUpperSection extends StatelessWidget {
  MyWalletUpperSection({super.key, required this.controller});

  final UserMyWalletController controller;
  final UserProfileController profileCtrl = Get.put(UserProfileController());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 26),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF5),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          CustomAppBarUser(
            title: "My Wallet",
            onTap: () => Get.offNamed(AppRoutes.bottomNavbarScreen),
            style: getTextStyle(),
          ),
          const SizedBox(height: 16),
          const Text("Current Balance"),
          Obx(
            () => Text(
              "\$${profileCtrl.walletBalance.value.toStringAsFixed(2)}",
              style: getTextStyle(fontSize: 32, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Obx(
              () => Row(
                children: [
                  walletButton(
                    title: "Add Funds",
                    selected: controller.selectFundsOrRedeen.value == 0,
                    onTap: () async {
                      controller.selectFundsOrRedeen.value = 0;
                      await Get.toNamed(AppRoutes.getuserAddFund());
                      await controller.loadProfileAndWallet();
                    },
                  ),
                  const SizedBox(width: 20),
                  walletButton(
                    title: "Redeem Coins",
                    selected: controller.selectFundsOrRedeen.value == 1,
                    onTap: () async {
                      controller.selectFundsOrRedeen.value = 1;
                      await Get.to(LoyaltyAndRewardsScreen());
                      await controller.loadProfileAndWallet();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget walletButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryButtonColor
                : const Color(0xFFFFFAE6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: getTextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.black : Colors.brown,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
