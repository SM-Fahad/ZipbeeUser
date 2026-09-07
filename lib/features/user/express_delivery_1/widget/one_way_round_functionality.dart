import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/features/user/collect_form_on_express_delivery/controller/collect_form_controller.dart';
import 'package:ZipBee/features/user/collect_form_on_express_delivery/screen/collect_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/express_controller_1.dart';

class OneWayRoundWidget extends StatelessWidget {
  final ExpressDeliveryMain controller;
  final String title;
  final String subtitle;
  final Widget icon;

  const OneWayRoundWidget({
    super.key,
    required this.controller,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = Get.width;

    final RxString currentTitle = title.obs;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon,
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => controller.isEditing.value
                    ? TextField(
                        autofocus: true,
                        controller: TextEditingController(
                          text: currentTitle.value,
                        ),
                        onChanged: (val) => currentTitle.value = val,
                        style: getTextStyle(
                          fontSize: screenWidth * 0.036,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                      )
                    : Text(
                        currentTitle.value,
                        style: TextStyle(
                          fontSize: screenWidth * 0.036,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => GestureDetector(
            onTap: () {
              Get.to(
                () => CollectFormScreen(
                  controller: Get.put(CollectFormController()),
                ),
              );
            },
            child: Icon(
              controller.isEditing.value ? Icons.check : Icons.edit,
              color: controller.isEditing.value ? Colors.green : Colors.black,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
