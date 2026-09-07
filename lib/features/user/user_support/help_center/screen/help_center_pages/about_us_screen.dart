import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/user_support/help_center/screen/help_center_pages/about_us_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Delete previous controller instance and create new one
    Get.delete<AboutUsController>(force: true);
    final controller = Get.put(AboutUsController());

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroungColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'About Us',
          style: getTextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.aboutUsData.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.aboutUsData.isEmpty) {
          return Center(
            child: Text('No data available', style: getTextStyle(fontSize: 14)),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: controller.aboutUsData.map((item) {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: getTextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(item.content, style: getTextStyle(fontSize: 14)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }),
    );
  }
}
