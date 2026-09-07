class LocationModel {
  String name;
  String address;

  LocationModel({required this.name, required this.address});

  LocationModel copyWith({String? name, String? address}) {
    return LocationModel(
      name: name ?? this.name,
      address: address ?? this.address,
    );
  }
}
