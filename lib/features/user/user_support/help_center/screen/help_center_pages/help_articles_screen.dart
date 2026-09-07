import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/user_support/help_center/screen/help_center_pages/help_articles_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpArticlesScreen extends StatelessWidget {
  const HelpArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Delete previous controller instance and create new one
    Get.delete<HelpArticlesController>(force: true);
    final controller = Get.put(HelpArticlesController());

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroungColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Help Articles',
          style: getTextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.articles.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.articles.isEmpty) {
          return Center(
            child: Text(
              'No articles available',
              style: getTextStyle(fontSize: 14),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: controller.articles.map((article) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.article, color: Colors.black, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              article.title,
                              style: getTextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        article.content,
                        style: getTextStyle(fontSize: 12),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
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
