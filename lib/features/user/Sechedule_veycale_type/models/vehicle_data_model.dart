import 'package:ZipBee/core/utils/constants/icon_path.dart';

class Vehicle {
  final String id; // ✅ REQUIRED
  final String name;
  final String type; // Courier, Car, Van, Truck
  final double price;
  final String details;
  final String? imageAsset;
  final String? subtitle;

  Vehicle({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.details,
    this.imageAsset,
    this.subtitle,
  });
}

class AdditionalService {
  final String id;
  final String name;
  final double price;
  final List<String> applicableTo;

  AdditionalService({
    required this.id,
    required this.name,
    required this.price,
    required this.applicableTo,
  });
}

class VehicleData {
  static final List<Vehicle> allVehicles = [
    Vehicle(
      id: 'courier',
      name: 'Courier',
      type: 'Courier',
      subtitle: 'Perfect for small goods',
      price: 15,
      details: '40x30x30 cm - Up to 8 kg',
      imageAsset: IconPath.courierIcon,
    ),
    Vehicle(
      id: 'car',
      name: 'Car',
      type: 'Car',
      subtitle: 'Medium size items',
      price: 15,
      details: '70x50x50 cm - Up to 20 kg',
      imageAsset: IconPath.realCar,
    ),
    Vehicle(
      id: 'mpv',
      name: 'MPV',
      type: 'Car',
      subtitle: 'Small-medium cartons',
      price: 25,
      details: '110x80x50 cm - Up to 50 kg',
      imageAsset: IconPath.realCar,
    ),
    Vehicle(
      id: 'van_17',
      name: '1.7 m Van',
      type: 'Van',
      price: 30,
      details: 'Up to 400 kg',
      imageAsset: IconPath.van,
    ),
    Vehicle(
      id: 'truck_10',
      name: '10 ft Truck',
      type: 'Truck',
      price: 50,
      details: 'Up to 2000 kg',
      imageAsset: IconPath.trunk1,
    ),
  ];

  static final List<AdditionalService> allServices = [
    AdditionalService(
      id: 'controlled_zone',
      name: 'Controlled zone',
      price: 15,
      applicableTo: ['Courier', 'Car'],
    ),
    AdditionalService(
      id: 'food',
      name: 'Get for me (Food)',
      price: 30,
      applicableTo: ['Courier'],
    ),
    AdditionalService(
      id: 'tailboard',
      name: 'Tailboard',
      price: 20,
      applicableTo: ['Truck'],
    ),
  ];
}
