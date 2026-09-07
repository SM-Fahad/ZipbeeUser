import 'package:ZipBee/core/common/widgets/custom_button.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/loyalty_and_rewards_controller.dart';

class LoyaltyAndRewardsScreen extends StatelessWidget {
  const LoyaltyAndRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoyaltyAndRewardsController(), permanent: false);

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              /// ================= TOP BAR =================
              Row(
                children: [
                  GestureDetector(
                    onTap: controller.onBack,
                    child: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  SizedBox(width: 100),
                  Text(
                    "Loyalty & Rewards",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              /// ================= POINTS BALANCE =================
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Your Coin Balance',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    /// POINTS
                    Obx(
                      () => Text(
                        controller.coin.value.toString(),
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 4),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  "Points Earning History",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// ================= HISTORY CARD =================
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Obx(() {
                      if (controller.isHistoryLoading.value) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (controller.history.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              "No history found",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: List.generate(controller.history.length, (
                          index,
                        ) {
                          final item = controller.history[index];
                          final isLast = index == controller.history.length - 1;
                          final isRedeem = item["isRedeem"] == true;

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item["title"] ?? "",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item["subtitle"] ?? "",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item["formattedDate"] ?? "",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "${item["signedAmount"] ?? ""} coins",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            isRedeem
                                                ? Colors.redAccent
                                                : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1,
                                ),
                            ],
                          );
                        }),
                      );
                    }),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "How It Works",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 10),

              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("• "),
                  Expanded(
                    child: Text(
                      "Each completed order earns 10 coins for every \$10 spent",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("• "),
                  Expanded(
                    child: Text(
                      "Earn coin on each order, which can be redeemed to your wallet as order credits",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

              // Spacer(),
              SizedBox(height: 40),

              CustomButton(
                label: 'Convert Coin',
                onPressed: controller.showRedeemBottomSheet,
                color: AppColors.onboardingIndicatorActive,
                textColor: Colors.black,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
