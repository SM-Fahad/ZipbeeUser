import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/finding_raider/widget/button.dart';
import 'package:ZipBee/features/user/wallet/add_payment_method/controller/add_payment_method_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AddPaymentMethodScreen extends StatelessWidget {
  final String clientSecret;

  AddPaymentMethodScreen({required this.clientSecret, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      AddPaymentMethodController(clientSecret: clientSecret),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroungColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          "Add payment method",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          children: [
            // Card Number Field
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.credit_card, color: Colors.black54),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller.cardNumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Card number",
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: controller.expiryController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "MM/YY",
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: controller.cvvController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "CVV",
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 14),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: Colors.black54),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller.nameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Name on Card",
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Spacer(),

            Obx(
              () => Button(
                buttonText: 'Save Card',
                textColor: AppColors.primaryFontColor,
                backgroundColor: AppColors.primaryButtonColor,
                onPressed: controller.isProcessing.value
                    ? null
                    : () => controller.saveCard(),
              ),
            ),

            SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}
