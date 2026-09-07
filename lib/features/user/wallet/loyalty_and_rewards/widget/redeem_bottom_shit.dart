import 'package:flutter/material.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';

class RedeemBottomSheet extends StatelessWidget {
  final VoidCallback? onRedeem;
  final VoidCallback? onCancel;

  const RedeemBottomSheet({super.key, this.onRedeem, this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Redeem Button
          GestureDetector(
            onTap: onRedeem,
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: AppColors.onboardingIndicatorActive,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "Redeem",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// Cancel Button
          GestureDetector(
            onTap: onCancel,
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: const Center(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 10),
        ],
      ),
    );
  }
}
