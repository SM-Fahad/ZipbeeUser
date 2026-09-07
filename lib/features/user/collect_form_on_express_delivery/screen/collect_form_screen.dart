import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/collect_form_on_express_delivery/widget/address_list_widget.dart';
import 'package:ZipBee/features/user/collect_form_on_express_delivery/widget/build_filter_chips.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/collect_form_controller.dart';

class CollectFormScreen extends StatelessWidget {
  final CollectFormController controller;

  const CollectFormScreen({super.key, required this.controller});

  String get appBarTitle {
    switch (controller.selectedFilterIndex.value) {
      case 0:
        return "Collect From";
      case 1:
        return "Deliver to";
      case 2:
        return "Deliver to";
      default:
        return "Collect From";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.backgroungColor,
        appBar: AppBar(
          title: Text(
            appBarTitle,
            style: getTextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              FilterChipsWidget(controller: controller),
              SizedBox(height: 20),
              AddressListWidget(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
