import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/controller.dart';
import '../widget/vihicle_tab_page.dart';

class StackedVehicleSelectionPage extends StatelessWidget {
  const StackedVehicleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StackedVehicleController());

    final args = Get.arguments as Map<String, dynamic>?;

    int initialIndex = 0;

    if (args != null) {
      if (args['initialIndex'] != null) {
        initialIndex = args['initialIndex'];
      }

      if (args['initialDistanceKm'] != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.totalDistanceKm.value = (args['initialDistanceKm'] as num)
              .toDouble();

          debugPrint('Initial distance: ${controller.totalDistanceKm.value}');
        });
      }

      // Extract order data and set in StackedOrderController
      if (args['order'] != null) {
        final orderData = args['order'] as Map<String, dynamic>;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            final orderCtrl = Get.find<StackedOrderController>();
            orderCtrl.syncOrderData(orderData);
            debugPrint(
              '✅ Order initialized: ID=${orderCtrl.lastOrderId}, Total=${orderCtrl.totalCost.value}',
            );
          } catch (_) {
            try {
              final orderCtrl = Get.put(StackedOrderController());
              orderCtrl.syncOrderData(orderData);
              debugPrint(
                '✅ Order initialized (new controller): ID=${orderCtrl.lastOrderId}, Total=${orderCtrl.totalCost.value}',
              );
            } catch (e) {
              debugPrint('❌ Error setting order data: $e');
            }
          }
        });
      }
    }

    return DefaultTabController(
      length: 4,
      initialIndex: initialIndex, // 🔥 IMPORTANT
      child: Scaffold(
        backgroundColor: AppColors.backgroungColor,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'Vehicle Type',
            style: getTextStyle(
              fontSize: 20,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(88),
            child: Container(
              height: 88,
              color: AppColors.backgroungColor,
              margin: const EdgeInsets.only(top: 5),
              child: TabBar(
                indicator: BoxDecoration(
                  // color: Colors.yellow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.black54,
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(
                    icon: Image.asset(IconPath.bike2, height: 38, width: 46),
                    text: 'Bike',
                  ),
                  Tab(
                    icon: Image.asset(IconPath.car2, height: 38, width: 46),
                    text: 'Car',
                  ),
                  Tab(
                    icon: Image.asset(IconPath.shopcar, height: 38, width: 46),
                    text: 'Van',
                  ),
                  Tab(
                    icon: Image.asset(IconPath.shipment, height: 38, width: 46),
                    text: 'Truck',
                  ),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            StackedVehicleTabPage(vehicleType: 'Courier'),
            StackedVehicleTabPage(vehicleType: 'Car'),
            StackedVehicleTabPage(vehicleType: 'Van'),
            StackedVehicleTabPage(vehicleType: 'Truck'),
          ],
        ),
      ),
    );
  }
}
