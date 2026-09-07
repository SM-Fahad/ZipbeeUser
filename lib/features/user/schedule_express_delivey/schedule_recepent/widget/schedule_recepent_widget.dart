import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/features/user/collect_form_on_express_delivery/Sender_Part/controller_sender/sender_controller.dart';
import 'package:ZipBee/features/user/collect_form_on_express_delivery/Sender_Part/widget_sender/text_filed_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ScheduleRecipientWidget extends StatelessWidget {
  final String title;
  final VoidCallback onPressed; // Add this

  const ScheduleRecipientWidget({
    super.key,
    required this.title,
    required this.onPressed, // Require it
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SenderController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: getTextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),

        CustomTextField(
          controller: controller.addressController,
          label: "Address*",
        ),
        SizedBox(height: 10),

        CustomTextField(
          controller: controller.floorController,
          label: "Floor or unit no.*",
          maxLines: 1,
          maxLength: 120,
        ),
        SizedBox(height: 10),

        CustomTextField(
          controller: controller.nameController,
          label: "Contact name*",
        ),
        SizedBox(height: 10),

        CustomTextField(
          controller: controller.numberController,
          label: "Contact number*",
          suffixIcon: Icon(Icons.person_outline),
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 10),

        Row(
          children: [
            Obx(
              () => Checkbox(
                value: controller.saveAddress.value,
                onChanged: (v) => controller.saveAddress.value = v ?? false,
              ),
            ),
            Text(
              "Save this address",
              style: getTextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
        SizedBox(height: 26),

        /// CONFIRM BUTTON
        Obx(
          () => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isFormValid.value
                  ? onPressed
                  : null, // <-- use parent callback
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.isFormValid.value
                    ? Colors.yellow.shade700
                    : Colors.grey.shade300,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Confirm",
                style: getTextStyle(
                  fontSize: 18,
                  color: controller.isFormValid.value
                      ? Colors.black
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
