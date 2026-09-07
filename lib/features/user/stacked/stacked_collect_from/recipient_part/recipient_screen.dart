import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/core/utils/constants/image_path.dart';
import 'package:ZipBee/features/user/collect_form_on_express_delivery/Sender_Part/controller_sender/sender_controller.dart';
import 'package:ZipBee/features/user/collect_form_on_express_delivery/Sender_Part/widget_sender/text_filed_widget.dart';
import 'package:ZipBee/features/user/express_delivery_1/express_delivery_to_sendr_or_recepmeant/screen/express_sender_or_recepmeant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/model.dart';

class StackedRecipientView extends StatelessWidget {
  final StackedAddressModel address;

  const StackedRecipientView({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    final SenderController controller = Get.put(SenderController());

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// MAP SECTION
              SizedBox(
                height: 240,
                width: double.infinity,
                child: Image.asset(
                  ImagePath.map,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              /// FORM SECTION
              Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recipient 1",
                      style: getTextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
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
                      suffixIcon: Icon(Icons.person_outline),
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: controller.numberController,
                      label: "Contact number*",
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Obx(
                              () => Checkbox(
                            value: controller.saveAddress.value,
                            onChanged: (value) =>
                            controller.saveAddress.value = value ?? false,
                          ),
                        ),
                        Text(
                          "Save this address",
                          style: getTextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
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
                              ? () {
                            Get.to(ExpressToSenderOrRecepment());
                            // Get.toNamed(
                            //   AppRoutes.getexpressSenderOrRecepment(),
                            // );
                          }
                              : null,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
