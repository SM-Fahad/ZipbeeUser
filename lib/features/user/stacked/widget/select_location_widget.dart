import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/stacked/schedule_stacked_ delivey/Schedule_recepent/screen/schedule_recepent_screen1.dart';
import 'package:ZipBee/features/user/stacked/schedule_stacked_ delivey/Schedule_sender_recepent/screen/schedule_sender_screen.dart';
import 'package:ZipBee/features/user/stacked/widget/stacked_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../stacked_controller/stacked_controller.dart';

class StackedSelectLocationWidget extends StatelessWidget {
  const StackedSelectLocationWidget({super.key, required this.controller});

  final StackedLocationController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      child: Column(
        children: [
          StackedButtonWidget(controller: controller),
          SizedBox(height: 10),
          Divider(),
          StackedCustomAddButton(),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class StackedCustomAddButton extends StatelessWidget {
  const StackedCustomAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[100],
          foregroundColor: Colors.black,

          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
          final loc = Get.find<StackedLocationController>();

          // Case 1: No sender and no recipient
          // Go to sender screen → confirm → go to recipient screen → confirm → back to stacked
          if (loc.senderData.value == null && loc.receiverData.value == null) {
            Get.to(
              () => StackedSenderScheduleScreen(),
              arguments: {'navigateNextToRecipient': true},
            );
            return;
          }

          // Case 2: Has sender, no recipient
          // Go directly to recipient screen → confirm → back to stacked
          if (loc.senderData.value != null && loc.receiverData.value == null) {
            Get.to(
              () => StackedSchedulRecepmenteScreen(),
              arguments: {'addAsStop': true, 'isAdditionalStop': false},
            );
            return;
          }

          // Case 3: Has both sender and recipient
          // Go to recipient screen with blank fields → confirm → add to recipient list
          Get.to(
            () => StackedSchedulRecepmenteScreen(),
            arguments: {'addAsStop': true, 'isAdditionalStop': true},
          );
        },
      ),
    );
  }
}
