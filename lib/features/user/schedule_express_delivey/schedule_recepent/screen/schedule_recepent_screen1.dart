import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/core/utils/constants/image_path.dart';

import 'package:ZipBee/features/user/schedule_express_delivey/Schedule_recepent/screen/schedule_recepent_screen2.dart';
import 'package:ZipBee/features/user/schedule_express_delivey/schedule_recepent/widget/schedule_recepent_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class SchedulRecepmenteScreen extends StatelessWidget {
  final String title;

  const SchedulRecepmenteScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// MAP Section
              SizedBox(
                height: 240,
                width: double.infinity,
                child: Image.asset(ImagePath.map, fit: BoxFit.cover),
              ),

              /// FORM Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: ScheduleRecipientWidget(
                  title: 'Recipient 1',
                  onPressed: () {
                    // Navigate to Screen 2
                    Get.to(
                      () => SchedulRecepmenteScreen2(title: 'Recipient 2'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
