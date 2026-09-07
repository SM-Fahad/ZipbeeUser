class StackedLocationModel {
  String name;
  String address;

  StackedLocationModel({required this.name, required this.address});

  StackedLocationModel copyWith({String? name, String? address}) {
    return StackedLocationModel(
      name: name ?? this.name,
      address: address ?? this.address,
    );
  }
}
