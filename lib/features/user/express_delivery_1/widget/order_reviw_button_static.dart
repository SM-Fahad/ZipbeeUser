import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/express_delivery_1/controller/express_controller_1.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderReviwButtonStatic extends StatelessWidget {
  final ExpressDeliveryMain controller = Get.find<ExpressDeliveryMain>();

  OrderReviwButtonStatic({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 70),
      padding: EdgeInsets.all(5),
      color: Colors.white,
      child: Row(
        children: [
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Total ',
                        style: getTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryFontColor,
                        ),
                      ),
                      TextSpan(
                        text: '(incl GST)',
                        style: getTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: AppColors.primaryFontColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => Text(
                    controller.totalAmount.value.toString(),
                    style: getTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: controller.totalAmount.value > 0
                    ? Colors.amber
                    : Colors.grey,
              ),
              onPressed: controller.totalAmount.value > 0
                  ? () {
                      controller.createOrder(); 
                    }
                  : null,
              child: controller.isLoading.value
                  ? SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Review Order',
                      style: getTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
            ),
          ),

           SizedBox(width: 8),
        ],
      ),
    );
  }
}
