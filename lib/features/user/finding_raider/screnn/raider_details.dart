import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/service/external_launcher_service.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/bottom_navbar/screen/bottom_navbar_screen.dart';
import 'package:ZipBee/features/user/chat/screen/chat_screen.dart';
import 'package:ZipBee/features/user/finding_raider/controller/rider_controller.dart';
import 'package:ZipBee/features/user/finding_raider/services/share_reward_service.dart';
import 'package:ZipBee/features/user/finding_raider/utils/ride_share_message_builder.dart';
import 'package:ZipBee/features/user/finding_raider/widget/button.dart';
import 'package:ZipBee/features/user/finding_raider/widget/custom_icon_text_button.dart';
import 'package:ZipBee/features/user/finding_raider/widget/order_location_info_widget.dart';
import 'package:ZipBee/features/user/finding_raider/widget/raider_info.dart';
import 'package:ZipBee/features/user/google_map/widget/google_map_widget.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class RaiderDetails extends StatefulWidget {
  const RaiderDetails({super.key});

  @override
  State<RaiderDetails> createState() => _RaiderDetailsState();
}

class _RaiderDetailsState extends State<RaiderDetails> {
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

    _fetchOrderDataOnInit();
  }

  void _fetchOrderDataOnInit() {
    String rawId = orderController.orderNumber.value.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    int? id = int.tryParse(rawId) ?? orderController.lastOrderId;

    if (id != null && id != 0) {
      if (controller.orderId.value != id) {
        controller.clearOrderData();
        controller.orderId.value = id;
      }
      controller.fetchOrderData(id, showLoader: controller.routeStops.isEmpty);
    }
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
                key: ValueKey('map_raider_details_${controller.orderId.value}'),
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
                    child: Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          dragHandle(),
                          const SizedBox(height: 24),
                          RaiderInfoWidget(),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomIconTextButton(
                                text: 'Message',
                                iconPath: IconPath.message,
                                borderColor: Colors.black,
                                textColor: Colors.black,
                                backgroundColor: Colors.white,
                                onPressed: () {
                                  if (controller
                                      .assignRiderUserId
                                      .value
                                      .isEmpty) {
                                    EasyLoading.showError(
                                      'Rider information not available',
                                    );
                                    return;
                                  }

                                  Get.to(
                                    () => const ChatScreen(),
                                    arguments: {
                                      "receiverId":
                                          controller.assignRiderUserId.value,
                                      "senderName":
                                          controller.assignRiderName.value,
                                      "orderId": controller.orderId.value
                                          .toString(),
                                      "totalCost": controller.totalCost.value
                                          .toStringAsFixed(2),
                                      "vehicleType":
                                          controller.vehicleType.value,
                                      "assignRiderPhone":
                                          controller.assignRiderPhone.value,
                                    },
                                  );
                                },
                              ),

                              CustomIconTextButton(
                                text: 'Call',
                                iconPath: IconPath.call,
                                borderColor: Colors.black,
                                textColor: Colors.black,
                                backgroundColor: Colors.white,
                                onPressed: () {
                                  final phoneNumber =
                                      controller.assignRiderPhone.value;
                                  if (phoneNumber.isNotEmpty) {
                                    ExternalLauncherService.openDialer(
                                      phoneNumber,
                                    );
                                  } else {
                                    EasyLoading.showError(
                                      'Phone number not available',
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total',
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
                              _buildPaymentDisplay(),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Date & Time'),
                              Text(
                                _formatDateTime(
                                  controller.orderCreatedAt.value,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          OrderLocationInfoWidget(
                            pickupStops: controller.pickupStops,
                            dropStops: controller.dropStops,
                            routeType: controller.routeType,
                          ),
                          const SizedBox(height: 20),
                          Button(
                            buttonText: 'Share Ride Information',
                            backgroundColor:
                                AppColors.onboardingIndicatorActive,
                            textColor: Colors.black,
                            onPressed: () async {
                              final assignRider =
                                  controller.assignRiderData.value;
                              final registration =
                                  (assignRider != null &&
                                      assignRider['registrations'] != null &&
                                      (assignRider['registrations'] as List)
                                          .isNotEmpty)
                                  ? assignRider['registrations'][0]
                                  : null;

                              final String
                              shareMessage = RideShareMessageBuilder.build(
                                orderId: orderController.orderNumber.value,
                                assignedRiderId:
                                    controller.assignRiderData.value?['id']
                                        ?.toString() ??
                                    'N/A',
                                riderName:
                                    registration?['raider_name'] ??
                                    'Not Assigned',
                                totalFare: controller.totalCost.value
                                    .toStringAsFixed(2),
                                paymentType:
                                    RideShareMessageBuilder.paymentMethodLabel(
                                      controller.paymentType.value,
                                    ),
                                pickupStops: controller.pickupStops,
                                dropStops: controller.dropStops,
                                routeType: controller.routeType.value,
                                scheduledDateTime:
                                    RideShareMessageBuilder.scheduledDateTimeLabel(
                                      scheduledTime:
                                          controller.scheduledTime.value,
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
                        ],
                      ),
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

  Widget _buildPaymentDisplay() {
    return Obx(() {
      final payType = controller.paymentType.value;

      if (payType == 'ONLINE_PAY') {
        return Row(
          children: [
            Image.asset(IconPath.visa, height: 24),
            const SizedBox(width: 8),
          ],
        );
      } else if (payType == 'WALLET') {
        return Row(
          children: [
            Image.asset(IconPath.wallet, height: 24),
            const SizedBox(width: 8),
            const Text(
              'Wallet',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        );
      } else if (payType == 'COD') {
        return Row(
          children: [
            const Icon(Icons.money, size: 24, color: Colors.green),
            const SizedBox(width: 8),
            const Text(
              'Cash',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        );
      }

      return const SizedBox.shrink();
    });
  }

  String _formatDateTime(String isoString) =>
      RideShareMessageBuilder.formatDateTime(isoString);
}
