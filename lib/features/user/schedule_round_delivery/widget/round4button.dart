import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/express_delivery_1/controller/express_controller_1.dart';
import 'package:ZipBee/features/user/express_delivery_1/widget/one_way_round_functionality.dart';
import 'package:ZipBee/features/user/schedule_express_delivey/schedule_sender_recepent/screen/schedule_sender_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Round4 extends StatelessWidget {
  const Round4({super.key, required this.controller});

  final ExpressDeliveryMain controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isRound = controller.isRoundTrip.value;

      return Column(
        children: [
          /// ------------------ ONE WAY | ROUND SWITCH ------------------

          /// ------------------- MAIN CONTAINER -------------------
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
                Card(
                  child: Row(
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
                  ),
                ),
                SizedBox(height: 8),

                /// Title Row
                Row(
                  spacing: 8,
                  children: [
                    Center(
                      child: Image.asset(
                        IconPath.exparess,
                        width: 24,
                        height: 24,
                      ),
                    ),
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

                /// ---------------- ROUND TRIP SECTION ----------------
                if (isRound)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OneWayRoundWidget(
                        controller: ExpressDeliveryMain(),
                        title: 'Collected from (Sender: Athena Lin)',
                        subtitle: 'Blk 657 Ang Mo Kio Ave 9, S560657',
                        icon: Image.asset(
                          IconPath.collectIcon,
                          width: 14,
                          height: 14,
                        ),
                      ),

                      SizedBox(height: 4),
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

                      OneWayRoundWidget(
                        controller: ExpressDeliveryMain(),
                        title: 'Deliver to (Recipient: Joseph Low)',
                        subtitle: 'Blk 222 Sengkang Ave 2, S530222',
                        icon: Image.asset(
                          IconPath.deliveredIcon,
                          width: 14,
                          height: 14,
                        ),
                      ),

                      SizedBox(height: 4),
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

                      OneWayRoundWidget(
                        controller: ExpressDeliveryMain(),
                        title: 'Deliver to (Annie Tan)',
                        subtitle: 'Blk 447 Sengkang Ave 4, S530447',
                        icon: Image.asset(
                          IconPath.deliveredIcon,
                          width: 14,
                          height: 14,
                        ),
                      ),

                      SizedBox(height: 4),
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

                      OneWayRoundWidget(
                        controller: ExpressDeliveryMain(),
                        title: 'Deliver to (Tony Toh)',
                        subtitle: 'Blk 244 Jurong East St 61, S500244',
                        icon: Image.asset(
                          IconPath.deliveredIcon,
                          width: 14,
                          height: 14,
                        ),
                      ),
                    ],
                  ),

                /// ---------------- ONE WAY SECTION ----------------
                if (!isRound)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OneWayRoundWidget(
                        controller: ExpressDeliveryMain(),
                        title: 'Collected from (Sender: Athena Lin)',
                        subtitle: 'Sender Address',
                        icon: Image.asset(
                          IconPath.collectIcon,
                          width: 14,
                          height: 14,
                        ),
                      ),
                      SizedBox(height: 4),
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
                      OneWayRoundWidget(
                        controller: ExpressDeliveryMain(),
                        title: 'Delivered from (Sender: Athena Lin)',
                        subtitle: 'Delivered Address',
                        icon: Image.asset(
                          IconPath.deliveredIcon,
                          width: 14,
                          height: 14,
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: 16),
                Divider(),

                /// ---------------- ADD STOP BUTTON ----------------
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
                      Get.to(SenderScheduleScreen());
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
