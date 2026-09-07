import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/home/controller/home_controller.dart'; // Import HomeController
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:ZipBee/features/user/stacked/stacked_controller/update_details_controller.dart';

class DeliveryTypeDialog extends StatelessWidget {
  const DeliveryTypeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final orderController = Get.find<StackedOrderController>();
    final updateController = Get.put(UpdateDetailsController());
    // Get delivery types from HomeController
    final homeController = Get.find<HomeController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pick your preferred delivery",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Dynamic list from HomeController
              Obx(() {
                if (homeController.isDeliveryLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (homeController.deliveryTypes.isEmpty) {
                  return const Text("No delivery options available");
                }

                return Column(
                  children: homeController.deliveryTypes.map((type) {
                    final normalizedTypeName = type.name.trim().toUpperCase();
                    bool isSelected =
                        orderController.deliveryType.value
                            .trim()
                            .toUpperCase() ==
                        normalizedTypeName;

                    // Logic: Multiplier to Percentage
                    // 0.75 -> 75%
                    double multiplier =
                        double.tryParse(type.priceMultiplier ?? "0") ?? 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryButtonColor.withValues(
                                alpha: 0.1,
                              )
                            // Light highlight
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Colors.amber
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              type.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (type.iconPath != null) ...[
                              const SizedBox(width: 6),
                              Image.asset(
                                type.iconPath!,
                                height: 20,
                                width: 20,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox.shrink(),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(type.formattedSubtitle),
                        trailing: Text(
                          "${multiplier}X",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                        onTap: () async {
                          final previousDeliveryType =
                              orderController.deliveryType.value;
                          final previousDeliveryTypeId =
                              orderController.deliveryTypeId.value;
                          orderController.setDeliveryTypeName(type.name);
                          orderController.setDeliveryTypeId(type.id);

                          EasyLoading.show(status: 'Updating...');
                          bool success = false;
                          if (orderController.lastOrderId != null) {
                            success = await updateController.patchDeliveryType(
                              orderController.lastOrderId!,
                              type.id,
                            );
                          }
                          EasyLoading.dismiss();

                          if (success) {
                            Get.back();
                          } else {
                            orderController.setDeliveryTypeName(
                              previousDeliveryType,
                            );
                            orderController.setDeliveryTypeId(
                              previousDeliveryTypeId,
                            );
                          }
                        },
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
