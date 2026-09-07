import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PromoDialogContent extends StatelessWidget {
  final TextEditingController promoController = TextEditingController();

  PromoDialogContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: promoController,
          decoration: InputDecoration(
            hintText: "AZN07",
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.0),
              child: Image.asset(IconPath.promo, width: 24, height: 24),
            ),
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
        SizedBox(height: 40),
        FilledButton(
          onPressed: () {
            Get.back();
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            'Apply',
            style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
