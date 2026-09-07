import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/services/contact_picker_service.dart';
import 'package:ZipBee/features/user/collect_form_on_express_delivery/Sender_Part/widget_sender/text_filed_widget.dart';
import 'package:ZipBee/features/user/stacked/schedule_stacked_%20delivey/Schedule_recepent/controller/recepent_controller.dart';
import 'package:ZipBee/features/user/stacked/stacked_collect_from/model/model.dart';
import 'package:ZipBee/features/user/stacked/widget/country_code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// This widget uses RecipientController (not SenderController from sender_part)
class ScheduleRecipientWidgetST extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final StackedAddressModel? address;
  final bool isAdditionalStop;

  const ScheduleRecipientWidgetST({
    super.key,
    required this.title,
    required this.onPressed,
    this.address,
    this.isAdditionalStop = false,
  });

  Future<void> _pickContact(RecipientController controller) async {
    final pickedContact = await ContactPickerService.pickPhoneContact();
    if (pickedContact == null) return;

    if (pickedContact.name.isNotEmpty) {
      controller.nameController.text = pickedContact.name;
    }
    controller.setContactNumber(pickedContact.phoneNumber);
    controller.validateForm();
  }

  @override
  Widget build(BuildContext context) {
    // Use a unique tag for additional stop to get a fresh controller instance
    final String controllerTag = isAdditionalStop
        ? 'additional_stop'
        : 'primary';
    final controller = Get.isRegistered<RecipientController>(tag: controllerTag)
        ? Get.find<RecipientController>(tag: controllerTag)
        : Get.put(RecipientController(), tag: controllerTag);

    // Initialize controller on first build with proper separation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeController(controller);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: getTextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),

        // Container(
        //   width: double.infinity,
        //   padding: const EdgeInsets.all(12),
        //   decoration: BoxDecoration(
        //     color: const Color(0xFFFFF8E1),
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   child: Row(
        //     children: [
        //       Icon(Icons.map_outlined, color: Colors.amber.shade800, size: 18),
        //       const SizedBox(width: 8),
        //       Expanded(
        //         child: Text(
        //           'Use the map above to search by postal code, building, or road and auto-fill the address.',
        //           style: getTextStyle(fontSize: 12, color: Colors.black87),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        // SizedBox(height: 12),

        // CustomTextField(
        //   controller: controller.postalCodeController,
        //   label: "Postal Code*",
        // ),
        // SizedBox(height: 10),
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
          suffixIcon: IconButton(
            onPressed: () => _pickContact(controller),
            icon: const Icon(Icons.contacts_outlined),
            tooltip: 'Pick from contacts',
          ),
        ),
        SizedBox(height: 10),

        CountryCodeTextField(
          controller: controller.numberController,
          label: "Contact number*",
          keyboardType: TextInputType.phone,
          selectedCountryCode: controller.selectedCountryCode,
          onCountryCodeChanged: controller.updateCountryCode,
        ),
        SizedBox(height: 10),

        CustomTextField(
          controller: controller.noteController,
          label: "Note to driver",
          maxLines: 2,
          maxLength: 120,
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
              onPressed: controller.isFormValid.value ? onPressed : null,
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

  /// Initialize controller after widget build is complete
  void _initializeController(RecipientController controller) {
    if (isAdditionalStop) {
      // For additional stops, clear all fields
      controller.addressController.clear();
      controller.postalCodeController.clear();
      controller.floorController.clear();
      controller.nameController.clear();
      controller.selectedCountryCode.value = '+65';
      controller.numberController.clear();
      controller.noteController.clear();
      controller.saveAddress.value = false;
      controller.validateForm();
    } else if (address != null) {
      // For primary recipient, prefill if address provided
      if (controller.addressController.text.isEmpty) {
        controller.addressController.text = address!.addressFromApr.isNotEmpty
            ? address!.addressFromApr
            : address!.address;
      }
      if (controller.floorController.text.isEmpty) {
        controller.floorController.text = address!.floorUnit;
      }
      if (controller.nameController.text.isEmpty) {
        controller.nameController.text = address!.contactName;
      }
      if (controller.numberController.text.isEmpty) {
        controller.setContactNumber(address!.contactNumber);
      }
      controller.saveAddress.value = address!.isSaved;
      controller.validateForm();
    }
  }
}
