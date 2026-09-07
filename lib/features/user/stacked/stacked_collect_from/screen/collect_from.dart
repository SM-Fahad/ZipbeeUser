import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ZipBee/features/user/stacked/schedule_stacked_ delivey/Schedule_sender_recepent/screen/schedule_sender_screen.dart';
import 'package:ZipBee/features/user/stacked/schedule_stacked_ delivey/Schedule_recepent/screen/schedule_recepent_screen1.dart';

import '../controller/controller.dart';
import '../widget/address_list_widget.dart';
import '../widget/build_filter_chips.dart';

class StackedCollectFormScreen extends StatelessWidget {
  final StackedCollectFormController controller;
  final String? addressType; // 'SENDER' or 'RECEIVER'

  const StackedCollectFormScreen({
    super.key,
    required this.controller,
    this.addressType,
  });

  String get appBarTitle {
    // If addressType is provided, use it to determine title
    if (addressType == 'RECEIVER') {
      return "Deliver To";
    }
    // Default to "Collect From" for SENDER or when not specified
    return "Collect From";
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeWithAddressType(addressType);
    });
    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: getTextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(height: 12),
            StackedFilterChipsWidget(
              controller: controller,
              onNewTap: () {
                if (addressType == 'RECEIVER') {
                  Get.to(() => const StackedSchedulRecepmenteScreen());
                } else {
                  Get.to(() => const StackedSenderScheduleScreen());
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StackedAddressListWidget(
                controller: controller,
                addressType: addressType,
              ),
            ),
            SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }

  // Used for CustomButton 'Add' action. Don't Delete. 
  // ignore: unused_element
  void _navigateToAddScreen(String type) {
    // This will be handled in address_list_widget by checking type
    if (type == 'RECEIVER') {
      // Navigate to recipient schedule screen
      Get.to(() {
        // Import required
        return Container(); // Placeholder
      });
    } else {
      // Navigate to sender schedule screen
      Get.to(() {
        return Container(); // Placeholder
      });
    }
  }
}
