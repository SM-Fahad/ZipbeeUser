// ignore_for_file: file_names

import 'dart:convert';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/Veicale_Type_on_Exprees_Delivery/models/vehicle_data_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class VehicleController extends GetxController {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 80,
      printEmojis: true,
      printTime: false,
    ),
  );

  final selectedVehicle = Rxn<Vehicle>();
  final selectedServices = <AdditionalService>[].obs;
  final calculationHistory = <String>[].obs;

  final isLoading = false.obs;
  final List<Vehicle> _allVehicles = [];

  final List<AdditionalService> _allServices = [
    AdditionalService(
      name: 'Controlled zone',
      price: 15.0,
      applicableTo: ['Courier', 'Car'],
    ),
    AdditionalService(
      name: 'Get for me (Food / beverage only)',
      price: 30.0,
      applicableTo: ['Courier'],
    ),
    AdditionalService(
      name: 'Get for me (Others except food / beverage)',
      price: 20.0,
      applicableTo: ['Courier'],
    ),
    AdditionalService(name: 'Door-to-door', price: 30.0, applicableTo: ['Van']),
    AdditionalService(name: 'Tailboard', price: 20.0, applicableTo: ['Truck']),
    AdditionalService(name: 'Open/Box', price: 20.0, applicableTo: ['Truck']),
  ];

  @override
  void onInit() {
    _logger.i('VehicleController init');
    fetchVehicleTypes();
    super.onInit();
  }

  // ================= API =================

  Future<void> fetchVehicleTypes() async {
    try {
      isLoading.value = true;
      _logger.i('Fetching vehicle types');

      final response = await http.get(
        Uri.parse(ApiEndPoint.vehicleTypes),
        headers: {'Content-Type': 'application/json'},
      );

      _logger.i('API status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['success'] == true) {
          final List data = decoded['data'];

          _allVehicles
            ..clear()
            ..addAll(
              data.map<Vehicle>((e) => Vehicle(
                    id: e['id'] ?? 0,
                    name: e['vehicle_type'],
                    type: _mapType(e['vehicle_type']),
                    subtitle: _buildSubtitle(e['vehicle_type']),
                    price: double.parse(e['base_price'].toString()),
                    details:
                        "${e['dimension']} - Up to ${e['max_load']} kg",
                    imageAsset: _mapIcon(e['vehicle_type']),
                    peakPricing: e['peak_pricing'] ?? false,
                  )),
            );

          _logger.i(
            'Vehicle loaded: ${_allVehicles.length}',
          );
        } else {
          _logger.w(
            'API success=false | message: ${decoded['message']}',
          );
        }
      } else {
        _logger.e('API failed: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logger.e(
        'Vehicle API exception',
        error: e,
        stackTrace: stack,
      );
      Get.snackbar('Error', 'Failed to load vehicle types');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // ================= HELPERS =================

  List<Vehicle> getVehiclesForType(String type) =>
      _allVehicles.where((v) => v.type == type).toList();

  List<AdditionalService> getAdditionalServicesForType(String type) {
    final vehicle = selectedVehicle.value;
    if (vehicle == null) return [];
    return _allServices
        .where((s) => s.applicableTo.contains(vehicle.type))
        .toList();
  }

  void selectVehicle(Vehicle vehicle) {
    selectedVehicle.value =
        selectedVehicle.value == vehicle ? null : vehicle;
    selectedServices.clear();
    _updateHistory();

    _logger.i('Vehicle selected: ${vehicle.name}');
  }

  void toggleService(AdditionalService service) {
    selectedServices.contains(service)
        ? selectedServices.remove(service)
        : selectedServices.add(service);

    _logger.i('Service toggled: ${service.name}');
    _updateHistory();
  }

  double calculateTotal() {
    double total = selectedVehicle.value?.price ?? 0;
    total += selectedServices.fold(0.0, (s, e) => s + e.price);
    return total;
  }

  void _updateHistory() {
    calculationHistory.clear();

    if (selectedVehicle.value != null) {
      calculationHistory.add(
        "${selectedVehicle.value!.name}: S\$${selectedVehicle.value!.price.toStringAsFixed(2)}",
      );
    }

    for (var s in selectedServices) {
      calculationHistory.add(
        "${s.name}: S\$${s.price.toStringAsFixed(2)}",
      );
    }
  }

  bool get isOrderReady => selectedVehicle.value != null;

  // ================= MAPPERS =================

  String _mapType(String apiType) {
    final t = apiType.toLowerCase();
    if (t.contains('truck')) return 'Truck';
    if (t.contains('van')) return 'Van';
    if (t.contains('car') || t.contains('suv')) return 'Car';
    return 'Courier';
  }

  String _buildSubtitle(String type) {
    final t = type.toLowerCase();
    if (t.contains('truck')) return 'Delivery of large & bulky items';
    if (t.contains('van')) return 'Van delivery of medium-large items';
    if (t.contains('car') || t.contains('suv')) {
      return 'Car delivery of medium size items';
    }
    return 'Perfect for small goods, with a faster order pickup time';
  }

  String _mapIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('truck')) return IconPath.trunk1;
    if (t.contains('van')) return IconPath.van;
    if (t.contains('car') || t.contains('suv')) return IconPath.realCar;
    return IconPath.courierIcon;
  }
}
