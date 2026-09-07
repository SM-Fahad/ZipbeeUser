import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/express_delivery_1/controller/express_controller_1.dart';
import 'package:ZipBee/features/user/express_delivery_1/order_express_delivery/widget/custom_toggoe_switich_widget.dart';
import 'package:ZipBee/features/user/express_delivery_1/order_express_delivery/widget/order_confirmation_dialog.dart';
import 'package:ZipBee/features/user/express_delivery_1/order_express_delivery/widget/order_success_dialog.dart';
import 'package:ZipBee/features/user/express_delivery_1/order_express_delivery/widget/payment_method_widget.dart';
import 'package:ZipBee/features/user/stacked/show_order_confirmation/promoCode_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

/// Show order confirmation dialog (reusable)
void showOrderConfirmationDialog(
  ExpressDeliveryMain controller, {
  int orderId = 0,
}) {
  final String formattedTotal =
      "\$${controller.totalAmount.toStringAsFixed(2)}";

  final String savedAmount =
      "\$${controller.discountAmount.toStringAsFixed(2)}";

  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.symmetric(horizontal: 8),
      content: SingleChildScrollView(
        child: Container(
          width: Get.width * 0.95,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your Order",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 22),

              // Promo Code Row
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
                                  MediaQuery.of(context).size.width * 0.8;
                              return SizedBox(
                                width: width,
                                child: PromoDialog(orderId: orderId),
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
              SizedBox(height: 14),

              // Redeem Coins
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
                    () => GestureDetector(
                      onTap: () async {
                        if (!controller.redeemCoins.value) {
                          EasyLoading.show(status: 'Redeeming coins...');
                          await controller.redeemCoinsApi(
                            orderId: orderId,
                            coinsAmount: 10,
                          );
                          EasyLoading.dismiss();
                        }
                      },
                      child: CustomToggleSwitch(
                        value: controller.redeemCoins.value,
                        onChanged: (_) {
                          // Toggle handled in onTap above
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),

              // Favourite Riders
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Favourite Riders',
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Obx(
                    () => GestureDetector(
                      onTap: () async {
                        if (!controller.favoriteRiders.value) {
                          EasyLoading.show(status: 'Setting favorite rider...');
                          await controller.followFavoriteRider(
                            orderId: orderId,
                          );
                          EasyLoading.dismiss();
                        }
                      },
                      child: CustomToggleSwitch(
                        value: controller.favoriteRiders.value,
                        onChanged: (_) {
                          // Toggle handled in onTap above
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Subtotal & Total
              buildDetailRow("Subtotal:", "\$45"),
              SizedBox(height: 10),
              buildDetailRow("Coin/s redeemed:", "\$00"),
              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 24),
              buildDetailRow("Saved:", savedAmount, isTotal: true),
              SizedBox(height: 10),
              buildDetailRow("Total Amount:", formattedTotal, isTotal: true),
              SizedBox(height: 30),

              // Payment Method
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
                  PaymentMethodSelector(
                    options: [
                      PaymentOption(
                        title: "Stripe",
                        subtitle: "Instant payment",
                        imageAsset: IconPath.stripe,
                      ),
                      PaymentOption(
                        title: "Wallet",
                        subtitle: "S\$10.50",
                        imageAsset: IconPath.wallet,
                      ),
                      PaymentOption(
                        title: "Cash",
                        subtitle: "To be paid by sender or receipent",
                        imageAsset: IconPath.cash,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 44),

              // Buttons
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
                      OrderConfirmationDialog.show(orderId);
                      await Future.delayed(Duration(seconds: 3));
                      Get.back();
                      OrderSuccessDialog.show(orderId: orderId);
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

/// Helper function now top-level so it can be accessed from anywhere
Widget buildDetailRow(String title, String value, {bool isTotal = false}) {
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
