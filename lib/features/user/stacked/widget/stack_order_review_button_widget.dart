import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/service/order_confirmation_service.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/widget/show_order_confirmation_dialog.dart';
import 'package:ZipBee/features/user/vehicle_type/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import 'package:ZipBee/features/user/home/model/delivery_type_model.dart';

class StackedOrderReviewButtonStatic extends StatelessWidget {
  const StackedOrderReviewButtonStatic({super.key});

  String _formatAmount(double value, {String? sign}) {
    final resolvedSign = sign ?? (value < 0 ? '-' : '+');
    return '$resolvedSign\$${value.abs().toStringAsFixed(2)}';
  }

  Widget _buildBreakdownRow({
    required String label,
    String? detail,
    required String amount,
    Color? amountColor,
  }) {
    final title = detail == null || detail.isEmpty ? label : '$label: $detail';
    final String? iconPath = label == 'Delivery Type' && detail != null
        ? DeliveryTypeModel.getDeliveryTypeIconPath(null, deliveryType: detail)
        : null;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: getTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryFontColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (iconPath != null) ...[
                  const SizedBox(width: 6),
                  Image.asset(
                    iconPath,
                    height: 16,
                    width: 16,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: getTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: amountColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Use Get.find() NOT Get.put() inside build
    final vehicleController = Get.find<StackedVehicleController>();
    final orderController = Get.find<StackedOrderController>();
    orderController.ensureInitialPricingLoaded();

    return Container(
      margin: const EdgeInsets.only(bottom: 70),
      padding: const EdgeInsets.all(5),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            final total = orderController.totalCost.value;
            final isLoading = orderController.isFetchingTotal.value;
            final deliveryCharge =
                orderController.pricingDeliveryTypeCharge.value;
            final basePrice = orderController.pricingBasePrice.value;
            final additionalService =
                orderController.pricingAdditionalServiceCost.value;
            final fee = orderController.totalFee.value;
            final multiplier = orderController.deliveryTypeMultiplier.value;
            final vehicleName = orderController.pricingVehicleName.value;
            final isReady = vehicleController.selectedVehicle.value != null;
            final isBreakdownExpanded =
                orderController.isBreakdownExpanded.value;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: orderController.toggleBreakdown,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                isBreakdownExpanded
                                    ? Icons.keyboard_arrow_down
                                    : Icons.keyboard_arrow_right,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: isLoading
                                    ? Row(
                                        children: const [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.amber,
                                                  ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text("Loading..."),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Total (incl. GST):',
                                                  style: getTextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors
                                                        .primaryFontColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '\$${total.toStringAsFixed(2)}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: getTextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: total > 0
                                                        ? Colors.black
                                                        : Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: isReady
                          ? () async {
                              final savedTotal = orderController.totalCost.value;

                              orderController.isFetchingTotal.value = true;

                              try {
                                if (orderController.lastOrderId != null) {
                                  final res =
                                      await OrderConfirmationService.getOrder(
                                        orderController.lastOrderId!,
                                      );

                                  final data =
                                      (res['body']?['data']
                                              as Map<String, dynamic>?) ??
                                          {};
                                  orderController.syncOrderData(data);
                                }

                                await orderController.placeOrder(
                                  locationController: Get.find(),
                                  vehicleController: vehicleController,
                                );

                                EasyLoading.show(
                                  status: 'Loading order details...',
                                );

                                final orderRes =
                                    await OrderConfirmationService.getOrder(
                                      orderController.lastOrderId ?? 0,
                                    );

                                final orderData =
                                    orderRes['body']?['data']
                                        as Map<String, dynamic>? ??
                                    {};
                                orderController.syncOrderData(orderData);

                                EasyLoading.dismiss();

                                showStackedOrderConfirmationDialog(
                                  orderController,
                                );
                              } catch (e) {
                                EasyLoading.dismiss();
                                orderController.totalCost.value = savedTotal;
                                orderController.totalAmount.value = savedTotal;
                              } finally {
                                orderController.isFetchingTotal.value = false;
                              }
                            }
                          : null,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          isReady ? Colors.amber : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        'Review Order',
                        style: getTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isReady ? Colors.black : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                if (isBreakdownExpanded)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F7EF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE7DFC4)),
                    ),
                    child: Column(
                      children: [
                        _buildBreakdownRow(
                          label: 'Delivery Type',
                          detail: orderController.deliveryTypeDisplayName,
                          amount: _formatAmount(
                            deliveryCharge,
                            sign: multiplier < 1 ? '-' : '+',
                          ),
                          amountColor: multiplier < 1
                              ? Colors.red.shade600
                              : Colors.green.shade700,
                        ),
                        _buildBreakdownRow(
                          label: 'Vehicle Type',
                          detail: vehicleName,
                          amount: _formatAmount(basePrice, sign: '+'),
                          amountColor: Colors.green.shade700,
                        ),
                        _buildBreakdownRow(
                          label: 'Additional Service',
                          amount: _formatAmount(additionalService, sign: '+'),
                          amountColor: Colors.green.shade700,
                        ),
                        _buildBreakdownRow(
                          label: 'Fee',
                          amount: _formatAmount(fee, sign: '+'),
                          amountColor: Colors.green.shade700,
                        ),
                        const Divider(height: 18),
                        _buildBreakdownRow(
                          label: 'Total',
                          amount: '=\$${total.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
