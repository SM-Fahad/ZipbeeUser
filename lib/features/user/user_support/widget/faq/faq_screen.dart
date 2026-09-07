import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/api_end_point/api_end_point.dart';
import '../../../../../core/shared_prefference_service/shared_pref.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FaqController>(
      init: FaqController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.backgroungColor,
          appBar: AppBar(
            backgroundColor: AppColors.backgroungColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'FAQ',
              style: getTextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
          ),
          body: _buildBody(controller),
        );
      },
    );
  }

  Widget _buildBody(FaqController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.faqList.isEmpty) {
      return Center(
        child: Text(
          'No FAQs available',
          style: getTextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: controller.faqList.length,
      itemBuilder: (context, index) {
        final faq = controller.faqList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              title: Text(
                faq.question,
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Text(
                    faq.answer,
                    style: getTextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FaqController extends GetxController {
  bool isLoading = false;
  List<FaqModel> faqList = [];

  @override
  void onInit() {
    fetchFaqs();
    super.onInit();
  }

  Future<void> fetchFaqs() async {
    try {
      isLoading = true;
      update();

      final role = await SharedPreferencesHelper.getSelectedRole() ?? 'USER';
      final token = await SharedPreferencesHelper.getAccessToken();

      debugPrint("Logged in role for FAQ: $role");

      final response = await GetConnect().get(
        '${ApiEndPoint.faqRole}?faq_for=$role',
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint("FAQ Response Status: ${response.statusCode}");
      debugPrint("FAQ Response Body: ${response.body}");

      if (response.statusCode == 200) {
        dynamic body = response.body;
        List<dynamic> dataList = [];

        // Check if the response is a Map containing 'data' or a direct List
        if (body is Map && body.containsKey('data')) {
          dataList = body['data'] as List;
        } else if (body is List) {
          dataList = body;
        }

        faqList = dataList.map((e) => FaqModel.fromJson(e)).toList();

        for (var faq in faqList) {
          debugPrint("FAQ Loaded: ${faq.question}");
        }
      } else {
        debugPrint("FAQ API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("FAQ Exception: $e");
    } finally {
      isLoading = false;
      update();
    }
  }
}

class FaqModel {
  final int id;
  final String question;
  final String answer;
  final String faqFor;
  final bool isActive;

  FaqModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.faqFor,
    required this.isActive,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      faqFor: json['faq_for'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }
}
