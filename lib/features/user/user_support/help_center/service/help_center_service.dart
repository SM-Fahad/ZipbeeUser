import 'dart:convert';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:ZipBee/features/user/user_support/help_center/model/about_us_model.dart';
import 'package:ZipBee/features/user/user_support/help_center/model/content_management_model.dart';
import 'package:ZipBee/features/user/user_support/help_center/model/help_article_model.dart';
import 'package:http/http.dart' as http;

class HelpCenterService {
  /// Fetch About Us data from API
  Future<AboutUsResponse?> fetchAboutUs() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final headers = {
        'accept': '*/*',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse(ApiEndPoint.aboutUs),
        headers: headers,
      );

      print('About Us Response: ${response.statusCode}');
      print('About Us Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final aboutUsResponse = AboutUsResponse.fromJson(json);

        // Filter by faq_for == USER
        final userAboutUs = aboutUsResponse.data
            .where((item) => item.faqFor.toUpperCase() == 'USER')
            .toList();

        return AboutUsResponse(
          success: aboutUsResponse.success,
          message: aboutUsResponse.message,
          data: userAboutUs,
        );
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception in fetchAboutUs: $e');
      return null;
    }
  }

  /// Fetch Help Articles from API
  Future<HelpArticleResponse?> fetchHelpArticles() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final headers = {
        'accept': '*/*',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse(ApiEndPoint.helpArticles),
        headers: headers,
      );

      print('Help Articles Response: ${response.statusCode}');
      print('Help Articles Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final articleResponse = HelpArticleResponse.fromJson(json);

        // Filter by faq_for == USER
        final userArticles = articleResponse.data
            .where((item) => item.faqFor.toUpperCase() == 'USER')
            .toList();

        return HelpArticleResponse(
          success: articleResponse.success,
          message: articleResponse.message,
          data: userArticles,
        );
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception in fetchHelpArticles: $e');
      return null;
    }
  }

  /// Fetch Content Management data from API
  Future<ContentManagementResponse?> fetchContentManagement() async {
    try {
      final headers = {'accept': '*/*'};

      final response = await http.get(
        Uri.parse(ApiEndPoint.contentManagement),
        headers: headers,
      );

      print('Content Management Response: ${response.statusCode}');
      print('Content Management Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final contentResponse = ContentManagementResponse.fromJson(json);

        // Filter by faq_for == USER
        final userContent = contentResponse.data
            .where((item) => item.faqFor.toUpperCase() == 'USER')
            .toList();

        return ContentManagementResponse(
          success: contentResponse.success,
          message: contentResponse.message,
          data: userContent,
        );
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception in fetchContentManagement: $e');
      return null;
    }
  }
}
