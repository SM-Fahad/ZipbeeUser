import 'package:ZipBee/core/utils/constants/icon_path.dart';

class DeliveryTypeModel {
  final int id;
  final String name;
  final int deliveryTime;
  final String deliveryUnit;
  final String? priceMultiplier;
  final String? icon;

  DeliveryTypeModel({
    required this.id,
    required this.name,
    required this.deliveryTime,
    required this.deliveryUnit,
    required this.priceMultiplier,
    this.icon,
  });

  factory DeliveryTypeModel.fromJson(Map<String, dynamic> json) {
    return DeliveryTypeModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: (json['name'] ?? '').toString(),
      deliveryTime: json['delivery_time'] is int
          ? json['delivery_time']
          : int.tryParse(json['delivery_time']?.toString() ?? '0') ?? 0,
      deliveryUnit: (json['delivery_unit'] ?? 'MINUTES').toString(),
      priceMultiplier: json['price_multiplier']?.toString(),
      icon: json['icon'] as String?,
    );
  }

  static List<DeliveryTypeModel> fromJsonList(List<dynamic> list) {
    return list
        .whereType<Map>()
        .map((item) => DeliveryTypeModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  String get formattedSubtitle {
    return "Delivery within $deliveryTime ${deliveryUnit.toLowerCase()} of collection";
  }

  /// Resolved dynamic icon asset path for this delivery type
  String? get iconPath {
    return getDeliveryTypeIconPath(icon, deliveryType: name, deliveryTypeId: id);
  }

  /// Dynamically map delivery type icon string or name to matching icon asset path.
  static String? getDeliveryTypeIconPath(
    String? iconName, {
    String? deliveryType,
    int? deliveryTypeId,
  }) {
    if (iconName != null && iconName.trim().isNotEmpty) {
      final asset = _resolveAssetFromIconName(iconName);
      if (asset != null) return asset;
    }

    if (deliveryType != null && deliveryType.trim().isNotEmpty) {
      final asset = _resolveAssetFromIconName(deliveryType);
      if (asset != null) return asset;
    }

    return null;
  }

  static String? _resolveAssetFromIconName(String iconName) {
    final rawIcon = iconName.toLowerCase().trim();
    final cleanIcon = rawIcon
        .split('/')
        .last
        .replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '')
        .trim();

    if (cleanIcon.contains('wallet_pricing') || cleanIcon.contains('wallet')) {
      return IconPath.wallet_pricing;
    }
    if (cleanIcon.contains('additional_package') || cleanIcon.contains('additional') || cleanIcon.contains('package')) {
      return IconPath.additional_package;
    }
    if (cleanIcon.contains('express_delivery') || cleanIcon.contains('express')) {
      return IconPath.express_delivery;
    }
    if (cleanIcon.contains('helper_team') || cleanIcon.contains('helper')) {
      return IconPath.helper_team;
    }
    if (cleanIcon.contains('scheduled_delivery') ||
        cleanIcon.contains('scheduled') ||
        cleanIcon.contains('standard') ||
        cleanIcon.contains('saver')) {
      return IconPath.scheduled_delivery;
    }

    return null;
  }
}
