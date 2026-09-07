import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/Sechedule_veycale_type/models/vehicle_data_model.dart'
    as ScheduleVehicle;
import 'package:ZipBee/features/user/Sechedule_veycale_type/controller/sechedule_vehicle_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widget/sechedule_veycale_widget.dart';

/// ------------------------------------------------------------------------
/// MAIN PAGE
/// ------------------------------------------------------------------------
class SecheduleVehicleSelectionPage extends StatelessWidget {
  SecheduleVehicleSelectionPage({Key? key}) : super();

  /// ✅ Controller initialized ONCE
  final VehicleSelectionController controller =
      Get.put(VehicleSelectionController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.backgroungColor,
        appBar: _buildAppBar(),
        body: const TabBarView(
          children: [
            VehicleListContent(type: 'Courier'),
            VehicleListContent(type: 'Car'),
            VehicleListContent(type: 'Van'),
            VehicleListContent(type: 'Truck'),
          ],
        ),
        bottomNavigationBar: BottomSummaryPanel(),
      ),
    );
  }

  /// ------------------------------------------------------------------------
  /// APP BAR
  /// ------------------------------------------------------------------------
  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.backgroungColor,
      centerTitle: true,
      title: Text(
        'Vehicle Type',
        style: getTextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TabBar(
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.black,
          indicator: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            border: Border.all(color: Colors.amber, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          tabs: [
            _buildTabIcon(IconPath.bike2),
            _buildTabIcon(IconPath.car2),
            _buildTabIcon(IconPath.shipment),
            _buildTabIcon(IconPath.shopcar),
          ],
        ),
      ),
    );
  }

  Widget _buildTabIcon(String path) {
    return Tab(
      icon: Image.asset(
        path,
        height: 67,
        width: 67,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// ------------------------------------------------------------------------
/// TAB CONTENT
/// ------------------------------------------------------------------------
class VehicleListContent extends StatelessWidget {
  final String type;

  const VehicleListContent({
    Key? key,
    required this.type,
  }) : super();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VehicleSelectionController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Vehicle',
            style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          /// VEHICLE LIST
          ...controller
              .getVehiclesByType(type)
              .map((ScheduleVehicle.Vehicle vehicle) {
            return Obx(
              () => VehicleCard(
                vehicle: vehicle,
                isSelected:
                    controller.selectedVehicle.value?.id == vehicle.id,
                onTap: () => controller.selectVehicle(vehicle),
              ),
            );
          }),

          const SizedBox(height: 20),

          /// ADDITIONAL SERVICES
          Obx(() {
            if (controller.selectedVehicle.value?.type != type) {
              return const SizedBox.shrink();
            }

            if (controller.availableServices.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Additional Services',
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ...controller.availableServices.map(
                  (service) => ServiceCard(
                    service: service,
                    isSelected:
                        controller.selectedServices.contains(service),
                    onTap: () => controller.toggleService(service),
                  ),
                ),
              ],
            );
          }),

          /// Space for bottom panel
          const SizedBox(height: 160),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------------------
/// BOTTOM SUMMARY PANEL
/// ------------------------------------------------------------------------
class BottomSummaryPanel extends StatelessWidget {
  BottomSummaryPanel({Key? key}) ;

  final VehicleSelectionController controller =
      Get.find<VehicleSelectionController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _showHistoryModal(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.keyboard_arrow_up, color: Colors.grey),
                  Text(
                    "View Breakdown",
                    style:
                        getTextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const Divider(),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total:',
                        style: getTextStyle(
                            fontSize: 14, color: Colors.grey),
                      ),
                      Obx(
                        () => Text(
                          'S\$${controller.totalAmount.toStringAsFixed(2)}',
                          style: getTextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isOrderReady
                        ? () => Get.back()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Review Order',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ------------------------------------------------------------------------
  /// PRICE BREAKDOWN MODAL
  /// ------------------------------------------------------------------------
  void _showHistoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Price Breakdown",
                style: getTextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Obx(
                () => Column(
                  children: controller.calculationHistory
                      .map(
                        (item) => Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check,
                                  size: 16, color: Colors.amber),
                              const SizedBox(width: 8),
                              Text(item,
                                  style:
                                      getTextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              const Divider(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: getTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Obx(
                    () => Text(
                      "S\$${controller.totalAmount.toStringAsFixed(2)}",
                      style: getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
