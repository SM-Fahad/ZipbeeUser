class PlaceModel {
  final int id;
  final String name;
  final String address;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String type;
  final String shortName;

  PlaceModel({
    required this.id,
    required this.name,
    required this.address,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.shortName,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'] ?? 0,
      name: json['contact_name'] ?? '',
      address: json['address'] ?? '',
      postalCode: json['postal_code'] ?? '',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      type: json['type'] ?? 'SENDER',
      shortName: json['shortName'] ?? '',
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
