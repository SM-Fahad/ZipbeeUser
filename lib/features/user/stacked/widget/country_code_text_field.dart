import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CountryCodeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final RxString selectedCountryCode;
  final ValueChanged<String> onCountryCodeChanged;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const CountryCodeTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.selectedCountryCode,
    required this.onCountryCodeChanged,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 104,
                child: Obx(
                  () => CountryCodePicker(
                    onChanged: (country) {
                      onCountryCodeChanged(country.dialCode ?? '+65');
                    },
                    initialSelection: selectedCountryCode.value,
                    favorite: const ['+65'],
                  ),
                ),
              ),
              Container(width: 1, height: 32, color: Colors.grey.shade400),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    suffixIcon: suffixIcon,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
