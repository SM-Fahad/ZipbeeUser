import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/stacked/stacked_collect_from/controller/controller.dart';
import 'package:ZipBee/features/user/stacked/stacked_collect_from/screen/collect_from.dart';
import 'package:ZipBee/features/user/stacked/stacked_controller/stacked_controller.dart';
// import 'package:ZipBee/features/user/stacked/schedule_stacked_ delivey/Schedule_recepent/screen/schedule_recepent_screen1.dart';
// import 'package:ZipBee/features/user/stacked/schedule_stacked_ delivey/Schedule_sender_recepent/screen/schedule_sender_screen.dart';
import 'package:ZipBee/features/user/stacked/widget/delivery_type_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import '../stacked_controller/update_details_controller.dart';
import 'package:ZipBee/features/user/home/model/delivery_type_model.dart';

class StackedButtonWidget extends StatelessWidget {
  const StackedButtonWidget({super.key, required this.controller});

  final StackedLocationController controller;

  bool _hasText(String value, {String? placeholder}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    if (placeholder != null && trimmed == placeholder) return false;
    return true;
  }

  bool _hasPickupData() {
    return controller.collectedStops.isNotEmpty ||
        (_hasText(controller.senderDisplayName) &&
            _hasText(
              controller.senderDisplayAddress,
              placeholder: 'Sender Address',
            ));
  }

  bool _hasDropOffData() {
    return controller.recipientStops.isNotEmpty ||
        (_hasText(controller.receiverDisplayName) &&
            _hasText(
              controller.receiverDisplayAddress,
              placeholder: 'Delivered Address',
            ));
  }

  int _dropOffStopCount() {
    if (controller.recipientStops.isNotEmpty) {
      return controller.recipientStops.length;
    }

    return _hasDropOffData() ? 1 : 0;
  }

  bool _isFixedRouteEnabled() {
    return _hasPickupData() && _dropOffStopCount() >= 2;
  }

