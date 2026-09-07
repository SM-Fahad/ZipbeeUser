import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/express_delivery_1/controller/express_controller_1.dart';
import 'package:ZipBee/features/user/express_delivery_1/widget/one_way_round_functionality.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class ExpressButtonWidget extends StatelessWidget {
  const ExpressButtonWidget({super.key, required this.controller});

  final ExpressDeliveryMain controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isRound = controller.isRoundTrip.value;

      return Column(
        children: [
          Card(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.toggleTripType(false),
                    child: Container(
                      padding:  EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: !isRound
                            ? AppColors.primaryButtonColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'One way',
                        style: getTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.toggleTripType(true),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isRound
                            ? AppColors.primaryButtonColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Round',
                        style: getTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

           SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(IconPath.exparessGrey, width: 15, height: 15),
                     SizedBox(width: 8),
                    Text(
                      'Fixed route',
                      style: getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                 SizedBox(height: 8),

                OneWayRoundWidget(
                  controller: controller,
                  title:
                      'Collected from (Sender: ${controller.senderName.value.isEmpty ? 'N/A' : controller.senderName.value})',
                  subtitle: controller.senderAddress.value.isEmpty
                      ? 'Sender Address'
                      : controller.senderAddress.value,
                  icon: Image.asset(
                    IconPath.collectIcon,
                    width: 14,
                    height: 14,
                  ),
                ),

                 SizedBox(height: 6),
                 Icon(
                  Icons.fiber_manual_record,
                  size: 10,
                  color: Colors.grey,
                ),
                 Icon(
                  Icons.fiber_manual_record,
                  size: 10,
                  color: Colors.grey,
                ),
                 SizedBox(height: 6),

                OneWayRoundWidget(
                  controller: controller,
                  title:
                      'Delivered to (Receiver: ${controller.receiverName.value.isEmpty ? 'N/A' : controller.receiverName.value})',
                  subtitle: controller.receiverAddress.value.isEmpty
                      ? 'Delivered Address'
                      : controller.receiverAddress.value,
                  icon: Image.asset(
                    IconPath.deliveredIcon,
                    width: 14,
                    height: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
