class StackVehicle {
  final int? id;
  final String name; // vehicle_type or friendly name
  final String
  type; // normalized type e.g., 'CAR', 'VAN', 'TRUCK', 'MOTORCYCLE'
  final double price; // use basePrice as primary price
  final double? basePrice;
  final double? perKmPrice;
  final String details; // dimension + max_load
  final String description;
  final String? dimension;
  final String? maxLoad;
  final bool? isActive;
  final String? imageAsset; // optional
  final String? subtitle; // optional

  StackVehicle({
    this.id,
    required this.name,
    required this.type,
    required this.price,
    this.basePrice,
    this.perKmPrice,
    required this.details,
    required this.description,
    this.dimension,
    this.maxLoad,
    this.isActive,
    this.imageAsset,
    this.subtitle,
  });

  factory StackVehicle.fromApi(Map<String, dynamic> map) {
    final rawMap = map['vehicle_type'] is Map<String, dynamic>
        ? map['vehicle_type'] as Map<String, dynamic>
        : map;
    final vehicleType = (rawMap['vehicle_type'] ?? map['vehicle_type'] ?? '')
        .toString();
    final vehicleName = (rawMap['vehicle_name'] ?? rawMap['vehicle_type'] ?? '')
        .toString();
    double? bp;
    double? pk;
    try {
      bp = rawMap['base_price'] != null
          ? double.tryParse(rawMap['base_price'].toString())
          : null;
    } catch (_) {
      bp = null;
    }
    try {
      pk = rawMap['per_km_price'] != null
          ? double.tryParse(rawMap['per_km_price'].toString())
          : null;
    } catch (_) {
      pk = null;
    }

    final width = rawMap['dimension_width']?.toString();
    final height = rawMap['dimension_height']?.toString();
    final length = rawMap['dimension_length']?.toString();
    final dim =
        [width, height, length].every((value) => value?.isNotEmpty == true)
        ? '${width} x ${height} x ${length}'
        : rawMap['dimension']?.toString();
    final maxLoad = rawMap['max_load']?.toString();
    final desc = (rawMap['vehicle_desc'] ?? '').toString();

    final detailsParts = <String>[];
    if (desc.isNotEmpty) detailsParts.add(desc);
    if (dim != null && dim.isNotEmpty) detailsParts.add(dim);
    if (maxLoad != null && maxLoad.isNotEmpty) {
      detailsParts.add('Up to $maxLoad kg');
    }

    return StackVehicle(
      id: rawMap['id'] is int
          ? rawMap['id'] as int
          : int.tryParse(rawMap['id']?.toString() ?? ''),
      name: vehicleName.isNotEmpty ? vehicleName : vehicleType,
      type: vehicleType,
      price: bp ?? 0.0,
      basePrice: bp,
      perKmPrice: pk,
      details: detailsParts.join(' - '),
      description: desc,
      dimension: dim,
      maxLoad: maxLoad,
      isActive:
          rawMap['isActive'] == true || rawMap['isActive'].toString() == 'true',
    );
  }
}

class StackedAdditionalService {
  final String name;
  final double price;
  final List<String>
  applicableTo; // List of vehicle types this service applies to

  StackedAdditionalService({
    required this.name,
    required this.price,
    required this.applicableTo,
  });
}
