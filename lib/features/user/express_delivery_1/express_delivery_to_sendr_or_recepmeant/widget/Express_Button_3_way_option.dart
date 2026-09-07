// ignore_for_file: file_names

import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/express_delivery_1/controller/express_controller_1.dart';
import 'package:ZipBee/features/user/express_delivery_1/widget/one_way_round_functionality.dart';
import 'package:ZipBee/features/user/express_delivery_1/widget/select_location_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpressButtonWidget3Address extends StatelessWidget {
  const ExpressButtonWidget3Address({super.key, required this.controller});

  final ExpressDeliveryMain controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isRound = controller.isRoundTrip.value;

      return Container(
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

            SizedBox(height: 16),
            isRound
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Divider(),

                      CustomAddButton(),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        title: 'Return address (Athena Lin)',
                        subtitle: 'Blk 657 Ang Mo Kio Ave 9, S560657',
                        icon: Image.asset(
                          IconPath.collectIcon,
                          width: 14,
                          height: 14,
                        ),
                      ),

                      Divider(),

                      CustomAddButton(),
                    ],
                  ),
          ],
        ),
      );
    });
  }
}
