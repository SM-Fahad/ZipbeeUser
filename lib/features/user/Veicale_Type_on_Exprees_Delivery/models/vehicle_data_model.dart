import 'package:ZipBee/core/utils/constants/icon_path.dart';

class Vehicle {
  final int id;
  final String name;
  final String type;
  final String subtitle;
  final double price;
  final String details;
  final String imageAsset;
  final bool peakPricing;

  Vehicle({
    required this.id,
    required this.name,
    required this.type,
    required this.subtitle,
    required this.price,
    required this.details,
    required this.imageAsset,
    required this.peakPricing,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      name: json['vehicle_type'],          // 👉 UI title
      type: json['vehicle_type'],
      subtitle: _buildSubtitle(json),      // 👉 UI subtitle
      price: double.parse(json['base_price'].toString()),
      details:
          "${json['dimension']} • Max ${json['max_load']} kg",
      imageAsset: _mapVehicleIcon(json['vehicle_type']),
      peakPricing: json['peak_pricing'] ?? false,
    );
  }

  static String _buildSubtitle(Map<String, dynamic> json) {
    if (json['vehicle_type'].toString().toLowerCase().contains('truck')) {
      return 'Delivery of large & bulky items';
    }
    if (json['vehicle_type'].toString().toLowerCase().contains('van')) {
      return 'Ideal for medium-large deliveries';
    }
    return 'Fast and reliable delivery';
  }

  static String _mapVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'suv':
      case 'car':
        return IconPath.realCar;
      case 'van':
        return IconPath.van;
      case 'truck':
        return IconPath.trunk1;
      default:
        return IconPath.bike;
    }
  }
}


class AdditionalService {
  final String name;
  final double price;
  final List<String>
  applicableTo; // List of vehicle types this service applies to

  AdditionalService({
    required this.name,
    required this.price,
    required this.applicableTo,
  });
}

