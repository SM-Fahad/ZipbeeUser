import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/wallet/loyalty_and_rewards/screen/loyalty_and_rewards_screen.dart';
import 'package:ZipBee/features/user/wallet/manage_payment/screen/manage_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/user_my_wallet_controller.dart';
import '../widgets/my_wallet_upper_section.dart';

class UserMyWallet extends StatelessWidget {
  UserMyWallet({super.key});

  final controller = Get.put(UserMyWalletController());

  @override
  Widget build(BuildContext context) {
    controller.registerRouteListener(context);

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadProfileAndWallet,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                MyWalletUpperSection(controller: controller),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      rowItem(
                        "Manage Payment Methods",
                        onTap: () async {
                          await Get.to(ManagePaymentScreen());
                          await controller.loadProfileAndWallet();
                        },
                      ),
                      const Divider(),

                      rowItem(
                        "Loyalty & Rewards",
                        onTap: () async {
                          await Get.to(LoyaltyAndRewardsScreen());
                          await controller.loadProfileAndWallet();
                        },
                      ),

                      const SizedBox(height: 30),

                      Text(
                        "Wallet Recent Transactions",
                        style: getTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),

                      /// ================= TRANSACTION LIST =================
                      Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (controller.recentTransactionList.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text("No transactions found"),
                            ),
                          );
                        }

                        final totalTransactions =
                            controller.recentTransactionList.length;
                        final hasMoreThanFour = totalTransactions > 4;
                        final itemCount = hasMoreThanFour &&
                                !controller.showAllTransactions.value
                            ? 4
                            : totalTransactions;

                        return Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: itemCount,
                              itemBuilder: (_, index) {
                                final item =
                                    controller.recentTransactionList[index];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title'] ?? "",
                                            style: getTextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (item['message'] != null &&
                                              item['message']
                                                  .toString()
                                                  .trim()
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              item['message'].toString(),
                                              style: getTextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        item['amount'] ?? "",
                                        style: getTextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: item['isCredit'] == true
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            if (hasMoreThanFour)
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    controller.showAllTransactions.value =
                                        !controller.showAllTransactions.value;
                                  },
                                  child: Text(
                                    controller.showAllTransactions.value
                                        ? "See less"
                                        : "See more",
                                    style: getTextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryButtonColor,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget rowItem(String title, {Future<void> Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: getTextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.subtitleFontColor,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}
