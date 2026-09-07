import 'package:intl/intl.dart';

class MessageModel {
  final String? id;
  final String? conversationId;
  final String? senderId;
  final String? receiverId;
  final String text;
  final bool isMe;
  final String time;
  final DateTime? createdAt;
  bool isRead;
  final String? messageType;
  final String? status;

  MessageModel({
    this.id,
    this.conversationId,
    this.senderId,
    this.receiverId,
    required this.text,
    required this.isMe,
    required this.time,
    this.createdAt,
    this.isRead = false,
    this.messageType = 'TEXT',
    this.status,
  });

  factory MessageModel.fromSocket({
    required Map<String, dynamic> data,
    required bool isMe,
  }) {
    final rawDate = data['createdAt'] ?? data['time'];
    DateTime? dt;
    if (rawDate != null) {
      try {
        dt = DateTime.parse(rawDate.toString()).toLocal();
      } catch (_) {}
    }
    dt ??= DateTime.now();

    final isReadVal = data['isRead'] == true ||
        data['status'] == 'read' ||
        data['status'] == 'seen' ||
        data['readAt'] != null;

    return MessageModel(
      id: data['id']?.toString() ?? data['_id']?.toString(),
      conversationId: data['conversationId']?.toString(),
      senderId: data['senderId']?.toString(),
      receiverId: data['receiverId']?.toString(),
      text: data['content'] ?? data['message'] ?? '',
      isMe: isMe,
      time: formatTime(dt),
      createdAt: dt,
      isRead: isReadVal,
      messageType: data['messageType']?.toString() ?? 'TEXT',
      status: data['status']?.toString(),
    );
  }

  factory MessageModel.fromJson(
    Map<String, dynamic> json, {
    required String? currentUserId,
  }) {
    final senderId = (json['senderId'] ?? json['from'] ?? json['sender']?['id'] ?? json['sender'])
        ?.toString()
        .trim();

    final isMe = senderId != null &&
        currentUserId != null &&
        senderId.isNotEmpty &&
        senderId == currentUserId.trim();

    final rawDate = json['createdAt'] ?? json['created_at'] ?? json['time'];
    DateTime? dt;
    if (rawDate != null) {
      try {
        dt = DateTime.parse(rawDate.toString()).toLocal();
      } catch (_) {}
    }
    dt ??= DateTime.now();

    final isReadVal = json['isRead'] == true ||
        json['status'] == 'read' ||
        json['status'] == 'seen' ||
        json['readAt'] != null;

    return MessageModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      conversationId: json['conversationId']?.toString(),
      senderId: senderId,
      receiverId: json['receiverId']?.toString(),
      text: (json['content'] ?? json['message'] ?? '').toString(),
      isMe: isMe,
      time: formatTime(dt),
      createdAt: dt,
      isRead: isReadVal,
      messageType: json['messageType']?.toString() ?? 'TEXT',
      status: json['status']?.toString(),
    );
  }

  static String formatTime(DateTime time) {
    try {
      return DateFormat('hh:mm a').format(time);
    } catch (_) {
      return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
    }
  }
}
