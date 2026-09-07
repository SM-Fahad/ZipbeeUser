import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/core/utils/constants/image_path.dart';
import 'package:ZipBee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../model/model.dart';
import '../controller/controller.dart';
import '../widget/text_field_widget.dart';

class StackedSenderView extends StatelessWidget {
  final StackedAddressModel address;
  const StackedSenderView({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    final StackedSenderController controller = Get.put(StackedSenderController());

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
                      "Sender",
                      style: getTextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    StackedCustomTextField(
                      controller: controller.addressController,
                      label: "Address*",
                    ),
                    SizedBox(height: 10),
                    StackedCustomTextField(
                      controller: controller.floorController,
                      label: "Floor or unit no.*",
                      maxLines: 1,
                      maxLength: 120,
                    ),
                    SizedBox(height: 10),
                    StackedCustomTextField(
                      controller: controller.nameController,
                      label: "Contact name*",
                      suffixIcon: Icon(Icons.person_outline),
                    ),
                    SizedBox(height: 10),
                    StackedCustomTextField(
                      controller: controller.numberController,
                      label: "Contact number*",
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 10),
                    StackedCustomTextField(
                      controller: controller.noteController,
                      label: "Note to driver",
                      maxLines: 2,
                      maxLength: 120,
                    ),
                    SizedBox(height: 8),
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
                    SizedBox(height: 16),

                    /// CONFIRM BUTTON
                    Obx(
                          () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isFormValid.value
                              ? () {
                            Get.toNamed(
                              AppRoutes.getexpressSenderOrRecepment(),
                            );
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
