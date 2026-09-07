import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:ZipBee/features/user/stacked/widget/pic_date_time.dart';
import 'package:ZipBee/features/user/vehicle_type/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:ZipBee/features/user/home/controller/home_controller.dart';
import 'package:intl/intl.dart';

import '../stacked_controller/stacked_controller.dart';
import '../widget/collect_time_widget.dart';
import '../widget/select_location_widget.dart';
import '../widget/stack_order_review_button_widget.dart';
import '../stacked_controller/update_details_controller.dart';
import '../widget/vehicle_type_widget.dart';

class StackedScreen extends StatelessWidget {
  final StackedLocationController controller = Get.put(
    StackedLocationController(),
  );
  final vehicleController = Get.put(StackedVehicleController());
  final StackedOrderController orderController = Get.put(
    StackedOrderController(),
  );

  StackedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Delivery Details',
          style: getTextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              StackedSelectLocationWidget(controller: controller),
              SizedBox(height: 24),
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
                      StackedCollectTimeOption(
                        title: "Now",
                        selected: controller.isNowSelected.value,
                        onTap: () async {
                          controller.selectNow();

                          // Ensure schedule controller set to Now as well
                          try {
                            final sched = Get.find<StackedScheduleController>();
                            sched.setNow(true);
                          } catch (_) {}

                          try {
                            final upd = Get.put(UpdateDetailsController());
                            final oc = Get.find<StackedOrderController>();
                            if (oc.lastOrderId != null) {
                              final ok = await upd.patchCollectTime(
                                oc.lastOrderId!,
                                'ASAP',
                              );
                              if (ok)
                                debugPrint(
                                  'Collect time switched to ASAP for order ${oc.lastOrderId}',
                                );
                            }
                          } catch (e) {
                            debugPrint('patchCollectTime ASAP error: $e');
                          }
                        },
                      ),
                      SizedBox(width: 16),
                      StackedCollectTimeOption(
                        title: "Schedule",
                        subtitle: controller.collectTimeSubtitle.value,
                        selected: !controller.isNowSelected.value,
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          controller.selectSchedule();

                          // Open the date-time dialog and await selected datetime
                          final selected = await showDialog<DateTime?>(
                            context: context,
                            builder: (_) => StackedPickDateTimeDialog(),
                          );

                          if (selected != null) {
                            String formattedDate = DateFormat('EEE, dd MMM, hh:mm a').format(selected);
                            controller.updateSubtitle(formattedDate);
                            // Save selected time into schedule controller
                            try {
                              final sched =
                                  Get.find<StackedScheduleController>();
                              sched.setDateTime(selected.toLocal());
                              sched.setNow(false);
                            } catch (_) {}

                            // call API to update collect time to scheduled
                            try {
                              final upd = Get.put(UpdateDetailsController());
                              final oc = Get.find<StackedOrderController>();
                              if (oc.lastOrderId != null) {
                                await upd.patchCollectTime(
                                  oc.lastOrderId!,
                                  'SCHEDULED',
                                  scheduledTime: selected
                                      .toUtc()
                                      .toIso8601String(),
                                );
                              }
                            } catch (_) {}
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
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
                  // IconButton(
                  //   onPressed: () {
                  //     // Pass placeholder initial distance = 2.0 km. Replace with routing-based distance later.
                  //     // Get.to(() => StackedVehicleSelectionPage(), arguments: {'initialDistanceKm': 2.0});
                  //   },
                  //   icon: Icon(Icons.info_outline),
                  //   color: Colors.black87,
                  //   iconSize: 20,
                  // ),
                ],
              ),
              SizedBox(height: 4),
              StackedVehicleTypeWidget(controller: controller),

              SizedBox(height: 24),
              StackedOrderReviewButtonStatic(),
            ],
          ),
        ),
      ),
    );
  }
}
