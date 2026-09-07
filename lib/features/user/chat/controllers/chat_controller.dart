import 'dart:convert';
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:ZipBee/features/user/chat/auth_sevice/history.dart';
import 'package:ZipBee/features/user/chat/models/message_model.dart';
import 'package:ZipBee/features/user/chat/socket_service.dart/socket_service.dart';
import 'package:ZipBee/features/user/order/model/order_model.dart';
import 'package:ZipBee/core/service/app_http_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserMessageController extends GetxController {
  final messages = <MessageModel>[].obs;
  final conversationId = RxnString();

  final textController = TextEditingController();
  final scrollController = ScrollController();

  String? orderId;
  String? receiverId;
  String? currentUserId;

  final orderDetails = Rxn<OrderModel>();
  final isOrderDetailsLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;

    orderId = args?['orderId']?.toString();
    receiverId = args?['receiverId']?.toString();

    debugPrint("orderId: $orderId");
    debugPrint("receiverId: $receiverId");

    final uId = (await SharedPreferencesHelper.getUserId())?.toString().trim();
    currentUserId = uId;

    await loadChatHistory();
    await initSocket();
    fetchOrderDetails();

    ever(messages, (_) => _scrollToBottom());
  }

  Future<void> fetchOrderDetails() async {
    if (orderId == null) return;
    try {
      isOrderDetailsLoading.value = true;
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = ApiEndPoint.getOrder.replaceAll("{orderId}", orderId!);

      final response = await AppHttpClient.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];

        final List stops = data['orderStops'] ?? [];
        final pickup = stops.firstWhere(
          (s) => s['type'] == 'PICKUP',
          orElse: () => {},
        );
        final drops = stops.where((s) => s['type'] == 'DROP').toList();

        data['pickup_address'] = pickup['address'] ?? "";
        data['pickup_lat'] = pickup['latitude'];
        data['pickup_long'] = pickup['longitude'];
        data['sender_name'] = data['user']?['username'] ?? "";

        if (drops.isNotEmpty) {
          data['drop_off_address'] = drops.first['address'] ?? "";
          data['drop_off_lat'] = drops.first['latitude'];
          data['drop_off_long'] = drops.first['longitude'];
          data['recipient_name'] =
              drops.first['destination']?['contact_name'] ?? "";
        }

        orderDetails.value = OrderModel.fromJson(data);
      }
    } catch (e) {
      debugPrint("Error fetching order details in chat controller: $e");
    } finally {
      isOrderDetailsLoading.value = false;
    }
  }

  /// Initialize socket connection
  Future<void> initSocket() async {
    debugPrint("Initializing user socket connection...");

    final token = await SharedPreferencesHelper.getAccessToken();
    final userId = await SharedPreferencesHelper.getOrExtractUserId();
    debugPrint("Current UserId: $userId");

    if (token == null) {
      debugPrint("Token missing");
      return;
    }

    currentUserId = userId?.toString().trim();

    await UserSocketService().loadToken();
    UserSocketService().connect(userId: userId);

    // Listen for incoming messages
    UserSocketService().on('receive_message', (data) {
      debugPrint("📩 User received message: $data");

      try {
        final messageData = Map<String, dynamic>.from(data);
        final cId = messageData['conversationId']?.toString();
        if (cId != null && cId.isNotEmpty) {
          conversationId.value = cId;
        }

        final newMessage = MessageModel.fromSocket(
          data: messageData,
          isMe: false,
        );

        messages.add(newMessage);

        // Auto-mark conversation as read
        markConversationAsRead();
      } catch (e) {
        debugPrint("❌ User error parsing received message: $e");
      }
    });

    // Listen for messages read receipt (opposite party viewed message)
    UserSocketService().on('messages_seen', (data) {
      debugPrint("👁️ User messages_seen receipt received: $data");
      try {
        if (data is Map) {
          final seenConvId = data['conversationId']?.toString();
          if (seenConvId == null ||
              conversationId.value == null ||
              seenConvId == conversationId.value) {
            for (var i = 0; i < messages.length; i++) {
              if (messages[i].isMe && !messages[i].isRead) {
                messages[i].isRead = true;
              }
            }
            messages.refresh();
          }
        }
      } catch (e) {
        debugPrint("❌ User error processing messages_seen: $e");
      }
    });
  }

  /// Mark conversation as read via Socket and REST fallback
  void markConversationAsRead() {
    final cId = conversationId.value;
    if (cId == null || cId.isEmpty) return;

    debugPrint("📖 User marking conversation as read: $cId");
    UserSocketService().markAsRead(cId);
    ChatApiService.markAsRead(cId);
  }

  /// Send message
  void sendMessage(String receiverId) {
    debugPrint("Sending message to receiverId: $receiverId, orderId: $orderId");

    final text = textController.text.trim();
    if (text.isEmpty) return;

    final payload = {
      "receiverId": receiverId,
      "orderId": orderId,
      "content": text,
      "messageType": "TEXT",
    };

    UserSocketService().emit('send_message', payload);

    final now = DateTime.now();
    messages.add(
      MessageModel(
        conversationId: conversationId.value,
        text: text,
        isMe: true,
        time: MessageModel.formatTime(now),
        createdAt: now,
        isRead: false,
      ),
    );

    textController.clear();
  }

  //  ─── Load Chat History ─────────────────────────────────────────────

  Future<void> loadChatHistory() async {
    if (receiverId == null || orderId == null) return;

    try {
      final uId = (await SharedPreferencesHelper.getUserId())
          ?.toString()
          .trim();
      currentUserId = uId;

      final dataMap = await ChatApiService.getChatHistoryData(
        receiverId: receiverId!,
        orderId: orderId!,
      );

      if (dataMap == null) return;

      final convId = dataMap['conversationId'] ??
          dataMap['id'] ??
          (dataMap['conversation'] is Map ? dataMap['conversation']['id'] : null);
      if (convId != null) {
        conversationId.value = convId.toString();
      }

      final rawMessages = dataMap['messages'] as List<dynamic>? ?? [];

      final List<MessageModel> history = [];
      for (final msg in rawMessages) {
        final map = Map<String, dynamic>.from(msg);
        if (conversationId.value == null && map['conversationId'] != null) {
          conversationId.value = map['conversationId'].toString();
        }

        history.add(
          MessageModel.fromJson(map, currentUserId: currentUserId),
        );
      }

      messages.assignAll(history);

      debugPrint("📜 User loaded ${history.length} messages from history. ConvId: ${conversationId.value}");

      // Mark messages as read since user opened the chat screen
      if (conversationId.value != null && conversationId.value!.isNotEmpty) {
        markConversationAsRead();
      }
    } catch (e) {
      debugPrint("loadChatHistory error: $e");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    UserSocketService().dispose();
    super.onClose();
  }
}
