import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/features/user/express_delivery_1/controller/express_controller_1.dart';
import 'package:ZipBee/features/user/schedule_express_delivey/screen/schedule_delivery.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TipAleartDialog extends StatelessWidget {
  const TipAleartDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final locationController = Get.put(ExpressDeliveryMain());
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.amber, width: 2),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 300, 
          maxWidth: 400, 
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+3 Points',
                style: getTextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.amberAccent,
                ),
              ),
              SizedBox(height: 40),
              FilledButton(
                onPressed: () {
                  Get.to(ScheduleDelivery());
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
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
