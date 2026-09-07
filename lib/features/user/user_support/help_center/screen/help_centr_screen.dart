import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/user_support/help_center/controller/help_center_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpCentrScreen extends StatelessWidget {
  const HelpCentrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HelpCenterController());

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroungColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Help Center',
          style: getTextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.options.length,
                separatorBuilder: (_, __) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final option = controller.options[index];
                  final leadingIcon = option.icon is IconData
                      ? Icon(
                          option.icon as IconData,
                          size: 24,
                          color: Colors.black,
                        )
                      : Image.asset(
                          option.icon as String,
                          width: 24,
                          height: 24,
                          color: Colors.black,
                        );
                  return Material(
                    color: Colors.white,
                    child: ListTile(
                      onTap: option.onTap,
                      tileColor: Colors.white,
                      leading: leadingIcon,
                      title: Text(
                        option.title,
                        style: getTextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        option.description,
                        style: getTextStyle(fontSize: 10),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}
