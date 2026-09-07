import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/order/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../active_order_details/screen/active_order_details_screen.dart';
import '../completed_order_details/completed_order_details_screen/screen/completed_order_details_screen.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController());

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text("Orders", style: getTextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryButtonColor),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Obx(
                    () => Row(
                      children: List.generate(controller.orderTabs.length, (
                        index,
                      ) {
                        final isSelected =
                            controller.selectOrderListIndex.value == index;
                        return GestureDetector(
                          onTap: () {
                            controller.selectOrderListIndex.value = index;
                            controller.fetchOrders(isRefresh: true);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryButtonColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              controller.orderTabs[index],
                              style: getTextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Order List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.orderList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.orderList.isEmpty) {
                  return const Center(child: Text("No Orders Found"));
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!controller.isLoading.value &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      controller.loadMoreOrders();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.orderList.length,
                    itemBuilder: (_, index) {
                      final item = controller.orderList[index];
                      final dropStopsCount = controller.getDropStopsCount(item);

                      return GestureDetector(
                        onTap: () {
                          if (controller.selectOrderListIndex.value == 0 ||
                              controller.selectOrderListIndex.value == 1) {
                            Get.to(() => ActiveOrderDetailsScreen(order: item));
                          } else if (controller.selectOrderListIndex.value ==
                              2) {
                            Get.to(
                              () => CompletedOrderDetailsScreen(order: item),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.subtitleFontColor,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Order Id: #${item.orderId}",
                                style: getTextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              Center(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    _buildValueChip(
                                      controller.displayValue(
                                        item.deliveryTypeName,
                                      ),
                                      iconPath: item.deliveryTypeIconPath,
                                    ),
                                    _buildValueChip(
                                      controller.displayValue(item.routeType),
                                    ),
                                    _buildValueChip(
                                      controller.collectionValue(item),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              Text(
                                "📍 Collected from",
                                style: getTextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.displayValue(item.pickupAddress),
                                style: getTextStyle(
                                  fontSize: 12,
                                  color: AppColors.subtitleFontColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),

                              // Drop Locations
                              Text(
                                "📦 Deliver to $dropStopsCount destination${dropStopsCount > 1 ? 's' : ''}",
                                style: getTextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ...(controller.getDropStops(item))
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "•  ",
                                            style: getTextStyle(fontSize: 12),
                                          ),
                                          Expanded(
                                            child: Text(
                                              controller.displayValue(
                                                entry.value["address"],
                                              ),
                                              style: getTextStyle(
                                                fontSize: 12,
                                                color:
                                                    AppColors.subtitleFontColor,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              const SizedBox(height: 12),

                              // Cost
                              Row(
                                // mainAxisAlignment:
                                //     MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total Cost :",
                                    style: getTextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Text(
                                    "\$${item.total.toStringAsFixed(2)}",
                                    style: getTextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.primaryButtonColor,
                                    ),
                                  ),
                                  Spacer(), 
                                  // e-recipt button 
                                  // if (item.status == "COMPLETED" ||
                                  //     controller.selectOrderListIndex.value == 1)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.primaryButtonColor,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () {
                                        controller.sendEReceipt(item.orderId);
                                      },
                                      child: Text(
                                        "Send e-receipt",
                                        style: getTextStyle(
                                          color: AppColors.fontColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueChip(String value, {String? iconPath}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryButtonColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: getTextStyle(
              color: AppColors.primaryButtonColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          if (iconPath != null && iconPath.isNotEmpty) ...[
            const SizedBox(width: 4),
            Image.asset(
              iconPath,
              height: 14,
              width: 14,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }
}
