import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widget/custom_toggle_switch_widget.dart';
import '../widget/order_confirmation_dialog.dart';
import '../widget/order_success_widget.dart';
import '../widget/payment_method_widget.dart';
import '../widget/promo_dialog_widget.dart';

class StackedOrderControllerScreen extends GetxController {
  double totalAmount = 0.00;

  RxBool redeemCoins = false.obs;
  RxBool favoriteRiders = false.obs;

  void showConfirmationDialog() {
    final String formattedTotal = "S\$${totalAmount.toStringAsFixed(2)}";

    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.all(10), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: Get.width, 
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Order",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 22),

                Row(
                  children: [
                    Image.asset(IconPath.promo, height: 24, width: 24),
                    SizedBox(width: 8),
                    Text(
                      'Promo Code',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Get.dialog(
                          AlertDialog(
                            insetPadding: EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.amber, width: 2),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  "Promo Code",
                                  style: getTextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Spacer(),
                                InkWell(
                                  onTap: () => Get.back(),
                                  child: Icon(
                                    Icons.cancel_outlined,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            content: Builder(
                              builder: (context) {
                                final width =
                                    MediaQuery.of(context).size.width *
                                    0.8; // device width er 50%
                                return SizedBox(
                                  width: width,
                                  child: StackedPromoDialogContent(),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 130,
                        height: 27,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "Enter code",
                          style: getTextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // ---------- REDEEM COINS ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Redeem 10 Coins',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Obx(
                      () => StackedCustomToggleSwitch(
                        value: redeemCoins.value,
                        onChanged: (val) => redeemCoins.value = val,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // ---------- FAVOURITE RIDERS ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Favourite Riders ',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Obx(
                      () => StackedCustomToggleSwitch(
                        value: favoriteRiders.value,
                        onChanged: (val) => favoriteRiders.value = val,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 31),

                // ---------- SUBTOTAL ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal:',
                      style: getTextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'S\$45',
                      style: getTextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Coin/s redeemed:',
                      style: getTextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '-S\$00',
                      style: getTextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Divider(),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saved:',
                      style: getTextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '-S\$00',
                      style: getTextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                _buildDetailRow("Total Amount:", formattedTotal, isTotal: true),
                SizedBox(height: 30),

                // ---------- PAYMENT METHOD ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payment Method:',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    StackedPaymentMethodSelector(
                      orderAmount: totalAmount,
                      options: [
                        StackedPaymentOption(
                          title: "Stripe",
                          subtitle: "Instant payment",
                          imageAsset: IconPath.stripe,
                        ),
                        StackedPaymentOption(
                          title: "Wallet",
                          subtitle: "\$10.50",
                          imageAsset: IconPath.wallet,
                        ),
                        StackedPaymentOption(
                          title: "Cash",
                          subtitle: "To be paid by sender or receipent",
                          imageAsset: IconPath.cash,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 44),

                // ---------- BUTTONS ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FilledButton(
                      onPressed: () => Get.back(),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: BorderSide(color: Colors.red, width: 1.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Cancel order',
                            style: getTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(width: 3),
                          Image.asset(IconPath.cancel, height: 14, width: 14),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () async {
                        Get.back();
                        StackedOrderConfirmationDialog.show();
                        await Future.delayed(Duration(seconds: 3));
                        Get.back();
                        StackedOrderSuccessDialog.show();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'Review Order',
                        style: getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- HELPER METHOD ----------
Widget _buildDetailRow(String title, String value, {bool isTotal = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: getTextStyle(
          fontSize: isTotal ? 16 : 12,
          fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: getTextStyle(
          fontSize: isTotal ? 16 : 12,
          fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    ],
  );
}
