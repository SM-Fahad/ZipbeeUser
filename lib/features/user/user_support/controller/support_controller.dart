import 'dart:convert';
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/user_support/help_center/screen/help_centr_screen.dart';
import 'package:ZipBee/features/user/user_support/support_chat_screen/screen/support_chat_screen.dart';
import 'package:ZipBee/features/user/user_support/model/support_option_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/shared_prefference_service/shared_pref.dart';

class SupportController extends GetxController {
  final options = <SupportOption>[].obs;

  final String apiUrl = ApiEndPoint.supportContact;

  String serviceEmail = '';
  String serviceNumber = '';

  @override
  void onInit() {
    super.onInit();
    checkAuthorizationAndFetch();
  }

  /// Check if user is authorized before calling API
  Future<void> checkAuthorizationAndFetch() async {
    final isLoggedIn = await SharedPreferencesHelper.isLoggedIn();
    if (!isLoggedIn) {
      // User not authorized, fallback to default options
      loadSupportOptions();
      return;
    }

    final token = await SharedPreferencesHelper.getAccessToken();
    if (token == null || token.isEmpty) {
      loadSupportOptions();
      return;
    }

    // Fetch from API
    fetchSupportContacts(token);
  }

  /// Fetch phone/email from API
  Future<void> fetchSupportContacts(String token) async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final data = body['data'];

        if (data != null) {
          serviceEmail = data['service_email']?.toString() ?? '';
          serviceNumber = data['service_number']?.toString() ?? '';
        }

        loadSupportOptions();
      } else {
        EasyLoading.showError(
          'Failed to load support info: ${response.statusCode}',
        );
        loadSupportOptions(); // fallback
      }
    } catch (e) {
      print('Exception: $e');
      EasyLoading.showError('Something went wrong');
      loadSupportOptions(); // fallback
    }
  }

  /// Populate support options
  void loadSupportOptions() {
    options.assignAll([
      SupportOption(
        title: 'Chat with us',
        description:
            'Get help with orders or account related issue, available 24/7',
        icon: IconPath.send,
        onTap: () => Get.to(() => ChatScreen()),
      ),
      SupportOption(
        title: 'Call us',
        description: serviceNumber.isNotEmpty ? serviceNumber : '+4448949894',
        icon: IconPath.call,
        onTap: () async {
          final numberToCall = serviceNumber.isNotEmpty
              ? serviceNumber
              : '+4448949894';
          final Uri launchUri = Uri(scheme: 'tel', path: numberToCall);
          if (await canLaunchUrl(launchUri)) {
            await launchUrl(launchUri, mode: LaunchMode.externalApplication);
          } else {
            EasyLoading.showError('Could not launch dialer');
          }
        },
      ),
      SupportOption(
        title: 'Send us an email',
        description: serviceEmail.isNotEmpty ? serviceEmail : 'nicho@gmail.com',
        icon: IconPath.email,
        onTap: () async {
          final emailToUse = serviceEmail.isNotEmpty
              ? serviceEmail
              : 'nicho@gmail.com';
          final Uri emailLaunchUri = Uri(
            scheme: 'mailto',
            path: emailToUse,
            query: 'subject=Support Request&body=Hi Support Team,',
          );
          if (await canLaunchUrl(emailLaunchUri)) {
            await launchUrl(
              emailLaunchUri,
              mode: LaunchMode.externalApplication,
            );
          } else {
            EasyLoading.showError('Could not launch email client');
          }
        },
      ),
      // SupportOption(
      //   title: 'FAQ',
      //   description: 'Get quick help from our frequently asked questions',
      //   icon: IconPath.faq,
      //   onTap: () => Get.to(() => const FaqScreen()),
      // ),
      SupportOption(
        title: 'Help Center',
        description: "Here you can get all information about us",
        icon: IconPath.faq,
        onTap: () => Get.to(() => const HelpCentrScreen()),
      ),
    ]);
  }
}
