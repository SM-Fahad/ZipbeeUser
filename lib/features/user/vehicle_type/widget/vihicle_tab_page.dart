import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:ZipBee/features/user/stacked/widget/stack_order_review_button_widget.dart';
import 'package:ZipBee/features/user/vehicle_type/widget/vehicle_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/additional_controller.dart';
import '../controller/controller.dart';

class StackedVehicleTabPage extends StatelessWidget {
  final String vehicleType;

  const StackedVehicleTabPage({super.key, required this.vehicleType});

  @override
  Widget build(BuildContext context) {
    final vehicleController = Get.put(StackedVehicleController());
    final serviceController = Get.put(AdditionalServiceController());
    final orderController = Get.put(StackedOrderController());

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// VEHICLES
                Obx(() {
                  final vehicles = vehicleController.getVehiclesForType(
                    vehicleType,
                  );

                  if (vehicles.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("No vehicles available"),
                      ),
                    );
                  }

                  return Column(
                    children: vehicles
                        .map(
                          (v) => StackedVehicleCard(
                            vehicle: v,
                            isSelected:
                                vehicleController.selectedVehicle.value == v,
                            onTap: () {
                              final orderId = orderController.lastOrderId;
                              final deliveryTypeId =
                                  orderController.deliveryTypeId.value;

                              if (orderId != null && deliveryTypeId != null) {
                                vehicleController.toggleVehicle(
                                  v,
                                  orderId,
                                  deliveryTypeId,
                                );
                              } else {
                                debugPrint(
                                  '❌ Order ID or Delivery Type ID is null, cannot update vehicle',
                                );
                              }
                            },
                          ),
                        )
                        .toList(),
                  );
                }),

                const SizedBox(height: 20),

                Text(
                  'Additional Service',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                /// ADDITIONAL SERVICES
                Obx(() {
                  final String? orderId = orderController.lastOrderId
                      ?.toString();
                  final services = serviceController.services;

                  debugPrint("Order ID for services: $orderId");
                  debugPrint("Available services: ${services.length}");

                  if (orderId == null) {
                    return const Center(
                      child: Text("Please select a vehicle to see services"),
                    );
                  }

                  // if (services.isEmpty) {
                  //   return const Center(child: CircularProgressIndicator());
                  // }

                  if (services.isEmpty) {
                    return const Center(
                      child: Text("No additional services available"),
                    );
                  }

                  return Column(
                    children: services.map((service) {
                      final bool isSelected = serviceController
                          .selectedServiceIds
                          .contains(service.id);

                      return GestureDetector(
                        onTap: () async {
                          await serviceController.toggleService(
                            service.id,
                            orderId,
                          );
                        },
                        child: Container(
                          height: 72,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryButtonColor
                                  : AppColors.backgroungColor,
                              width: 2,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: AppColors.primaryButtonColor
                                      .withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  service.serviceName,
                                  style: const TextStyle(fontSize: 18),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                "\$${service.value}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
                SizedBox(height: 20),
                // Bottom summary 
                StackedOrderReviewButtonStatic(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
