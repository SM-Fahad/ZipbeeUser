import 'package:ZipBee/core/service/external_launcher_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../core/common/styles/global_text_style.dart';
import '../../../chat/screen/chat_screen.dart';
import '../../model/order_model.dart';

class MessageCallSection extends StatelessWidget {
  final OrderModel order;
  const MessageCallSection({super.key, required this.order});

  void _callRider() async {
    if (order.assignRiderPhone.isNotEmpty) {
      await ExternalLauncherService.openDialer(order.assignRiderPhone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.to(
              () => const ChatScreen(),
              arguments: {
                "receiverId": (order.assignRiderUserId ?? 0).toString(),
                "senderName": order.assignRiderName,
                "orderId": order.orderId,
                "totalCost": order.total.toStringAsFixed(2),
                "vehicleType": order.vehicleType,
                "assignRiderPhone": order.assignRiderPhone,
              },
            ),

            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: const BorderSide(color: Colors.grey),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.message_outlined,
                  size: 20,
                  color: Colors.black,
                ),
                const SizedBox(width: 8),
                Text(
                  "Message",
                  style: getTextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: _callRider,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: const BorderSide(color: Colors.grey),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.call_outlined, size: 20, color: Colors.black),
                const SizedBox(width: 8),
                Text("Call", style: getTextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
