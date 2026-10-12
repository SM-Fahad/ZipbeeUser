import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/finding_raider/controller/rider_controller.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/widget/payment_method_widget.dart';
import 'package:ZipBee/features/user/wallet/manage_payment/model/payment_card_model.dart';
import 'package:ZipBee/features/user/wallet/manage_payment/screen/manage_payment_screen.dart';
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
              onPressed: () async {
                EasyLoading.show(status: 'Loading...');
                try {
                  await Future.wait([
                    _paymentCtrl.fetchWalletBalance(),
                    _paymentCtrl.loadStripeCards(forceRefresh: true),
                  ]);
                } catch (_) {}
                EasyLoading.dismiss();
                if (context.mounted) {
                  showPriorityOrderDialog(
                    context,
                    _controller,
                    _paymentCtrl,
                  );
                }
              },
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
  // Ensure cards and balance are refreshed in the background as well
  paymentCtrl.fetchWalletBalance();
  paymentCtrl.loadStripeCards();

  final initialAmount = controller.priorityFee.value > 0
      ? controller.priorityFee.value.toStringAsFixed(2)
      : '';
  final TextEditingController amountController =
      TextEditingController(text: initialAmount);

  // Default selection: If wallet has balance, default to WALLET; else default to primary card if available
  final RxString selectedMethod = RxString('WALLET');
  final cards = paymentCtrl.managePaymentController.savedCards;
  if (paymentCtrl.walletBalance.value <= 0 && cards.isNotEmpty) {
    final defaultCard = cards
            .where((c) => c.isDefault)
            .cast<PaymentCardModel?>()
            .firstOrNull ??
        cards.firstOrNull;
    if (defaultCard != null) {
      selectedMethod.value = defaultCard.stripeMethodId;
      paymentCtrl.selectedStripeCard.value = defaultCard;
      paymentCtrl.selectedPaymentMethodId = defaultCard.stripeMethodId;
    }
  } else {
    selectedMethod.value = 'WALLET';
    paymentCtrl.selectedTitle.value = 'Wallet';
  }

  Get.dialog(
    Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
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
                  'Enter Priority Amount (Min \$5)',
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
                    hintText: 'Enter amount (Min \$5)',
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
                Text(
                  'Select Payment Method',
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() {
                  final savedCards = paymentCtrl.managePaymentController.savedCards;
                  final walletBal = paymentCtrl.walletBalance.value;

                  return Column(
                    children: [
                      // --- Wallet Option ---
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedMethod.value == 'WALLET'
                                ? Colors.amber
                                : Colors.grey.shade300,
                            width: selectedMethod.value == 'WALLET' ? 1.8 : 1,
                          ),
                          color: selectedMethod.value == 'WALLET'
                              ? const Color(0xFFFFFBEA)
                              : Colors.white,
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          leading: Image.asset(
                            IconPath.wallet,
                            width: 28,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.account_balance_wallet, color: Colors.amber),
                          ),
                          title: Text(
                            "Wallet",
                            style: getTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            "\$${walletBal.toStringAsFixed(2)}",
                            style: getTextStyle(
                              fontSize: 12,
                              color: walletBal > 0 ? Colors.black87 : Colors.grey.shade600,
                            ),
                          ),
                          trailing: Radio<String>(
                            value: 'WALLET',
                            activeColor: Colors.amber,
                            groupValue: selectedMethod.value,
                            onChanged: (val) {
                              if (val != null) {
                                selectedMethod.value = val;
                                paymentCtrl.selectedTitle.value = 'Wallet';
                              }
                            },
                          ),
                          onTap: () {
                            selectedMethod.value = 'WALLET';
                            paymentCtrl.selectedTitle.value = 'Wallet';
                          },
                        ),
                      ),

                      // --- Saved Stripe Cards (e.g. Visa ****4242) ---
                      ...savedCards.map((card) {
                        final bool isSelected =
                            selectedMethod.value == card.stripeMethodId;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.amber
                                  : Colors.grey.shade300,
                              width: isSelected ? 1.8 : 1,
                            ),
                            color: isSelected
                                ? const Color(0xFFFFFBEA)
                                : Colors.white,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            leading: Image.asset(
                              IconPath.stripe,
                              width: 28,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.credit_card,
                                color: Colors.blueAccent,
                              ),
                            ),
                            title: Text(
                              "${card.brandLabel} ****${card.last4}",
                              style: getTextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              "Expiry ${card.expiryLabel}",
                              style: getTextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            trailing: Radio<String>(
                              value: card.stripeMethodId,
                              activeColor: Colors.amber,
                              groupValue: selectedMethod.value,
                              onChanged: (val) {
                                if (val != null) {
                                  selectedMethod.value = val;
                                  paymentCtrl.selectedStripeCard.value = card;
                                  paymentCtrl.selectedPaymentMethodId =
                                      card.stripeMethodId;
                                  paymentCtrl.selectedTitle.value =
                                      'Stripe • ${card.brandLabel} ****${card.last4}';
                                }
                              },
                            ),
                            onTap: () {
                              selectedMethod.value = card.stripeMethodId;
                              paymentCtrl.selectedStripeCard.value = card;
                              paymentCtrl.selectedPaymentMethodId =
                                  card.stripeMethodId;
                              paymentCtrl.selectedTitle.value =
                                  'Stripe • ${card.brandLabel} ****${card.last4}';
                            },
                          ),
                        );
                      }),

                      // --- Add Payment Method Option ---
                      InkWell(
                        onTap: () async {
                          Get.back();
                          await Get.to(() => ManagePaymentScreen());
                          await Future.wait([
                            paymentCtrl.fetchWalletBalance(),
                            paymentCtrl.loadStripeCards(forceRefresh: true),
                          ]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.add_circle_outline,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                savedCards.isEmpty
                                    ? '+ Add payment method (Visa / Mastercard)'
                                    : '+ Add another payment method',
                                style: getTextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 20),
                Obx(() {
                  final bool isUpdate = controller.isPriorited.value ||
                      controller.priorityFee.value > 0;
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final amount =
                            double.tryParse(amountController.text.trim());
                        if (amount == null || amount <= 0) {
                          EasyLoading.showError('Please enter a valid amount');
                          return;
                        }

                        if (selectedMethod.value == 'WALLET') {
                          if (paymentCtrl.walletBalance.value < amount) {
                            EasyLoading.showError(
                              'Insufficient wallet balance (\$${paymentCtrl.walletBalance.value.toStringAsFixed(2)})',
                            );
                            return;
                          }
                          Get.back();
                          await controller.addOrUpdatePriority(
                            amount: amount,
                            payType: 'WALLET',
                          );
                        } else {
                          final cardId = selectedMethod.value;
                          if (cardId.isEmpty) {
                            EasyLoading.showError(
                              'Please select a payment method',
                            );
                            return;
                          }
                          Get.back();
                          await controller.addOrUpdatePriority(
                            amount: amount,
                            payType: 'ONLINE_PAY',
                            paymentMethodId: cardId,
                          );
                        }
                      },
                      child: Text(
                        isUpdate ? 'Update Priority' : 'Confirm',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
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
