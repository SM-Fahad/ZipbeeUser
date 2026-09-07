import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/features/user/Veicale_Type_on_Exprees_Delivery/controller/vehicle_secation_controller.dart';
import 'package:ZipBee/features/user/Veicale_Type_on_Exprees_Delivery/widget/additional_service_card.dart';
import 'package:ZipBee/features/user/Veicale_Type_on_Exprees_Delivery/widget/buttom_sumary.dart';
import 'package:ZipBee/features/user/Veicale_Type_on_Exprees_Delivery/widget/vehicale_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class VehicleTabPage extends StatelessWidget {
  final String vehicleType;

  const VehicleTabPage({super.key, required this.vehicleType});

  @override
  Widget build(BuildContext context) {
    final VehicleController controller = Get.put(
      VehicleController(),
      tag: vehicleType,
    );

    return Column(
      children: [
        // Flexible scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please select available vehicle',
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),

                // Vehicles list
                Obx(() {
                  final vehicles = controller.getVehiclesForType(vehicleType);
                  final selectedVehicle = controller.selectedVehicle.value;
                  return Column(
                    children: vehicles
                        .map(
                          (vehicle) => Padding(
                            padding: EdgeInsets.only(bottom: 14),
                            child: VehicleCard(
                              vehicle: vehicle,
                              isSelected: selectedVehicle?.name == vehicle.name,
                              onTap: () => controller.selectVehicle(vehicle),
                            ),
                          ),
                        )
                        .toList(),
                  );
                }),

                // Additional services list
                Obx(() {
                  final selectedVehicle = controller.selectedVehicle.value;
                  if (selectedVehicle == null) return SizedBox.shrink();
                  final services = controller.getAdditionalServicesForType(
                    selectedVehicle.type,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (services.isNotEmpty) ...[
                        SizedBox(height: 20),
                        Text(
                          'Additional Services',
                          style: getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        ...services.map(
                          (service) => Padding(
                            padding: EdgeInsets.only(bottom: 14),
                            child: AdditionalServiceCard(
                              service: service,
                              isSelected: controller.selectedServices.contains(
                                service,
                              ),
                              onTap: () => controller.toggleService(service),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                }),
              ],
            ),
          ),
        ),

        // Fixed BottomSummary (not inside scroll)
        BottomSummary(vehicleController: controller, couriers: []),
      ],
    );
  }
}
