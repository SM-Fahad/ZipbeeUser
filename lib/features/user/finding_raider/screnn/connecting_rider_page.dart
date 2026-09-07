import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/bottom_navbar/screen/bottom_navbar_screen.dart';
import 'package:ZipBee/features/user/finding_raider/controller/rider_controller.dart';
import 'package:ZipBee/features/user/finding_raider/screnn/raider_details.dart';
import 'package:ZipBee/features/user/finding_raider/services/share_reward_service.dart';
import 'package:ZipBee/features/user/finding_raider/utils/ride_share_message_builder.dart';
import 'package:ZipBee/features/user/finding_raider/widget/button.dart';
import 'package:ZipBee/features/user/finding_raider/widget/order_location_info_widget.dart';
import 'package:ZipBee/features/user/finding_raider/widget/payment_Info_widget.dart';
import 'package:ZipBee/features/user/google_map/widget/google_map_widget.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:ZipBee/features/user/finding_raider/widget/cancel_order_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class ConnectingRiderPage extends StatefulWidget {
  const ConnectingRiderPage({super.key});

  @override
  State<ConnectingRiderPage> createState() => _ConnectingRiderPageState();
}

class _ConnectingRiderPageState extends State<ConnectingRiderPage> {
  late final RiderController controller;
  late final StackedOrderController orderController;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<RiderController>()
        ? Get.find<RiderController>()
        : Get.put(RiderController());

    orderController = Get.isRegistered<StackedOrderController>()
        ? Get.find<StackedOrderController>()
        : Get.put(StackedOrderController());

    final rawOrderNumber = orderController.orderNumber.value;
    String rawId = rawOrderNumber.replaceAll(RegExp(r'[^0-9]'), '');
    int? id = int.tryParse(rawId) ?? orderController.lastOrderId;

    if (id != null && id != 0) {
      if (controller.orderId.value != id) {
        controller.clearOrderData();
        controller.orderId.value = id;
      }
      orderController.lastOrderId = id;
      _startPollingAndHandleRiderAssignment();
    }
  }

  void _startPollingAndHandleRiderAssignment() {
    controller.startPollingAssignRider(() {
      debugPrint('✅ Rider assigned, navigating to next screen');
      controller.stopPollingAssignRider();
      Get.to(() => RaiderDetails());
    });
  }

  @override
  void dispose() {
    controller.stopPollingAssignRider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            controller.stopPollingAssignRider();
            controller.clearOrderData();
            Get.offAll(() => BottomNavbarScreen());
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset(IconPath.colorFullArrow, width: 24),
          ),
        ),
      ),
      body: Stack(
        children: [
          Obx(
            () => SizedBox.expand(
              child: GoogleMapWidget(
                key: ValueKey('map_connecting_${controller.orderId.value}'),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.4,
            maxChildSize: 0.7,
            builder: (_, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        dragHandle(),
                        const SizedBox(height: 16),

                        const Text(
                          'Connecting to rider...',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(child: _movingProgressBar()),

                        const SizedBox(height: 16),
                        // Payment Information - Updated with API data
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order ${orderController.orderNumber.value}',
                                    style: getTextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    '\$${controller.totalCost.value.toStringAsFixed(2)}',
                                    style: getTextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              PaymentInfoWidget(),
                            ],
                          ),
                        ),

                        const Divider(height: 32),

                        // Date & Time
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Date & Time',
                                style: getTextStyle(fontSize: 12),
                              ),
                              Text(
                                _formatDateTime(
                                  controller.orderCreatedAt.value,
                                ),
                                style: getTextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 32),

                        // Collection and Delivery Locations
                        OrderLocationInfoWidget(
                          pickupStops: controller.pickupStops,
                          dropStops: controller.dropStops,
                          routeType: controller.routeType,
                        ),

                        const SizedBox(height: 20),

                        Button(
                          buttonText: 'Share Ride Information',
                          backgroundColor: Colors.amber,
                          textColor: Colors.black,
                          onPressed: () async {
                            final assignRider =
                                controller.assignRiderData.value;
                            final registration = assignRider != null &&
                                    assignRider['registrations'] != null &&
                                    (assignRider['registrations'] as List)
                                        .isNotEmpty
                                ? assignRider['registrations'][0]
                                : null;

                            final orderId = orderController.orderNumber.value;
                            final riderId =
                                assignRider?['id']?.toString() ?? 'N/A';
                            final riderName =
                                registration?['raider_name']?.toString() ??
                                    'Not Assigned';
                            final String shareMessage =
                                RideShareMessageBuilder.build(
                              orderId: orderId,
                              assignedRiderId: riderId,
                              riderName: riderName,
                              totalFare:
                                  controller.totalCost.value.toStringAsFixed(2),
                              paymentType:
                                  RideShareMessageBuilder.paymentMethodLabel(
                                controller.paymentType.value,
                              ),
                              pickupStops: controller.pickupStops,
                              dropStops: controller.dropStops,
                              routeType: controller.routeType.value,
                              scheduledDateTime: RideShareMessageBuilder
                                  .scheduledDateTimeLabel(
                                scheduledTime: controller.scheduledTime.value,
                                fallbackCreatedAt:
                                    controller.orderCreatedAt.value,
                              ),
                              jobAcceptedTime:
                                  RideShareMessageBuilder.formatDateTime(
                                controller.orderUpdatedAt.value,
                              ),
                            );

                            await ShareRewardService.share();
                            await SharePlus.instance.share(
                              ShareParams(text: shareMessage),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => showCancelOrderDialog(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                                side: const BorderSide(
                                  color: Colors.red,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Cancel order',
                                  style: getTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Image.asset(IconPath.cancel),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String isoString) =>
      RideShareMessageBuilder.formatDateTime(isoString);

  Widget dragHandle() => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _movingProgressBar() => SizedBox(
        width: 146,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: const LinearProgressIndicator(
            minHeight: 6,
            backgroundColor: Color(0xFFE0E0E0),
            color: Colors.amber,
          ),
        ),
      );
}
