import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ZipBee/features/user/stacked/schedule_stacked_ delivey/Schedule_sender_recepent/screen/schedule_sender_screen.dart';
import 'package:ZipBee/features/user/stacked/schedule_stacked_ delivey/Schedule_recepent/screen/schedule_recepent_screen1.dart';

import '../controller/controller.dart';

class StackedAddressListWidget extends StatelessWidget {
  final StackedCollectFormController controller;
  final String? addressType; // 'SENDER' or 'RECEIVER'

  const StackedAddressListWidget({
    super.key,
    required this.controller,
    this.addressType,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (controller.addressList.isEmpty) {
        return Center(child: Text("No addresses found."));
      }

      return ListView.separated(
        itemCount: controller.addressList.length,
        itemBuilder: (context, index) {
          final address = controller.addressList[index];

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: address.iconPath.isNotEmpty
                ? Image.asset(
              address.iconPath,
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.location_on),
            )
                : SizedBox(width: 24, height: 24),
            title: Text(
              address.title,
              style: getTextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              address.subtitle,
              style: getTextStyle(color: Colors.grey.shade600),
            ),
            onTap: () {
              // Route based on addressType
              if (addressType == 'RECEIVER') {
                Get.off(() => StackedSchedulRecepmenteScreen(address: address));
              } else {
                // Default to SENDER
                Get.off(() => StackedSenderScheduleScreen(address: address));
              }
            },
          );
        },
        separatorBuilder: (context, index) => Divider(),
      );
    });
  }
}
