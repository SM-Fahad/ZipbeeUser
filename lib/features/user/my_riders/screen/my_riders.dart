import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/my_riders_controller.dart';
import '../widgets/my_riders_widget.dart';

class MyRidersScreen extends StatelessWidget {
  const MyRidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyRidersController());

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'My Riders',
          style: getTextStyle(
            fontSize: 20,
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RidersListWidget(controller: controller),
    );
  }
}
