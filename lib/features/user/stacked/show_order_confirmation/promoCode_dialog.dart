import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/express_delivery_1/controller/express_controller_1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class PromoDialog extends StatelessWidget {
  final TextEditingController promoController = TextEditingController();
  final int orderId;

  PromoDialog({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: promoController,
          decoration: InputDecoration(
            hintText: "AZN07",
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.0),
              child: Image.asset(IconPath.promo, width: 24, height: 24),
            ),
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
        SizedBox(height: 40),
        FilledButton(
          onPressed: () async {
            if (promoController.text.isEmpty) {
              Get.snackbar("Error", "Please enter a promo code");
              return;
            }

            EasyLoading.show(status: 'Applying promo code...');
            final controller = Get.find<ExpressDeliveryMain>();
            await controller.applyPromoCode(
              orderId: orderId,
              promoCode: promoController.text,
            );
            EasyLoading.dismiss();
            Get.back();
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            'Apply',
            style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
