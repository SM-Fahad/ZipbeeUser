import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/features/user/finding_raider/screnn/finding_rider_page.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/service/notify_rider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../controller/stacked_order_controller.dart';

class StackedOrderSuccessDialog {
  static final RxBool wantsConfirmationCall = true.obs;
  static final RxBool isSubmitting = false.obs;

  static StackedOrderController get controller =>
      Get.find<StackedOrderController>();

  static void show() {
    wantsConfirmationCall.value = true;
    isSubmitting.value = false;

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(
                  () => Text(
                    'Your order ${controller.displayOrderNumber} is confirmed!',
                    style: getTextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 24),

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
                  'Would you like the assigned driver to call you once your order is accepted? ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 20),

                Obx(
                  () => IgnorePointer(
                    ignoring: isSubmitting.value,
                    child: Opacity(
                      opacity: isSubmitting.value ? 0.6 : 1,
                      child: RadioGroup<bool>(
                        groupValue: wantsConfirmationCall.value,
                        onChanged: (value) async {
                          if (value != null) {
                            await _selectConfirmation(value);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () async => _selectConfirmation(true),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<bool>(
                                    value: true,
                                    activeColor: Colors.blue,
                                  ),
                                  SizedBox(width: 4),
                                  Text('Yes', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () async => _selectConfirmation(false),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<bool>(
                                    value: false,
                                    activeColor: Colors.blue,
                                  ),
                                  SizedBox(width: 4),
                                  Text('No', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false, // Prevent closing on outside tap
    );
  }

  static Future<void> _selectConfirmation(bool wantsCall) async {
    if (isSubmitting.value) return;

    wantsConfirmationCall.value = wantsCall;
    if (wantsCall) {
      await _handleRaiderConfirmation();
    } else {
      _goToNextFlow();
    }
  }

  static Future<void> _handleRaiderConfirmation() async {
    if (isSubmitting.value) return;

    var loadingShown = false;

    try {
      final orderId = controller.lastOrderId?.toString();
      if (orderId == null) {
        EasyLoading.showError('Order ID not found');
        return;
      }

      debugPrint('📢 Raider Confirmation - OrderId: $orderId');

      isSubmitting.value = true;
      EasyLoading.show(status: 'Processing...');
      loadingShown = true;

      final res = await NotifyRider.raiderConfirmation(
        orderId: orderId,
      );

      if (loadingShown) {
        EasyLoading.dismiss();
        loadingShown = false;
      }

      final success = res['success'] as bool? ?? false;
      if (success) {
        debugPrint('✅ Raider confirmation successful');
        debugPrint('✅ Navigating to FindingRiderPage with OrderId: $orderId');
        _goToNextFlow();
      } else {
        EasyLoading.showError('Failed to process your response');
      }
    } catch (e) {
      if (loadingShown) {
        EasyLoading.dismiss();
      }
      debugPrint('❌ Error in _handleRaiderConfirmation: $e');
      EasyLoading.showError('An error occurred');
    } finally {
      isSubmitting.value = false;
    }
  }

  static void _goToNextFlow() {
    Get.back();
    Get.to(() => FindingRiderPage());
  }
}
