import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/features/user/collect_form_on_express_delivery/Sender_Part/controller_sender/sender_controller.dart';
import 'package:ZipBee/features/user/collect_form_on_express_delivery/Sender_Part/widget_sender/text_filed_widget.dart';
import 'package:ZipBee/features/user/google_map/widget/google_map_widget.dart';
import 'package:ZipBee/features/user/express_delivery_1/controller/express_controller_1.dart';
import 'package:ZipBee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecipientView extends StatelessWidget {
  const RecipientView({super.key});

  @override
  Widget build(BuildContext context) {
    final SenderController controller = Get.put(SenderController());
    final ExpressDeliveryMain locationController =
        Get.find<ExpressDeliveryMain>();

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 240,
              width: double.infinity,
              child: GoogleMapWidget(
                mode: GoogleMapWidgetMode.addressPicker,
                initialQuery: controller.postalCodeController.text.isNotEmpty
                    ? controller.postalCodeController.text
                    : controller.addressController.text,
                onLocationConfirmed: controller.applyResolvedLocation,
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
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
                  const SizedBox(height: 10),

                  CustomTextField(
                    controller: controller.postalCodeController,
                    label: "Postal Code*",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),

                  CustomTextField(
                    controller: controller.addressController,
                    label: "Address*",
                  ),
                  const SizedBox(height: 10),

                  CustomTextField(
                    controller: controller.floorController,
                    label: "Floor or unit no.*",
                  ),
                  const SizedBox(height: 10),

                  CustomTextField(
                    controller: controller.nameController,
                    label: "Contact name*",
                  ),
                  const SizedBox(height: 10),

                  CustomTextField(
                    controller: controller.numberController,
                    label: "Contact number*",
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Obx(
                        () => Checkbox(
                          value: controller.saveAddress.value,
                          onChanged: (v) =>
                              controller.saveAddress.value = v ?? false,
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
                  const SizedBox(height: 26),

                  /// ✅ CONFIRM
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isFormValid.value
                            ? () {
                                locationController.setReceiver(
                                  name: controller.nameController.text,
                                  address: controller.addressController.text,
                                );

                                Get.toNamed(AppRoutes.getexpressDelivery1());

                                controller.clearForm();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.isFormValid.value
                              ? Colors.yellow.shade700
                              : Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }
}
