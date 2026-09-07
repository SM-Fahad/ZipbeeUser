import 'package:ZipBee/features/user/express_delivery_1/order_express_delivery/widget/payment_method_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import '../controller/order_express_controller.dart';

class OrderConfirmationSheet {
  static void show(int orderId) {
    final controller = Get.find<OrderControllerExpress>();
    controller.fetchOrderById(orderId);

    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      Container(
        decoration:  BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding:  EdgeInsets.fromLTRB(20, 12, 20, 30),
        child: Obx(() {
          if (controller.isLoading.value && controller.lastOrderData.isEmpty) {
            return  SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                 SizedBox(height: 20),
                Text(
                  "Confirm Your Order",
                  style: getTextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                 SizedBox(height: 24),

                buildSectionLabel("Offers & Discounts"),
                buildPromoRow(),
                 Divider(height: 32),

                buildToggleRow(
                  title: "Redeem 10 Coins",
                  value: controller.redeemCoins.value,
                  onChanged: controller.toggleRedeemCoins,
                ),
                buildToggleRow(
                  title: "Favourite Riders",
                  value: controller.favoriteRiders.value,
                  onChanged: controller.toggleFavoriteRiders,
                ),

                 SizedBox(height: 24),

                buildSectionLabel("Payment Summary"),
                 SizedBox(height: 8),
                buildPriceRow("Subtotal", controller.subtotal),
                buildPriceRow(
                  "Coin/s Redeemed",
                  controller.redeemedAmount,
                  isDiscount: true,
                ),
                buildPriceRow("Saved", "S\$0.00", isDiscount: true),
                 Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Amount",
                      style: getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      controller.totalAmount,
                      style: getTextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),

                 SizedBox(height: 10),
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
                SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side:  BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: getTextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                     SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          bool success = await controller.confirmOrder(orderId);
                          if (success) {
                            
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Confirm Order",
                                style: getTextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  static Widget buildSectionLabel(String text) {
    return Padding(
      padding:  EdgeInsets.only(bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: getTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  static Widget buildPromoRow() {
    return Container(
      padding:  EdgeInsets.all(12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Image.asset(IconPath.promo, height: 24),
           SizedBox(width: 12),
          Text("Promo Code", style: getTextStyle(fontWeight: FontWeight.w600)),
           Spacer(),
          TextButton(
            onPressed: () {},
            child: Text(
              "Add Code",
              style: getTextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildToggleRow({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: getTextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          Switch.adaptive(
            value: value,
            // ignore: deprecated_member_use
            activeColor: Colors.amber,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  static Widget buildPriceRow(
    String label,
    String value, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: getTextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Text(
            value,
            style: getTextStyle(
              fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
