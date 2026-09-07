// Unused file
import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/stacked/schedule_stacked_%20delivey/Schedule_sender_recepent/screen/schedule_sender_screen.dart';
import 'package:ZipBee/features/user/stacked/stacked_controller/stacked_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ScheduleDeliveryButton extends StatelessWidget {
  const ScheduleDeliveryButton({super.key, required this.controller});

  final StackedLocationController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isRound = controller.isRoundTrip.value;

      return Column(
        children: [
          Card(
            child: OneAndTwoWayButton(controller: controller, isRound: isRound),
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
                    Image.asset(IconPath.exparess, width: 24, height: 24),
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
                SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // StackedOneWayRoundWidget(
                    //   controller: StackedLocationController(),
                    //   title: 'Collected from (Sender: Athena Lin)',
                    //   subtitle: 'Sender Address',
                    //   icon: Image.asset(
                    //     IconPath.collectIcon,
                    //     width: 14,
                    //     height: 14,
                    //   ),
                    // ),
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
                    // StackedOneWayRoundWidget(
                    //   controller: StackedLocationController(),
                    //   title: isRound
                    //       ? 'Delivered from (Sender: Athena Lin)'
                    //       : 'Deliver to (Recipient: Joseph Low)',
                    //   subtitle: isRound
                    //       ? 'Delivered Address'
                    //       : 'Blk 222 Sengkang Ave 2, S530222',
                    //   icon: Image.asset(
                    //     IconPath.deliveredIcon,
                    //     width: 14,
                    //     height: 14,
                    //   ),
                    // ),
                  ],
                ),
                SizedBox(height: 10),
                Divider(),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black,

                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(Icons.add),
                    label: Text(
                      "Add Stop",
                      style: getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      Get.to(StackedSenderScheduleScreen());
                    },
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

class OneAndTwoWayButton extends StatelessWidget {
  const OneAndTwoWayButton({
    super.key,
    required this.controller,
    required this.isRound,
  });

  final StackedLocationController controller;
  final bool isRound;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => controller.toggleTripType(false),
            child: Container(
              decoration: BoxDecoration(
                color: !isRound
                    ? AppColors.primaryButtonColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: Text(
                "One way",
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => controller.toggleTripType(true),
            child: Container(
              decoration: BoxDecoration(
                color: isRound
                    ? AppColors.primaryButtonColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: Text(
                "Round",
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
