import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/user_support/support_chat_screen/controller/support_chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreen extends StatelessWidget {
  final ChatController controller = Get.put(ChatController());
  ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroungColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4,
          children: [
            Image.asset(
              IconPath.supportIcon,
              width: 24,
              height: 24,
              fit: BoxFit.cover,
            ),
            Obx(
              () => Text(
                controller.supportUsername.value.isNotEmpty
                    ? controller.supportUsername.value
                    : 'Sandy',
                style: getTextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: controller.scrollController,
                padding: EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  return Align(
                    alignment: msg.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: msg.isUser
                            ? AppColors.onboardingIndicatorActive
                            : Colors.white,

                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20),

                          bottomLeft: msg.isUser
                              ? Radius.circular(12)
                              : Radius.circular(0),
                          bottomRight: msg.isUser
                              ? Radius.circular(0)
                              : Radius.circular(20),
                        ),
                      ),
                      child: Text(msg.text, style: getTextStyle(fontSize: 16)),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.textController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          final text = controller.textController.text.trim();
                          if (text.isEmpty) return;
                          controller.sendMessage(text);
                        },
                        padding: EdgeInsets.all(8),
                        splashRadius: 20,
                        icon: Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: Image.asset(
                            IconPath.send,
                            height: 25,
                            width: 25,
                            color: Colors.black,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      hintText: "Type a message",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // Attach button
                IconButton(
                  icon: Icon(Icons.attach_file, color: Colors.black),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.image),
                                title: Text('Send Image'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  controller.pickImageAndSend();
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.insert_drive_file),
                                title: Text('Send File'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  controller.pickFileAndSend();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 18),
        ],
      ),
    );
  }
}
