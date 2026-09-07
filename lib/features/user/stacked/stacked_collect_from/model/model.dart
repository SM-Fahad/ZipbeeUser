class StackedAddressModel {
  final int id;
  final String address;
  final String addressFromApr;
  final String floorUnit;
  final String contactName;
  final String contactNumber;
  final String noteToDriver;
  final bool isSaved;
  final String type; // SENDER or RECEIVER
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final int useCount;
  final DateTime? lastUsedAt;
  final String iconPath; // Asset path for icon

  // title and subtitle for UI convenience
  String get title => addressFromApr.isNotEmpty ? addressFromApr : address;
  String get subtitle => floorUnit;

  StackedAddressModel({
    required this.id,
    required this.address,
    required this.addressFromApr,
    required this.floorUnit,
    required this.contactName,
    required this.contactNumber,
    required this.noteToDriver,
    required this.isSaved,
    required this.type,
    this.latitude,
    this.longitude,
    this.accuracy,
    required this.useCount,
    this.lastUsedAt,
    required this.iconPath,
  });

  factory StackedAddressModel.fromJson(Map<String, dynamic> json, {String iconPath = ''}) {
    return StackedAddressModel(
      id: json['id'] ?? 0,
      address: json['address'] ?? '',
      addressFromApr: json['addressFromApr'] ?? '',
      floorUnit: json['floor_unit'] ?? '',
      contactName: json['contact_name'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      noteToDriver: json['note_to_driver'] ?? '',
      isSaved: json['is_saved'] ?? false,
      type: json['type'] ?? '',
      latitude: (json['latitude'] is num) ? (json['latitude'] as num).toDouble() : null,
      longitude: (json['longitude'] is num) ? (json['longitude'] as num).toDouble() : null,
      accuracy: (json['accuracy'] is num) ? (json['accuracy'] as num).toDouble() : null,
      useCount: json['useCount'] is int ? json['useCount'] : (json['useCount'] is num ? (json['useCount'] as num).toInt() : 0),
      lastUsedAt: json['lastUsedAt'] != null ? DateTime.tryParse(json['lastUsedAt']) : null,
      iconPath: iconPath,
    );
  }
}
