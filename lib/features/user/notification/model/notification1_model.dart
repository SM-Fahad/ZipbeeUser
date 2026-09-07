import 'package:intl/intl.dart';

class Notification1Model {
  final String id;
  final String type;
  final String title;
  final String subTitle;
  final String date;
  final String time;
  final String category;
  final String imageUrl;
  final String targetRole;
  final String? orderId;
  final bool isActive;
  final bool isRead;

  Notification1Model({
    required this.id,
    required this.type,
    required this.title,
    required this.subTitle,
    required this.date,
    required this.time,
    required this.category,
    required this.imageUrl,
    required this.targetRole,
    this.orderId,
    required this.isActive,
    required this.isRead,
  });

  factory Notification1Model.fromJson(Map<String, dynamic> json) {
    final createdAtStr = json['createdAt'] ?? json['created_at'];
    final createdAt = createdAtStr != null
        ? DateTime.parse(createdAtStr).toLocal()
        : DateTime.now();

    final markAsReadIds = (json['mark_as_read_id'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];
    final currentUserId = json['_current_user_id']?.toString();
    final isMarkedByCurrentUser =
        currentUserId != null && markAsReadIds.contains(currentUserId);

    return Notification1Model(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      type: (json['type'] ?? '').toString(),
      title: json['title'] ?? '',
      subTitle: json['message'] ?? '',
      date: DateFormat('dd-MM-yyyy').format(createdAt),
      time: DateFormat('hh:mm a').format(createdAt),
      category: (json['category'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      targetRole: (json['target_role'] ?? '').toString(),
      orderId: json['orderId']?.toString(),
      isActive: json['is_active'] == true,
      isRead:
          json['is_read'] == true ||
          json['isReadByUser'] == true ||
          isMarkedByCurrentUser,
    );
  }

  Notification1Model copyWith({
    String? id,
    String? type,
    String? title,
    String? subTitle,
    String? date,
    String? time,
    String? category,
    String? imageUrl,
    String? targetRole,
    String? orderId,
    bool? isActive,
    bool? isRead,
  }) {
    return Notification1Model(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subTitle: subTitle ?? this.subTitle,
      date: date ?? this.date,
      time: time ?? this.time,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      targetRole: targetRole ?? this.targetRole,
      orderId: orderId ?? this.orderId,
      isActive: isActive ?? this.isActive,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "title": title,
    "subTitle": subTitle,
    "date": date,
    "time": time,
    "category": category,
    "imageUrl": imageUrl,
    "targetRole": targetRole,
    "orderId": orderId,
    "isActive": isActive,
    "isRead": isRead,
  };
}
