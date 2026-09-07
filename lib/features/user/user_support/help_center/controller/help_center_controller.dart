import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/user_support/help_center/model/help_center_option_model.dart';
import 'package:ZipBee/features/user/user_support/help_center/screen/help_center_pages/about_us_screen.dart';
import 'package:ZipBee/features/user/user_support/help_center/screen/help_center_pages/cancellation_policy_screen.dart';
import 'package:ZipBee/features/user/user_support/help_center/screen/help_center_pages/dispute_screen.dart';
import 'package:ZipBee/features/user/user_support/help_center/screen/help_center_pages/help_articles_screen.dart';
import 'package:ZipBee/features/user/user_support/help_center/screen/help_center_pages/privacy_policy_screen.dart';
import 'package:ZipBee/features/user/user_support/help_center/screen/help_center_pages/terms_conditions_screen.dart';
import 'package:ZipBee/features/user/user_support/widget/faq/faq_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpCenterController extends GetxController {
  final options = <HelpCenterOption>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHelpCenterOptions();
  }

  /// Populate help center options
  void loadHelpCenterOptions() {
    options.assignAll([
      HelpCenterOption(
        title: 'Support & Dispute',
        description: 'If any complain, create dispute',
        icon: IconPath.supportIcon,
        onTap: () => Get.to(() => const DisputeScreen()),
      ),
      HelpCenterOption(
        title: 'Terms & Conditions',
        description: 'Read our terms and conditions',
        icon: Icons.rule,
        onTap: () => Get.to(() => const TermsConditionsScreen()),
      ),
      HelpCenterOption(
        title: 'Privacy Policy',
        description: 'Learn about how we protect your data',
        icon: IconPath.account,
        onTap: () => Get.to(() => const PrivacyPolicyScreen()),
      ),
      HelpCenterOption(
        title: 'Cancellation & Waiting Policy',
        description: 'Understand our cancellation and waiting policies',
        icon: Icons.policy_outlined,
        onTap: () => Get.to(() => const CancellationPolicyScreen()),
      ),
      HelpCenterOption(
        title: 'FAQ List',
        description: 'Get quick help from our frequently asked questions',
        icon: IconPath.faq,
        onTap: () => Get.to(() => const FaqScreen()),
      ),
      HelpCenterOption(
        title: 'Help Articles List',
        description: 'Browse helpful articles and guides',
        icon: IconPath.message,
        onTap: () => Get.to(() => const HelpArticlesScreen()),
      ),
      HelpCenterOption(
        title: 'About Us',
        description: 'Learn more about ZipBee',
        icon: IconPath.call,
        onTap: () => Get.to(() => const AboutUsScreen()),
      ),
    ]);
  }
}
