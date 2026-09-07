import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/auth/verification/controller/verification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';


class VerifyButton extends StatelessWidget {
  const VerifyButton({
    super.key,
    required this.controller,
    required this.media,
  });

  final VerificationController controller;
  final MediaQueryData media;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canVerify = controller.canVerify;
      final isVerifying = controller.isVerifying.value;
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canVerify ? controller.verifyCode : null,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: media.size.height * 0.02),
            backgroundColor: canVerify
                ? AppColors.primaryButtonColor
                // ignore: deprecated_member_use
                : AppColors.primaryButtonColor.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isVerifying
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Verify',
                  style: getTextStyle(
                    color: Colors.black,
                    fontSize: media.size.width * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      );
    });
  }
}
