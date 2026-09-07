import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentOption {
  final String title;
  final String subtitle;
  final String? imageAsset;

  PaymentOption({required this.title, required this.subtitle, this.imageAsset});
}

// Payment Controller
class PaymentController extends GetxController {
  var selectedIndex = 0.obs;
  var selectedTitle = "Select".obs;
}

// Payment Selection Widget
class PaymentSelectionWidget extends StatelessWidget {
  final List<PaymentOption> options;
  final PaymentController controller;

  const PaymentSelectionWidget({
    super.key,
    required this.options,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.asMap().entries.map((entry) {
        int index = entry.key;
        PaymentOption option = entry.value;

        return Column(
          children: [
            Obx(
              () => ListTile(
                leading: option.imageAsset != null
                    ? Image.asset(option.imageAsset!, width: 32, height: 32)
                    : Image.asset(IconPath.arrowBackIcon),
                title: Text(
                  option.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  option.subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: GestureDetector(
                  onTap: () {
                    controller.selectedIndex.value = index;
                    controller.selectedTitle.value = option.title;
                    Get.back();
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: controller.selectedIndex.value == index
                            ? Colors.yellow
                            : Colors.black,
                        width: 2,
                      ),
                    ),
                    child: controller.selectedIndex.value == index
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.yellow,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                onTap: () {
                  controller.selectedIndex.value = index;
                  controller.selectedTitle.value = option.title;
                  Get.back();
                },
              ),
            ),
            if (index != options.length - 1) Divider(height: 1),
          ],
        );
      }).toList(),
    );
  }
}

class PaymentMethodSelector extends StatelessWidget {
  final List<PaymentOption> options;
  final PaymentController controller = Get.put(PaymentController());

  PaymentMethodSelector({super.key, required this.options});

  void openSelectorSheet() {
    Get.bottomSheet(
      Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PaymentSelectionWidget(options: options, controller: controller),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: openSelectorSheet,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade500),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Obx(
              () => Text(
                controller.selectedTitle.value,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}