  Widget _buildStopList({
    required int count,
    required bool Function(int index) hasDataAt,
    required String Function(int index) nameAt,
    required String Function(int index) addressAt,
    required String titlePrefix,
    required String iconPath,
    required VoidCallback onTap,
    required VoidCallback onEdit,
    bool showTickWhenHasData = false,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, index) {
        final hasData = hasDataAt(index);
        final name = nameAt(index);
        final addr = addressAt(index);
        final title = titlePrefix == 'Drop Off'
            ? 'Stop ${index + 1} $name'
            : '$titlePrefix $name';

        return Column(
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Image.asset(iconPath, width: 24, height: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: getTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  addr,
                                  style: getTextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (showTickWhenHasData && hasData) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 16,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: onEdit,
                    ),
                  ],
                ),
              ),
            ),
            if (!hasData) const SizedBox(height: 8),
            if (hasData) const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          // border: Border.all(
          //   color: controller.isRoundTrip.value
          //       ? AppColors.primaryButtonColor
          //       : Colors.transparent,
          //   width: 5,
          // ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            /// =================== TOP TOGGLE (ONE WAY + ROUND) ===================
            Card(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final previous = controller.isRoundTrip.value;
                        controller.toggleTripType(false);

                        try {
                          final upd = Get.put(UpdateDetailsController());
                          final oc = Get.find<StackedOrderController>();
                          if (oc.lastOrderId != null) {
                            final ok = await upd.patchRouteType(
                              oc.lastOrderId!,
                              'ONE_WAY',
                            );
                            if (!ok) controller.toggleTripType(previous);
                          }
                        } catch (_) {
                          controller.toggleTripType(previous);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: !controller.isRoundTrip.value
                              ? AppColors.white
                              : Colors.grey.shade400,
                          // borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "One way",
                          style: getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: !controller.isRoundTrip.value
                                ? AppColors.primaryFontColor
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final previous = controller.isRoundTrip.value;
                        controller.toggleTripType(true);

                        try {
                          final upd = Get.put(UpdateDetailsController());
                          final oc = Get.find<StackedOrderController>();
                          if (oc.lastOrderId != null) {
                            final ok = await upd.patchRouteType(
                              oc.lastOrderId!,
                              'ROUND',
                            );
                            if (!ok) controller.toggleTripType(previous);
                          }
                        } catch (_) {
                          controller.toggleTripType(previous);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: controller.isRoundTrip.value
                              ? AppColors.white
                              : Colors.grey.shade400,
                          // borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Round",
                          style: getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: controller.isRoundTrip.value
                                ? AppColors.primaryFontColor
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// =================== MAIN CONTAINER ===================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ================= FIXED ROUTE =================
                  Obx(() {
                    final orderController = Get.put(StackedOrderController());
                    final isSelected = orderController.isFixed.value;
                    final isFixedRouteEnabled = _isFixedRouteEnabled();
                    final textColor = isFixedRouteEnabled
                        ? Colors.black
                        : Colors.grey.shade400;
                    return GestureDetector(
                      onTap: isFixedRouteEnabled
                          ? () async {
                              final newVal = !isSelected;
                              orderController.isFixed.value = newVal;

                              try {
                                final upd = Get.put(UpdateDetailsController());
                                if (orderController.lastOrderId != null) {
                                  await upd.patchIsFixed(
                                    orderController.lastOrderId!,
                                    newVal,
                                  );
                                }
                              } catch (_) {
                                orderController.isFixed.value = isSelected;
                              }
                            }
                          : null,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: !isFixedRouteEnabled
                              ? Colors.grey.shade100
                              : isSelected
                              ? AppColors.primaryButtonColor
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          // border: Border.all(
                          //   color: isSelected ? Colors.amber : Colors.grey,
                          // ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              IconPath.exparess,
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Fixed route",
                              style: getTextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isFixedRouteEnabled && isSelected
                                    ? AppColors.white
                                    : textColor,
                              ),
                            ),
                            SizedBox(width: 8),

                            // Checkbos
                            Container(
                              height: 18,
                              width: 18,
                              decoration: BoxDecoration(
                                color: isFixedRouteEnabled && isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isFixedRouteEnabled && isSelected
                                      ? Colors.white
                                      : textColor,
                                  width: 2,
                                ),
                              ),
                              child: isFixedRouteEnabled && isSelected
                                  ? Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.amber,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // SizedBox(height: 8),
                  Obx(() {
                    final orderController = Get.find<StackedOrderController>();
                    return GestureDetector(
                      onTap: () => Get.dialog(const DeliveryTypeDialog()),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Delivery Type: ${orderController.deliveryTypeDisplayName}',
                                  style: getTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (DeliveryTypeModel.getDeliveryTypeIconPath(
                                      null,
                                      deliveryType:
                                          orderController.deliveryTypeDisplayName,
                                    ) !=
                                    null) ...[
                                  const SizedBox(width: 6),
                                  Image.asset(
                                    DeliveryTypeModel.getDeliveryTypeIconPath(
                                      null,
                                      deliveryType:
                                          orderController.deliveryTypeDisplayName,
                                    )!,
                                    height: 18,
                                    width: 18,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const SizedBox.shrink(),
                                  ),
                                ],
                              ],
                            ),
                            Spacer(),
                            Icon(Icons.keyboard_arrow_right, size: 16),
                          ],
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 16),

                  /// =================== SENDER LIST ===================
                  Obx(() {
                    final count = controller.collectedStops.isNotEmpty
                        ? controller.collectedStops.length
                        : 1;

                    return _buildStopList(
                      count: count,
                      hasDataAt: (index) =>
                          controller.collectedStops.isNotEmpty &&
                          index < controller.collectedStops.length,
                      nameAt: (index) =>
                          controller.collectedStops.isNotEmpty &&
                              index < controller.collectedStops.length
                          ? controller.collectedStops[index].contactName
                          : controller.senderDisplayName,
                      addressAt: (index) =>
                          controller.collectedStops.isNotEmpty &&
                              index < controller.collectedStops.length
                          ? controller.collectedStops[index].addressFromApr
                          : controller.senderDisplayAddress,
                      titlePrefix: 'Pick Up',
                      iconPath: IconPath.collectIcon,
                      showTickWhenHasData: true,
                      onTap: () {
                        Get.to(
                          () => StackedCollectFormScreen(
                            controller: Get.put(StackedCollectFormController()),
                            addressType: 'SENDER',
                          ),
                        );
                      },
                      onEdit: () {
                        Get.to(
                          () => StackedCollectFormScreen(
                            controller: Get.put(StackedCollectFormController()),
                            addressType: 'SENDER',
                          ),
                        );
                      },
                    );
                  }),

                  /// =================== RECEIVER LIST ===================
                  Obx(() {
                    final count = controller.recipientStops.isNotEmpty
                        ? controller.recipientStops.length
                        : 1;

                    return _buildStopList(
                      count: count,
                      hasDataAt: (index) =>
                          controller.recipientStops.isNotEmpty &&
                          index < controller.recipientStops.length,
                      nameAt: (index) =>
                          controller.recipientStops.isNotEmpty &&
                              index < controller.recipientStops.length
                          ? controller.recipientStops[index].contactName
                          : controller.receiverDisplayName,
                      addressAt: (index) =>
                          controller.recipientStops.isNotEmpty &&
                              index < controller.recipientStops.length
                          ? controller.recipientStops[index].addressFromApr
                          : controller.receiverDisplayAddress,
                      titlePrefix: 'Drop Off',
                      iconPath: IconPath.deliveredIcon,
                      showTickWhenHasData: true,
                      onTap: () {
                        Get.to(
                          () => StackedCollectFormScreen(
                            controller: Get.put(StackedCollectFormController()),
                            addressType: 'RECEIVER',
                          ),
                        );
                      },
                      onEdit: () {
                        Get.to(
                          () => StackedCollectFormScreen(
                            controller: Get.put(StackedCollectFormController()),
                            addressType: 'RECEIVER',
                          ),
                        );
                      },
                    );
                  }),

                  /// =================== RETURN LIST ===================
                  Obx(() {
                    if (!controller.isRoundTrip.value) {
                      return const SizedBox.shrink();
                    }

                    final count = controller.collectedStops.isNotEmpty
                        ? controller.collectedStops.length
                        : 1;

                    return _buildStopList(
                      count: count,
                      hasDataAt: (index) =>
                          controller.collectedStops.isNotEmpty &&
                          index < controller.collectedStops.length,
                      nameAt: (index) =>
                          controller.collectedStops.isNotEmpty &&
                              index < controller.collectedStops.length
                          ? controller.collectedStops[index].contactName
                          : controller.senderDisplayName,
                      addressAt: (index) =>
                          controller.collectedStops.isNotEmpty &&
                              index < controller.collectedStops.length
                          ? controller.collectedStops[index].addressFromApr
                          : controller.senderDisplayAddress,
                      titlePrefix: 'Return',
                      iconPath: IconPath.collectIcon,
                      showTickWhenHasData: true,
                      onTap: () {
                        Get.to(
                          () => StackedCollectFormScreen(
                            controller: Get.put(StackedCollectFormController()),
                            addressType: 'SENDER',
                          ),
                        );
                      },
                      onEdit: () {
                        Get.to(
                          () => StackedCollectFormScreen(
                            controller: Get.put(StackedCollectFormController()),
                            addressType: 'SENDER',
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
