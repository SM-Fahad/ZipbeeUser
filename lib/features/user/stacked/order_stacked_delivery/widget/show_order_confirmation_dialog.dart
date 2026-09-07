import 'package:ZipBee/features/user/finding_raider/screnn/finding_rider_page.dart';
import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/bottom_navbar/screen/bottom_navbar_screen.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/service/order_confirmation_service.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/widget/custom_toggle_switch_widget.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/widget/order_confirmation_dialog.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/widget/order_success_widget.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/widget/payment_method_widget.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/widget/promo_dialog_widget.dart';
import 'package:ZipBee/features/user/wallet/loyalty_and_rewards/controller/loyalty_and_rewards_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

/// Show order confirmation dialog
void showStackedOrderConfirmationDialog(
  StackedOrderController controller,
) async {
  /// Ensure payment controller exists
  StackedPaymentController paymentCtrl;
  try {
    paymentCtrl = Get.find<StackedPaymentController>();
  } catch (_) {
    paymentCtrl = Get.put(StackedPaymentController());
  }

  LoyaltyAndRewardsController loyaltyCtrl;
  try {
    loyaltyCtrl = Get.find<LoyaltyAndRewardsController>();
  } catch (_) {
    loyaltyCtrl = Get.put(LoyaltyAndRewardsController(), permanent: false);
  }

  // Fetch wallet balance
  EasyLoading.show(status: 'Loading wallet...');
  final userRes = await OrderConfirmationService.getUserProfile();
  final userSuccess = userRes['success'] as bool? ?? false;

  double walletBalance = 0.0;
  if (userSuccess) {
    final userData = userRes['body'] as Map<String, dynamic>? ?? {};
    final userActualData = userData['data'] as Map<String, dynamic>? ?? {};
    final balanceRaw = userActualData['currentWalletBalance'];
    walletBalance = balanceRaw is String
        ? double.tryParse(balanceRaw) ?? 0.0
        : (balanceRaw as num?)?.toDouble() ?? 0.0;
    paymentCtrl.walletBalance.value = walletBalance;
    debugPrint('💰 Wallet Balance: \$$walletBalance');
  }
  await loyaltyCtrl.loadUserCoin();
  EasyLoading.dismiss();

  final codCollectFrom = 'RECEIVER'.obs;

  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: 8),
      content: SingleChildScrollView(
        child: Container(
          width: Get.width * 0.95,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Order",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 22),

              /// Promo Code Section
              Obx(
                () => Row(
                  children: [
                    Image.asset(IconPath.promo, height: 24, width: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Promo Code',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // Show applied code or Enter code button
                    controller.promoCode.value.isNotEmpty
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.green.withValues(alpha: 0.1),
                                ),
                                child: Text(
                                  controller.promoCode.value.toUpperCase(),
                                  style: getTextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  await controller.removePromoCode();
                                  debugPrint(
                                    '🔄 Promo removed, dialog should refresh',
                                  );
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 18,
                                ),
                              ),
                            ],
                          )
                        : GestureDetector(
                            onTap: () {
                              Get.dialog(
                                AlertDialog(
                                  insetPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: Colors.amber,
                                      width: 2,
                                    ),
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
                                      const Spacer(),
                                      InkWell(
                                        onTap: Get.back,
                                        child: const Icon(
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
                                          0.8;
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "Enter code",
                                style: getTextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              /// Redeem Coins
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Text(
                      'Redeem ${loyaltyCtrl.coin.value} Coins',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Obx(
                    () => StackedCustomToggleSwitch(
                      value: controller.redeemCoins.value,
                      onChanged: (value) async {
                        await controller.toggleRedeemCoins(
                          value,
                          coinsAmount: loyaltyCtrl.coin.value,
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              /// Favourite Riders
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
                    () => StackedCustomToggleSwitch(
                      value: controller.favoriteRiders.value,
                      onChanged: controller.toggleFavoriteRiders,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// Payment Summary Section
              Text(
                'Payment Summary',
                style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              /// Subtotal (Original Cost)
              Obx(
                () => buildDetailRow(
                  "Total Cost:",
                  "\$${(controller.originalCost.value > 0 ? controller.originalCost.value : controller.totalCost.value).toStringAsFixed(2)}",
                ),
              ),

              const SizedBox(height: 10),

              /// Promo Discount
              Obx(
                () => controller.discountAmount.value > 0
                    ? buildDetailRow(
                        "Promo (${controller.promoCode.value}):",
                        "-\$${controller.discountAmount.value.toStringAsFixed(2)}",
                        isDiscount: true,
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 10),

              /// Saved Amount (Total discount including coins)
              Obx(
                () =>
                    (controller.discountAmount.value > 0 ||
                        controller.coinsRedeemed.value > 0)
                    ? buildDetailRow(
                        "Total Saved:",
                        "-\$${(controller.discountAmount.value + (controller.coinsRedeemed.value > 0 ? 0.0 : 0.0)).toStringAsFixed(2)}",
                        isDiscount: true,
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              /// Total Cost
              Obx(
                () => buildDetailRow(
                  "SubTotal:",
                  "\$${(controller.totalAmount.value > 0 ? controller.totalAmount.value : controller.totalCost.value).toStringAsFixed(2)}",
                  isTotal: true,
                ),
              ),

              const SizedBox(height: 24),

              /// Payment Method
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
                    orderAmount: controller.totalAmount.value,
                    options: [
                      StackedPaymentOption(
                        title: "Stripe",
                        subtitle: "Instant payment",
                        imageAsset: IconPath.stripe,
                      ),
                      StackedPaymentOption(
                        title: "Wallet",
                        subtitle:
                            "\$${paymentCtrl.walletBalance.value.toStringAsFixed(2)}",
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

              const SizedBox(height: 12),

              /// Cash collect from
              Obx(() {
                if (paymentCtrl.selectedTitle.value.toLowerCase().contains(
                  'cash',
                )) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cash Collect from:',
                        style: getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      DropdownButton<String>(
                        value: codCollectFrom.value,
                        items: const [
                          DropdownMenuItem(
                            value: 'SENDER',
                            child: Text('Sender'),
                          ),
                          DropdownMenuItem(
                            value: 'RECEIVER',
                            child: Text('Receiver'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) codCollectFrom.value = v;
                        },
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),

              const SizedBox(height: 32),

              /// Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton(
                    onPressed: () {
                      Get.offAll(() => BottomNavbarScreen());
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: Colors.red, width: 1.5),
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
                        const SizedBox(width: 4),
                        Image.asset(IconPath.cancel, height: 14, width: 14),
                      ],
                    ),
                  ),

                  /// Place Order
                  FilledButton(
                    onPressed: () async {
                      final selected = paymentCtrl.selectedTitle.value
                          .toLowerCase();

                      debugPrint(
                        '➡️ Place Order clicked - Payment method: $selected',
                      );

                      // Handle STRIPE separately
                      if (selected.contains('stripe')) {
                        final stripePaymentMethodId =
                            paymentCtrl.selectedPaymentMethodId;

                        if (stripePaymentMethodId == null ||
                            stripePaymentMethodId.isEmpty) {
                          EasyLoading.showError(
                            'Please select a saved Stripe card',
                          );
                          return;
                        }

                        debugPrint(
                          '➡️ Stripe saved-card payment flow initiated with paymentMethodId: $stripePaymentMethodId',
                        );

                        EasyLoading.show(status: 'Placing order...');

                        final ok = await controller.confirmPlaceOrder(
                          paymentMethod: 'ONLINE_PAY',
                          paymentMethodId: stripePaymentMethodId,
                          codCollectFrom: null,
                        );

                        EasyLoading.dismiss();

                        if (!ok) {
                          EasyLoading.showError('Failed to place order');
                          return;
                        }

                        await _handlePostOrderSuccessDialogFlow(controller);
                      } else {
                        // Handle WALLET and CASH
                        String paymentMethodApi;
                        String? codCollect;

                        if (selected.contains('cash')) {
                          debugPrint('✅ Cash payment selected');
                          paymentMethodApi = 'COD';
                          codCollect = codCollectFrom.value;
                        } else if (selected.contains('wallet')) {
                          debugPrint('✅ Wallet payment selected');
                          paymentMethodApi = 'WALLET';
                          codCollect = null;
                        } else {
                          EasyLoading.showError(
                            'Please select a payment method',
                          );
                          return;
                        }

                        EasyLoading.show(status: 'Placing order...');

                        final ok = await controller.confirmPlaceOrder(
                          paymentMethod: paymentMethodApi,
                          paymentMethodId: null,
                          codCollectFrom: codCollect,
                        );

                        EasyLoading.dismiss();

                        if (ok) {
                          debugPrint(
                            'Final placed total: ${controller.totalAmount.value}',
                          );

                          await _handlePostOrderSuccessDialogFlow(controller);
                        } else {
                          EasyLoading.showError('Failed to place order');
                        }
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'Place Order',
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

Future<void> _handlePostOrderSuccessDialogFlow(
  StackedOrderController controller,
) async {
  Get.back(); // Closes the summary/confirmation dialog

  if (controller.isAutoConfirmation.value) {
    Get.to(() => FindingRiderPage());
    return;
  }

  final orderId = controller.lastOrderId;
  var shouldShowFirstOrderDialog = false;

  if (orderId != null && orderId != 0) {
    final firstOrderRes = await OrderConfirmationService.getFirstOrderStatus(
      orderId,
    );
    final success = firstOrderRes['success'] as bool? ?? false;
    final body = firstOrderRes['body'] as Map<String, dynamic>? ?? {};
    final data = body['data'] as Map<String, dynamic>? ?? {};
    final isFirstOrderData =
        data['isFirstOrder'] as Map<String, dynamic>? ?? {};

    shouldShowFirstOrderDialog =
        success && (isFirstOrderData['isFirstOrder'] == true);

    debugPrint(
      '✅ First order check - OrderId: $orderId, IsFirstOrder: $shouldShowFirstOrderDialog',
    );
  } else {
    debugPrint('⚠️ First order check skipped - invalid order id: $orderId');
  }

  if (shouldShowFirstOrderDialog) {
    StackedOrderConfirmationDialog.show();
    return;
  }

  StackedOrderSuccessDialog.show();
}

/// Helper - with discount styling for red text
Widget buildDetailRow(
  String title,
  String value, {
  bool isTotal = false,
  bool isDiscount = false,
}) {
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
          color: isDiscount
              ? Colors.green
              : (isTotal ? Colors.amber : Colors.black),
        ),
      ),
    ],
  );
}
