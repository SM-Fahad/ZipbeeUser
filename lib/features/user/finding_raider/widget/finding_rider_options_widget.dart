import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/finding_raider/controller/rider_controller.dart';
import 'package:ZipBee/features/user/finding_raider/widget/button.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/widget/payment_method_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class FindingRiderOptionsWidget extends StatelessWidget {
  final RiderController? riderController;

  const FindingRiderOptionsWidget({
    super.key,
    this.riderController,
  });

  RiderController get _controller =>
      riderController ??
      (Get.isRegistered<RiderController>()
          ? Get.find<RiderController>()
          : Get.put(RiderController()));

  StackedPaymentController get _paymentCtrl {
    StackedPaymentController ctrl;
    try {
      ctrl = Get.find<StackedPaymentController>();
    } catch (_) {
      ctrl = Get.put(StackedPaymentController());
    }
    if (ctrl.walletBalance.value == 0.0) {
      ctrl.fetchWalletBalance();
    }
    return ctrl;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final bool hasPriority =
            _controller.isPriorited.value || _controller.priorityFee.value > 0;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton(
              onPressed: () => showPriorityOrderDialog(
                context,
                _controller,
                _paymentCtrl,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                hasPriority ? 'Update Priority' : 'Add Priority',
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            if (hasPriority)
              FilledButton(
                onPressed: () => showCancelPriorityDialog(context, _controller),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(
                      color: Colors.orange,
                      width: 1.5,
                    ),
                  ),
                ),
                child: Text(
                  'Cancel Priority',
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

void showPriorityOrderDialog(
  BuildContext context,
  RiderController controller,
  StackedPaymentController paymentCtrl,
) {
  if (paymentCtrl.selectedTitle.value.toLowerCase().contains('cash')) {
    paymentCtrl.selectedTitle.value = 'Wallet';
  }

  final initialAmount = controller.priorityFee.value > 0
      ? controller.priorityFee.value.toStringAsFixed(2)
      : '';
  final TextEditingController amountController =
      TextEditingController(text: initialAmount);

  Get.dialog(
    Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Priority Order',
                  style: getTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Enter Priority Amount',
              style: getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter amount (e.g. 5.00)',
                prefixText: '\$ ',
                prefixStyle: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.amber, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Payment Method:',
                    style: getTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => StackedPaymentMethodSelector(
                    orderAmount: controller.totalCost.value,
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
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Obx(() {
              final bool isUpdate =
                  controller.isPriorited.value || controller.priorityFee.value > 0;
              return SizedBox(
                width: double.infinity,
                child: Button(
                  buttonText: isUpdate ? 'Update Priority' : 'Add Priority',
                  backgroundColor: Colors.amber,
                  textColor: Colors.black,
                  onPressed: () async {
                    final amount =
                        double.tryParse(amountController.text.trim());
                    if (amount == null || amount <= 0) {
                      EasyLoading.showError('Please enter a valid amount');
                      return;
                    }

                    final String titleLower =
                        paymentCtrl.selectedTitle.value.toLowerCase();
                    final String payType = titleLower.contains('cash')
                        ? 'COD'
                        : (titleLower.contains('stripe')
                            ? 'ONLINE_PAY'
                            : 'WALLET');

                    String? paymentMethodId;
                    if (payType == 'ONLINE_PAY') {
                      paymentMethodId = paymentCtrl
                              .selectedStripeCard.value?.stripeMethodId ??
                          paymentCtrl.selectedPaymentMethodId;

                      if (paymentMethodId == null || paymentMethodId.isEmpty) {
                        EasyLoading.showError(
                          'Please select a Stripe payment card',
                        );
                        return;
                      }
                    }

                    Get.back();
                    await controller.addOrUpdatePriority(
                      amount: amount,
                      payType: payType,
                      paymentMethodId: paymentMethodId,
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    ),
  );
}

void showCancelPriorityDialog(
  BuildContext context,
  RiderController controller,
) {
  Get.dialog(
    AlertDialog(
      title: const Text('Cancel Priority'),
      content: const Text(
        'Are you sure you want to cancel priority for this order and refund to wallet?',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () async {
            Get.back();
            await controller.cancelPriority();
          },
          child: const Text('Yes', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
