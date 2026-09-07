import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/service/order_service.dart';
import 'package:ZipBee/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/additional_controller.dart';
import '../controller/controller.dart';

class StackedBottomSummaryController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    print('\n🎬 [BOTTOM SUMMARY] Widget initState called');
    print('🎬 [BOTTOM SUMMARY] Attempting to refresh order data from API...\n');
    refreshOrderDataFromAPI();
  }

  Future<void> refreshOrderDataFromAPI() async {
    try {
      final oc = Get.find<StackedOrderController>();
      if (oc.lastOrderId != null) {
        print('🔄 [BOTTOM SUMMARY] Refreshing order data (ID: ${oc.lastOrderId})');
        final response = await OrderService.getOrder(oc.lastOrderId!);
        
        print('📥 [BOTTOM SUMMARY] API Response: ${response['statusCode']}');
        
        final status = response['statusCode'] as int? ?? 500;
        if (status == 200) {
          final data = (response['body'] as Map<String, dynamic>?)?['data'] as Map<String, dynamic>?;
          if (data != null) {
            double totalCostFromAPI = double.tryParse(data['total_cost'].toString()) ?? 0.0;
            print('💰 [BOTTOM SUMMARY] Got total_cost from API: \$${totalCostFromAPI.toStringAsFixed(2)}');
            print('📋 [BOTTOM SUMMARY] Full order data:');
            print('   - order_id: ${data['id']}');
            print('   - vehicle_type_id: ${data['vehicle_type_id']}');
            print('   - total_cost: \$${totalCostFromAPI.toStringAsFixed(2)}');
            print('   - total_fee: ${data['total_fee']}');
            print('   - additional_cost: ${data['additional_cost']}');
            print('   - total_distance: ${data['total_distance']}');
            print('   - delivery_type: ${data['delivery_type']}');
            print('   - pay_type: ${data['pay_type']}');
            
            // Update the controller with the latest data
            oc.totalCost.value = totalCostFromAPI;
            print('✅ [BOTTOM SUMMARY] Updated totalCost in controller to: \$${oc.totalCost.value.toStringAsFixed(2)}');
          }
        }
      }
    } catch (e) {
      print('❌ [BOTTOM SUMMARY] Error refreshing order: $e');
    }
  }
}

class StackedBottomSummary extends StatelessWidget {
  final StackedVehicleController vehicleController;
  final List<String> couriers;

