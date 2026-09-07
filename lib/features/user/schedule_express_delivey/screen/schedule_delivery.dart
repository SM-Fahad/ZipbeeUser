import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/Veicale_Type_on_Exprees_Delivery/controller/vehicle_secation_controller.dart';
import 'package:ZipBee/features/user/Veicale_Type_on_Exprees_Delivery/screen/veichale_secation_page.dart';
import 'package:ZipBee/features/user/express_delivery_1/controller/express_controller_1.dart';
import 'package:ZipBee/features/user/express_delivery_1/widget/collect_time_widget.dart';
import 'package:ZipBee/features/user/express_delivery_1/widget/order_review_widget.dart';
import 'package:ZipBee/features/user/express_delivery_1/widget/pick_date_time_dialog.dart';
import 'package:ZipBee/features/user/express_delivery_1/widget/vehicle_type_widget.dart';
import 'package:ZipBee/features/user/schedule_express_delivey/widget/schedule_delivery_button.dart';
import 'package:ZipBee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScheduleDelivery extends StatelessWidget {
  final ExpressDeliveryMain controller = Get.put(ExpressDeliveryMain());
  final VehicleController vehicleController = Get.find<VehicleController>();

  ScheduleDelivery({super.key});

  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hideKeyboard,
      child: Scaffold(
        backgroundColor: AppColors.backgroungColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              hideKeyboard();
              Get.back();
            },
          ),
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Express Delivery',
                style: getTextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.info_outline, color: Colors.black87, size: 20),
                onPressed: () {
                  hideKeyboard();
                  Get.toNamed(AppRoutes.getexpressFaq());
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Location Section
                Text(
                  'Select Location',
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                ScheduleDeliveryButton(controller: controller),

                SizedBox(height: 24),

                // 🔹 Collect Time Section
                Text(
                  'Collect time',
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Obx(
                  () => IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CollectTimeOption(
                          title: "Now",
                          selected: controller.isNowSelected.value,
                          onTap: controller.selectNow,
                        ),
                        SizedBox(width: 16),
                        CollectTimeOption(
                          title: "Schedule",
                          subtitle: "Pick Date and Time",
                          selected: !controller.isNowSelected.value,
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            controller.selectSchedule();

                            // Open the date-time dialog
                            showDialog(
                              context: context,
                              builder: (_) => PickDateTimeDialog(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // 🔹 Vehicle Type Section
                Row(
                  children: [
                    Text(
                      'Vehicle type',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.info_outline),
                      onPressed: () {
                        hideKeyboard();
                        Get.to(() => VehicleSelectionPage());
                      },
                    ),
                  ],
                ),

                SizedBox(height: 4),
                VehicleTypeWidget(controller: controller),

                SizedBox(height: 24),

                // 🔹 Order Review Section
                OrderReviewWidget(
                  vehicleController: vehicleController,
                  total: vehicleController.calculateTotal(),
                  calculationHistory: vehicleController.calculationHistory
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
