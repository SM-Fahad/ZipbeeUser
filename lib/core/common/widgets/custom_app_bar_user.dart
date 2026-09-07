import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBarUser extends StatelessWidget {
  final String title;
  final Widget? action;
  final VoidCallback? onTap;

  const CustomAppBarUser({
    required this.title,
    this.action,
    this.onTap,
    super.key,
    required TextStyle style,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onTap ?? Get.back,
            child: Icon(Icons.arrow_back_ios, size: 18),
          ),

          Center(
            child: Text(
              title,
              style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),

          action ?? SizedBox(width: 18),
        ],
      ),
    );
  }
}