  const StackedBottomSummary({
    super.key,
    required this.vehicleController,
    required this.couriers,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(StackedBottomSummaryController());
    final additionalServiceController = Get.find<AdditionalServiceController>();
    
    print('\n🎨 [BOTTOM SUMMARY] Building widget...');
    print('🎨 [BOTTOM SUMMARY] AdditionalServiceController found\n');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0),
      child: Container(
        margin: EdgeInsets.only(bottom: 70),
        padding: EdgeInsets.all(5),
        color: Colors.white,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_drop_up, size: 32),
              onPressed: () {
                openHistoryPopup(context, additionalServiceController, vehicleController);
              },
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total (incl. GST):',
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                  Obx(() {
                    print('\n═══════════════════════════════════════');
                    print('🔔 BOTTOM SUMMARY DISPLAY UPDATE');
                    print('═══════════════════════════════════════');
                    
                    // Get ONLY totalCost from API - No local vehicle calculation
                    try {
                      final oc = Get.find<StackedOrderController>();
                      final apiTotalCost = oc.totalCost.value;
                      
                      print('✅ StackedOrderController Found');
                      print('📊 Current totalCost value: \$${apiTotalCost.toStringAsFixed(2)}');
                      print('🔗 Order ID (lastOrderId): ${oc.lastOrderId}');
                      print('💳 Payment type (pay_type): ${oc.placeOrderResponse.value?['pay_type'] ?? 'N/A'}');
                      print('🚗 Delivery type: ${oc.placeOrderResponse.value?['delivery_type'] ?? 'N/A'}');
                      print('\n💰 DISPLAYING: \$${apiTotalCost.toStringAsFixed(2)}');
                      print('═══════════════════════════════════════\n');

                      return Text(
                        '\$${apiTotalCost.toStringAsFixed(2)}',
                        style: getTextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      );
                    } catch (e) {
                      print('❌ StackedOrderController NOT found: $e');
                      print('⏳ Waiting for order to be created from API...');
                      print('💰 DISPLAYING: \$0.00 (NO ORDER YET)');
                      print('═══════════════════════════════════════\n');
                      return Text(
                        '\$0.00',
                        style: getTextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      );
                    }
                  }),
                ],
              ),
            ),
            Obx(
              () => FilledButton(
                onPressed: vehicleController.selectedVehicle.value != null
                    ? () {
                        // Use only total_cost from API response
                        double amountToPass = vehicleController
                            .calculateTotal();
                        try {
                          final oc = Get.find<StackedOrderController>();
                          amountToPass = oc.totalCost.value;
                        } catch (_) {}

                        Get.toNamed(
                          AppRoutes.getstackedScreen(),
                          arguments: {'totalAmount': amountToPass},
                        );
                      }
                      : null,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (states) => vehicleController.selectedVehicle.value != null
                        ? Colors.amber
                        : Colors.grey.shade400,
                  ),
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
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

            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  void openHistoryPopup(
    BuildContext context,
    AdditionalServiceController additionalServiceController,
    StackedVehicleController vehicleController,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 50,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                "Cost Breakdown",
                style: getTextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Vehicle cost section
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Vehicle & Delivery",
                      style: getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Obx(() {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: vehicleController.calculationHistory.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              vehicleController.calculationHistory[index],
                              style: getTextStyle(fontSize: 12),
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Additional services section
              Obx(() {
                if (additionalServiceController.selectedServiceIds.isEmpty) {
                  print('==== ADDITIONAL SERVICES DEBUG ====');
                  print('No additional services selected');
                  return SizedBox.shrink();
                }

                print('==== ADDITIONAL SERVICES DEBUG ====');
                print('Selected Service IDs: ${additionalServiceController.selectedServiceIds}');

                return Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.amber.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.amber.shade50,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Additional Services",
                        style: getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 8),
                      ...additionalServiceController.selectedServiceIds.map((
                        serviceId,
                      ) {
                        final service = additionalServiceController.services
                            .firstWhereOrNull((s) => s.id == serviceId);
                        if (service == null) {
                          print('Service with ID $serviceId NOT FOUND');
                          return SizedBox.shrink();
                        }
                        
                        print('Service Found - ID: $serviceId, Name: ${service.serviceName}, Value: \$${service.value}');

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                service.serviceName,
                                style: getTextStyle(fontSize: 12),
                              ),
                              Text(
                                'S\$${service.value}',
                                style: getTextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),

              Divider(height: 24),

              // Total breakdown
              Obx(() {
                double vehicleTotal = vehicleController.calculateTotal();
                double additionalServicesTotal = additionalServiceController
                    .getSelectedServicesTotal();
                double subtotal = vehicleTotal + additionalServicesTotal;
                double gst = subtotal * 0.08; // 8% GST
                double finalTotal = subtotal + gst;
                
                print('==== TOTAL BREAKDOWN DEBUG ====');
                print('Vehicle Total: \$${vehicleTotal.toStringAsFixed(2)}');
                print('Additional Services Total: \$${additionalServicesTotal.toStringAsFixed(2)}');
                print('Subtotal: \$${subtotal.toStringAsFixed(2)}');
                print('GST (8%): \$${gst.toStringAsFixed(2)}');
                print('Final Total (incl. GST): \$${finalTotal.toStringAsFixed(2)}');

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Subtotal:",
                          style: getTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "\$${subtotal.toStringAsFixed(2)}",
                          style: getTextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "GST (8%):",
                          style: getTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "\$${gst.toStringAsFixed(2)}",
                          style: getTextStyle(
                            fontSize: 13,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total (incl. GST):",
                            style: getTextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "\$${finalTotal.toStringAsFixed(2)}",
                            style: getTextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),

              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
