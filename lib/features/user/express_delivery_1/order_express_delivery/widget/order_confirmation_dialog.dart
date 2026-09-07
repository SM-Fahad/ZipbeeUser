import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/features/user/express_delivery_1/controller/express_controller_1.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderConfirmationDialog {
  static final ExpressDeliveryMain controller = Get.put(ExpressDeliveryMain());

  static void show([dynamic orderIdentifier]) {
    if (orderIdentifier != null) {
      try {
        controller.orderNumber.value = '#${orderIdentifier.toString()}';
      } catch (_) {}
    }
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 16),

              Obx(
                () => Text(
                  'Congratulations!\nYour order ${controller.orderNumber.value} has been placed!',
                  style: getTextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),

              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFF789F56),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 40),
              ),

              SizedBox(height: 24),

              Text(
                'Once a driver has been assigned, you’ll receive a follow-up call for confirmation. Thank you again for your cooperation!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true, 
    );
  }
}
