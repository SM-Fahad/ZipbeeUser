import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/core/utils/constants/image_path.dart';
import 'package:ZipBee/features/user/auth/login/controller/login_signup_controller.dart';
import 'package:ZipBee/features/user/auth/login/screen/phone_field_widget.dart';
import 'package:ZipBee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginSignupScreen extends StatelessWidget {
  const LoginSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginSignupController(), permanent: true);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => controller.clearFields(),
    );

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Image.asset(
            ImagePath.backgroundImage,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                elevation: 3.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Obx(() {
                    final isLogin = controller.isLogin.value;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          isLogin ? 'Welcome Back!' : 'Welcome!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLogin
                              ? 'Log in to continue delivering with ease.'
                              : 'Sign up to continue delivering with ease.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.subtitleFontColor,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Toggle Login / Signup
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.fromLTRB(
                            isLogin ? 6 : 12,
                            6,
                            isLogin ? 12 : 6,
                            6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.subtitleFontColor,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => controller.isLogin.value = true,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isLogin
                                        ? AppColors.primaryButtonColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Login',
                                    style: getTextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => controller.isLogin.value = false,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !isLogin
                                        ? AppColors.primaryButtonColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Sign Up',
                                    style: getTextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Animated Login / Signup Fields
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 0.2),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: isLogin
                              ? buildLoginFields(controller)
                              : buildSignupFields(controller),
                        ),
                        const SizedBox(height: 30),

                        // Button
                        ElevatedButton(
                          onPressed: () => controller.submit(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryButtonColor,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isLogin ? 'Login' : 'Continue',
                            style: getTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Login Fields --------------------
  Widget buildLoginFields(LoginSignupController controller) {
    return Column(
      key: const ValueKey('loginFields'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Enter Email, Phone or Username",
          style: getTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.subtitleFontColor,
          ),
        ),
        const SizedBox(height: 5),
        buildTextField(
          controller.emailController,
          'Email, Phone or Username',
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 10),
        Text(
          "Enter your password",
          style: getTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.subtitleFontColor,
          ),
        ),
        const SizedBox(height: 5),
        buildPasswordField(
          controller.passwordController,
          controller.isLoginPasswordVisible,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.forgotPasswordScreen),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Forgot Password?",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onboardingIndicatorActive,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primaryButtonColor,
                decorationThickness: 2.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // -------------------- Signup Fields --------------------
  Widget buildSignupFields(LoginSignupController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      key: const ValueKey('signupFields'),
      children: [
        Text(
          "Enter your user name",
          style: getTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.subtitleFontColor,
          ),
        ),
        const SizedBox(height: 5),
        buildTextField(controller.nameController, 'User Name'),
        const SizedBox(height: 10),

        Text(
          "Enter your email address",
          style: getTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.subtitleFontColor,
          ),
        ),
        const SizedBox(height: 5),
        buildTextField(
          controller.emailController,
          'Email address',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),

        Text(
          "Enter your phone number",
          style: getTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.subtitleFontColor,
          ),
        ),
        SizedBox(height: 5),
        PhoneField(controller: controller),
        // buildTextField(
        //   controller.phoneController,
        //   'Phone Number',
        //   keyboardType: TextInputType.phone,
        // ),
        const SizedBox(height: 10),

        Text(
          "Referral Code (Optional)",
          style: getTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.subtitleFontColor,
          ),
        ),
        const SizedBox(height: 5),
        buildTextField(controller.referralCodeController, 'Referral Code'),
        const SizedBox(height: 10),

        Text(
          "Create a password",
          style: getTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.subtitleFontColor,
          ),
        ),
        SizedBox(height: 5),
        buildPasswordField(
          controller.passwordController,
          controller.isSignUpPasswordVisible,
          'Enter your password',
        ),
        const SizedBox(height: 10),

        Text(
          "Confirm your password",
          style: getTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.subtitleFontColor,
          ),
        ),
        SizedBox(height: 5),
        buildPasswordField(
          controller.confirmPasswordController,
          controller.isConfirmPasswordVisible,
          'Confirm your password',
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Password Field
  Widget buildPasswordField(
    TextEditingController controller,
    RxBool isVisible, [
    String hint = 'Password',
  ]) {
    return Obx(() {
      return Container(
        height: 52,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.subtitleFontColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: controller,
          obscureText: !isVisible.value,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            isDense: true,
            suffixIcon: IconButton(
              icon: Icon(
                isVisible.value ? Icons.visibility : Icons.visibility_off,
                size: 20,
              ),
              onPressed: () => isVisible.value = !isVisible.value,
            ),
          ),
        ),
      );
    });
  }

  // Generic Text Field
  Widget buildTextField(
    TextEditingController controller,
    String hintText, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 52,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.subtitleFontColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            isDense: true,
          ),
        ),
      ),
    );
  }
}
