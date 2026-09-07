import 'package:ZipBee/core/common/widgets/custom_button.dart';
import 'package:ZipBee/core/services/contact_picker_service.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/stacked/widget/country_code_text_field.dart';
import 'package:ZipBee/features/user/my_riders/controller/my_riders_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> _pickContact(MyRidersController controller) async {
  final pickedContact = await ContactPickerService.pickPhoneContact();
  if (pickedContact == null) return;
  controller.setContactNumber(pickedContact.phoneNumber);
}

void showAddRiderDialog(MyRidersController controller) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        color: Colors.amber.shade100,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add a favorite rider",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            CountryCodeTextField(
              controller: controller.phoneController,
              label: "Phone number",
              keyboardType: TextInputType.phone,
              selectedCountryCode: controller.selectedCountryCode,
              onCountryCodeChanged: controller.updateCountryCode,
              suffixIcon: IconButton(
                onPressed: () => _pickContact(controller),
                icon: const Icon(Icons.contacts_outlined),
                tooltip: 'Pick from contacts',
              ),
            ),
            const SizedBox(height: 25),
            CustomButton(
                onPressed: controller.addRider, 
                label: 'Add', 
                color: AppColors.primaryButtonColor, 
                textColor: AppColors.primaryFontColor,
                
              ),
          ],
        ),
      ),
    ),
  );
}
