import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/wallet/manage_payment/model/payment_card_model.dart';
import 'package:ZipBee/features/user/wallet/manage_payment/screen/manage_payment_screen.dart';

void showAddAmountDialog(BuildContext context, dynamic controller, dynamic paymentCtrl) {
  final TextEditingController amountController = TextEditingController();
  final RxString selectedMethod = RxString('WALLET');

  try {
    paymentCtrl?.fetchWalletBalance();
    paymentCtrl?.loadStripeCards();
  } catch (_) {}

  final cards = paymentCtrl?.managePaymentController?.savedCards ?? <PaymentCardModel>[];
  if (paymentCtrl != null && paymentCtrl.walletBalance.value <= 0 && cards.isNotEmpty) {
    final defaultCard = (cards as List<PaymentCardModel>)
            .where((c) => c.isDefault)
            .cast<PaymentCardModel?>()
            .firstOrNull ??
        cards.firstOrNull;
    if (defaultCard != null) {
      selectedMethod.value = defaultCard.stripeMethodId;
    }
  }

  Get.dialog(
    Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Add Amount", style: getTextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: "Enter amount (Min \$5)",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixText: "\$ ",
                  ),
                ),
                const SizedBox(height: 20),
                
                Text("Select Payment Method", style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),

                // Options list
                Obx(() {
                  final double balance = (paymentCtrl?.walletBalance?.value ?? 0.0).toDouble();
                  final List<PaymentCardModel> savedCards =
                      (paymentCtrl?.managePaymentController?.savedCards as List<PaymentCardModel>?) ?? [];

                  return Column(
                    children: [
                      // Wallet Option
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selectedMethod.value == 'WALLET' ? Colors.amber : Colors.grey.shade300,
                            width: selectedMethod.value == 'WALLET' ? 1.8 : 1,
                          ),
                          color: selectedMethod.value == 'WALLET' ? const Color(0xFFFFFBEA) : Colors.white,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          leading: Image.asset(IconPath.wallet, width: 26),
                          title: const Text("Wallet"),
                          subtitle: Text(
                            "\$${balance.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: balance > 0 ? Colors.black87 : Colors.grey.shade600,
                            ),
                          ),
                          trailing: Radio<String>(
                            value: 'WALLET',
                            activeColor: Colors.amber,
                            groupValue: selectedMethod.value,
                            onChanged: (val) => selectedMethod.value = val ?? 'WALLET',
                          ),
                          onTap: () => selectedMethod.value = 'WALLET',
                        ),
                      ),

                      // Saved Cards (Visa / Mastercard)
                      ...savedCards.map((card) {
                        final bool isSelected = selectedMethod.value == card.stripeMethodId;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Colors.amber : Colors.grey.shade300,
                              width: isSelected ? 1.8 : 1,
                            ),
                            color: isSelected ? const Color(0xFFFFFBEA) : Colors.white,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            leading: Image.asset(
                              IconPath.stripe,
                              width: 26,
                              errorBuilder: (_, __, ___) => const Icon(Icons.credit_card, color: Colors.blueAccent),
                            ),
                            title: Text("${card.brandLabel} ****${card.last4}"),
                            subtitle: Text("Expiry ${card.expiryLabel}"),
                            trailing: Radio<String>(
                              value: card.stripeMethodId,
                              activeColor: Colors.amber,
                              groupValue: selectedMethod.value,
                              onChanged: (val) {
                                if (val != null) selectedMethod.value = val;
                              },
                            ),
                            onTap: () => selectedMethod.value = card.stripeMethodId,
                          ),
                        );
                      }),

                      // Add Card Option
                      InkWell(
                        onTap: () async {
                          Get.back();
                          await Get.to(() => ManagePaymentScreen());
                          try {
                            if (paymentCtrl != null) {
                              await paymentCtrl.fetchWalletBalance();
                              await paymentCtrl.loadStripeCards(forceRefresh: true);
                            }
                          } catch (_) {}
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.add_circle_outline, color: Colors.amber, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                savedCards.isEmpty
                                    ? '+ Add payment method (Visa / Mastercard)'
                                    : '+ Add another payment method',
                                style: getTextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      final double? val = double.tryParse(amountController.text.trim());
                      if (val != null && val > 0) {
                        try {
                          controller.addNewAmount(val);
                        } catch (_) {}
                        EasyLoading.showSuccess('Amount Added!');
                        Get.back();
                      } else {
                        EasyLoading.showError('Please enter a valid positive amount');
                      }
                    },
                    child: const Text("Confirm", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}