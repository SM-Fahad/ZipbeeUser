import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ZipBee/features/user/chat/controllers/chat_controller.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/service/notify_rider.dart';

class OrderInfoCard extends StatelessWidget {
  final String orderId;

  final String fromName;
  final String toName;
  final String vehicleType;
  final double totalCost;

  const OrderInfoCard({
    super.key,
    required this.orderId,

    required this.fromName,
    required this.toName,
    required this.vehicleType,
    required this.totalCost,
  });

  @override
  Widget build(BuildContext context) {
    final chatController = Get.isRegistered<UserMessageController>()
        ? Get.find<UserMessageController>()
        : null;

    return Container(
      width: double.infinity,
      color: const Color(0xFFFFFBE6), // Light yellowish-white
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order #$orderId ",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            "Vehicle type: $vehicleType, Total: \$${totalCost.toStringAsFixed(2)}",
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
          if (chatController != null)
            Obx(() {
              final order = chatController.orderDetails.value;
              if (order == null) {
                return const SizedBox.shrink();
              }

              if (order.isAutoConfirmation) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Order Auto Confirmed",
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (!order.raiderConfirmation) {
                return const SizedBox.shrink();
              }

              if (order.userConfirmationAt == null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.amber, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Did the driver call you to confirm the order?",
                            style: TextStyle(
                              color: Colors.amber[900],
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          height: 26,
                          child: ElevatedButton(
                            onPressed: () async {
                              EasyLoading.show(status: 'Confirming...');
                              try {
                                final res = await NotifyRider.userConfirmation(
                                  orderId: order.orderId,
                                );
                                final success = res['success'] as bool? ?? false;
                                if (success) {
                                  EasyLoading.showSuccess('Order confirmed');
                                  await chatController.fetchOrderDetails();
                                } else {
                                  final msg = res['body']?['message'] ?? 'Failed to confirm';
                                  EasyLoading.showError(msg.toString());
                                }
                              } catch (e) {
                                debugPrint('Error user confirmation in chat: $e');
                                EasyLoading.showError('An error occurred');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Yes",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.blue, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Order Confirmed",
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }
            }),
        ],
      ),
    );
  }
}
