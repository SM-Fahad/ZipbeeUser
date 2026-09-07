import 'package:ZipBee/features/user/finding_raider/widget/button.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ZipBee/core/common/styles/global_text_style.dart';

Future<void> showCancelOrderDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: CancelOrderDialogBody(),
    ),
  );
}

class CancelOrderDialogBody extends StatelessWidget {
  CancelOrderDialogBody({super.key});

  final StackedOrderController controller = Get.find<StackedOrderController>();
  final RxString selectedReason = ''.obs;
  final RxString otherText = ''.obs;
  final TextEditingController otherController = TextEditingController();

  String getFinalReason() {
    if (selectedReason.value == 'Other') return otherText.value.trim();
    return selectedReason.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Are you sure you want to cancel?", style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 24),
          
          // এখানে আপনার reasonButton উইজেটগুলো থাকবে...
          _buildReasonButton("Changed my mind"),
          _buildReasonButton("Too expensive for me"),
          _buildReasonButton("Ordered by mistake"),
          _buildReasonButton("Other"),

          Obx(() => selectedReason.value == "Other" 
              ? TextField(onChanged: (v) => otherText.value = v, decoration: InputDecoration(hintText: "Reason...")) 
              : SizedBox()),

          SizedBox(height: 24),

          Obx(() => ElevatedButton(
            onPressed: controller.isCancelling.value ? null : () {
              controller.handleOrderCancellation(getFinalReason());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              )
              ),
            child: controller.isCancelling.value 
                ? CircularProgressIndicator(color: Colors.white) 
                : Text("Cancel order", style: TextStyle(color: Colors.white)),
          )),

          SizedBox(height: 12),
          
          // TextButton(onPressed: () => Get.back(), child: Text("No, go back")),
          Button(
            buttonText: "No, do not want to cancel the order",
            onPressed: () => Get.back(),
            backgroundColor: Colors.amber,
            textColor: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildReasonButton(String text) {
    return Obx(() => RadioListTile(
      title: Text(text),
      value: text,
      groupValue: selectedReason.value,
      onChanged: (v) => selectedReason.value = v.toString(),
    ));
  }
}