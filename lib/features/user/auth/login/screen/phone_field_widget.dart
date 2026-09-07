
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/auth/login/controller/login_signup_controller.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

class PhoneField extends StatelessWidget {
  const PhoneField({super.key, required this.controller});
  final LoginSignupController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.subtitleFontColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CountryCodePicker(
            onChanged: (country) {
              controller.selectedCountryCode.value = country.dialCode ?? '+65';
            },
            initialSelection: 'SG',
            favorite: const ['+65'],
          ),
          Container(width: 1, height: 32, color: Colors.grey.shade400),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Enter phone number',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}