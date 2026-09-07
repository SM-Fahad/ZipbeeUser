import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/features/user/collect_form_on_express_delivery/Sender_Part/screen_sender/sender_screen.dart';
import 'package:ZipBee/features/user/express_delivery_1/controller/express_controller_1.dart';
import 'package:ZipBee/features/user/express_delivery_1/widget/express_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

class SelectLocationWidget extends StatelessWidget {
  const SelectLocationWidget({super.key, required this.controller});

  final ExpressDeliveryMain controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ExpressButtonWidget(controller: controller),
          SizedBox(height: 10),
          Divider(),
          CustomAddButton(),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class CustomAddButton extends StatelessWidget {
   CustomAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[100],
          foregroundColor: Colors.black,

          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(Icons.add),
        label: Text(
          "Add Stop",
          style: getTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        onPressed: () {
          Get.to(SenderView());
        },
      ),
    );
  }
}
