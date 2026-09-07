import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/vehicle_type/screen/screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../stacked_controller/stacked_controller.dart';

class StackedVehicleTypeWidget extends StatelessWidget {
  const StackedVehicleTypeWidget({super.key, required this.controller});

  final StackedLocationController controller;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: controller.vehicleList.asMap().entries.map((entry) {
            final index = entry.key;
            final vehicle = entry.value;
            const selectedColor = AppColors.onboardingIndicatorActive;
            final isSelected =
                controller.selectedVehicle.value?.vehicleType ==
                vehicle.vehicleType;

            return Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Get.to(
                      () => const StackedVehicleSelectionPage(),
                      arguments: {
                        'initialIndex': index,
                        'initialDistanceKm': 2.0,
                      },
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? selectedColor
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: selectedColor.withValues(alpha: 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                vehicle.iconPath,
                                fit: BoxFit.cover,
                                width: screenWidth * 0.25,
                                height: screenWidth * 0.18,
                              ),
                            ),
                            if (isSelected)
                              const Positioned(
                                top: 6,
                                right: 6,
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.green,
                                  child: Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          vehicle.vehicleType,
                          style: getTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? selectedColor : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
