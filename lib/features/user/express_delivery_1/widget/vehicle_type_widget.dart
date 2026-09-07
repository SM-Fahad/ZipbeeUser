import 'package:ZipBee/features/user/express_delivery_1/controller/express_controller_1.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class VehicleTypeWidget extends StatelessWidget {
  const VehicleTypeWidget({super.key, required this.controller});

  final ExpressDeliveryMain controller;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: controller.vehicleList.map((vehicle) {
            bool isSelected = controller.selectedVehicle.value == vehicle;
            return Row(
              children: [
                GestureDetector(
                  onTap: () => controller.selectVehicle(vehicle),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? Colors.amber.shade600
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        vehicle.iconPath,
                        fit: BoxFit.cover,
                        width: screenWidth * 0.25,
                        height: screenWidth * 0.18,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
