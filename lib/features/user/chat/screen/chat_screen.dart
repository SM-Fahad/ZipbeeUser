import 'package:ZipBee/core/service/external_launcher_service.dart';
import 'package:ZipBee/features/user/chat/controllers/chat_controller.dart';
import 'package:ZipBee/features/user/chat/widget/chat_bubble.dart';
import 'package:ZipBee/features/user/chat/widget/order_info_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Receive arguments
    final args = Get.arguments as Map<String, dynamic>? ?? {};

    final String receiverId = args["receiverId"]?.toString() ?? "";
    final String senderName = args["senderName"]?.toString() ?? "";
    final String orderId = args["orderId"]?.toString() ?? "";
    final String vehicleType = args["vehicleType"]?.toString() ?? "";
    final String totalCost = args["totalCost"]?.toString() ?? "";
    final String assignRiderPhone = args["assignRiderPhone"]?.toString() ?? "";

    /// Inject controller
    final controller = Get.put(UserMessageController());

    /// Pass arguments to controller
    controller.receiverId = receiverId;
    controller.orderId = orderId;

    /// Load history manually (controller onInit may also do this)
    // controller.loadChatHistory();---any time again

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          senderName.isNotEmpty ? senderName : "Rider Name",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (assignRiderPhone.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.phone_forwarded_outlined,
                color: Colors.amber,
              ),
              onPressed: () {
                ExternalLauncherService.openDialer(assignRiderPhone);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          OrderInfoCard(
            orderId: orderId,
            vehicleType: vehicleType,
            totalCost: totalCost.isNotEmpty ? double.parse(totalCost) : 0.0,
            fromName: '',
            toName: '',
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("Today", style: TextStyle(color: Colors.grey)),
          ),

          /// Messages
          Expanded(
            child: Obx(() {
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  return ChatBubble(message: message);
                },
              );
            }),
          ),

          _buildInputArea(controller, receiverId),
        ],
      ),
    );
  }

  Widget _buildInputArea(UserMessageController controller, String receiverId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.grey[200]),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: controller.textController,
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => controller.sendMessage(receiverId),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => controller.sendMessage(receiverId),
            ),
          ],
        ),
      ),
    );
  }
}
