import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';

void showAddAmountDialog(BuildContext context, dynamic controller, dynamic paymentCtrl) {
  final TextEditingController amountController = TextEditingController();
  RxInt selectedMethod = 1.obs; // 1 for Wallet

  try {
    if (paymentCtrl != null && paymentCtrl.walletBalance.value == 0.0) {
      paymentCtrl.fetchWalletBalance();
    }
  } catch (_) {}

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add Amount", style: getTextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: "Enter amount",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixText: "\$ ",
              ),
            ),
            const SizedBox(height: 20),
            
            Text("Select Payment Method", style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            // Wallet Option
            Obx(() => ListTile(
              leading: Image.asset(IconPath.wallet, width: 24),
              title: const Text("Wallet"),
              subtitle: Text("\$${paymentCtrl.walletBalance.value.toStringAsFixed(2)}"),
              trailing: Radio<int>(
                value: 1, 
                activeColor: Colors.amber,
                groupValue: selectedMethod.value, 
                onChanged: (val) => selectedMethod.value = val!
              ),
              onTap: () => selectedMethod.value = 1,
            )),

            // Stripe Option
            Obx(() => ListTile(
              leading: Image.asset(
                IconPath.stripe,
                width: 24, 
                errorBuilder: (c, e, s) => const Icon(Icons.payment, color: Colors.grey),
              ),
              title: const Text("Stripe"),
              subtitle: const Text("Credit or Debit card"),
              trailing: Radio<int>(
                value: 2, 
                activeColor: Colors.amber,
                groupValue: selectedMethod.value, 
                onChanged: (val) => selectedMethod.value = val!
              ),
              onTap: () => selectedMethod.value = 2,
            )),

            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
                onPressed: () {
                  double? val = double.tryParse(amountController.text);
                  if (val != null && val > 0) {
                    controller.addNewAmount(val);
                    EasyLoading.showSuccess('Amount Added!');
                    Get.back();
                  } else {
                    EasyLoading.showError('Please enter a valid positive amount');
                  }
                },
                child: const Text("Confirm", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    ),
  );
}