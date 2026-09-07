import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PromoDialogController extends GetxController {
  final promoController = TextEditingController();

  @override
  void onClose() {
    promoController.dispose();
    super.onClose();
  }
}

class StackedPromoDialogContent extends StatelessWidget {
  const StackedPromoDialogContent({super.key});

  @override
  Widget build(BuildContext context) {
    final promoDialogCtrl = Get.put(PromoDialogController());
    final controller = Get.find<StackedOrderController>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: promoDialogCtrl.promoController,
          decoration: const InputDecoration(
            hintText: "Type your code",
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FilledButton(
              onPressed: () async {
                await controller.applyPromoCode(promoDialogCtrl.promoController.text);
                promoDialogCtrl.promoController.clear();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Apply',
                style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Cancel',
                style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
