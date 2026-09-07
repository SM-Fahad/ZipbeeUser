import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/auth/verification/controller/verification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class InputBoxField extends StatelessWidget {
  const InputBoxField({
    super.key,
    required this.context,
    required this.controller,
    required this.index,
    required this.screenWidth,
  });

  final BuildContext context;
  final VerificationController controller;
  final int index;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final double boxSize = screenWidth * 0.15;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: SizedBox(
        width: boxSize,
        height: boxSize,
        child: TextField(
          controller: controller.pinControllers[index],
          focusNode: controller.focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          style: getTextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            filled: false,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black54, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.primaryButtonColor,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) => controller.onPinChanged(value, index),
        ),
      ),
    );
  }
}
