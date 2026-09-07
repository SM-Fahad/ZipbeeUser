import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:ZipBee/features/user/stacked/stacked_controller/stacked_controller.dart';
import 'package:ZipBee/features/user/vehicle_type/model/model.dart';
import 'package:ZipBee/features/user/vehicle_type/service/vehicle_type_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class StackedVehicleController extends GetxController {
  final selectedVehicle = Rxn<StackVehicle>();
  final selectedServices = <StackedAdditionalService>[].obs;
  final calculationHistory = <String>[].obs;

  // lists populated from API
  final t1 = <StackVehicle>[].obs; // MOTORCYCLE, BICYCLE, ELECTRIC_SCOOTER
  final t2 = <StackVehicle>[].obs; // CAR, SUV
  final t3 = <StackVehicle>[].obs; // VAN
  final t4 = <StackVehicle>[].obs; // TRUCK

  // total route distance (km) used in fare estimation. Default placeholder 1.0
  // Replace this by real routing API calculation using pickup/destination coords.
  final totalDistanceKm = 1.0.obs;

  // keep default additional services as before but note: API does not provide them
  final List<StackedAdditionalService> _allServices = [
    StackedAdditionalService(
      name: 'Controlled zone',
      price: 15.0,
      applicableTo: ['Courier', 'Car'],
    ),
    StackedAdditionalService(
      name: 'Get for me (Food / beverage only)',
      price: 30.0,
      applicableTo: ['Courier'],
    ),
    StackedAdditionalService(
      name: 'Get for me (Others except food / beverage)',
      price: 20.0,
      applicableTo: ['Courier'],
    ),
    StackedAdditionalService(
      name: 'Door-to-door',
      price: 30.0,
      applicableTo: ['Van'],
    ),
    StackedAdditionalService(
      name: 'Tailboard',
      price: 20.0,
      applicableTo: ['Truck'],
    ),
    StackedAdditionalService(
      name: 'Open/Box',
      price: 20.0,
      applicableTo: ['Truck'],
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    // fetchAndCategorize();
  }

  void _syncTopVehicleCategory(String? rawVehicleType) {
    try {
      final locationController = Get.find<StackedLocationController>();
      locationController.selectVehicleByRawType(rawVehicleType);
    } catch (_) {}
  }

  void syncFromOrderData(Map<String, dynamic> orderData) {
    final deliveryType = orderData['delivery_type'] as Map<String, dynamic>?;
    final rawVehicles = deliveryType?['vehicle_types'];

    if (rawVehicles is! List) return;

    final parsed = rawVehicles
        .map((item) {
          final map = item as Map<String, dynamic>;
          final nestedVehicle = map['vehicle_type'] as Map<String, dynamic>?;
          if (nestedVehicle == null) return null;
          return StackVehicle.fromApi(nestedVehicle);
        })
        .whereType<StackVehicle>()
        .where((vehicle) => vehicle.isActive != false)
        .toList();

    t1.clear();
    t2.clear();
    t3.clear();
    t4.clear();

    for (final vehicle in parsed) {
      final type = vehicle.type.toUpperCase();
      if (['MOTORCYCLE', 'BICYCLE', 'ELECTRIC_SCOOTER'].contains(type)) {
        t1.add(vehicle);
      } else if (['CAR', 'SUV'].contains(type)) {
        t2.add(vehicle);
      } else if (type == 'VAN') {
        t3.add(vehicle);
      } else if (type == 'TRUCK') {
        t4.add(vehicle);
      }
    }

    final selectedVehicleId = orderData['vehicle_type_id'];
    final parsedSelectedVehicleId = selectedVehicleId is int
        ? selectedVehicleId
        : int.tryParse(selectedVehicleId?.toString() ?? '');

    if (parsedSelectedVehicleId == null) return;

    final allVehicles = [...t1, ...t2, ...t3, ...t4];
    final matchedVehicle = allVehicles.firstWhereOrNull(
      (vehicle) => vehicle.id == parsedSelectedVehicleId,
    );

    if (matchedVehicle != null) {
      selectedVehicle.value = matchedVehicle;
      _syncTopVehicleCategory(matchedVehicle.type);
      _updateHistory();
    }
  }

  // Future<void> fetchAndCategorize() async {
  //   final res = await VehicleTypeService.fetchVehicleTypes();
  //   if (res['statusCode'] != 200) return;

  //   final body = res['body'];
  //   if (body is Map && body['data'] is List) {
  //     final list = body['data'] as List;
  //     final parsed = list
  //         .map((e) => StackVehicle.fromApi(e as Map<String, dynamic>))
  //         .where((v) => v.isActive == true)
  //         .toList();

  //     // clear previous
  //     t1.clear();
  //     t2.clear();
  //     t3.clear();
  //     t4.clear();

  //     for (var v in parsed) {
  //       final vt = v.type.toUpperCase();
  //       if (['MOTORCYCLE', 'BICYCLE', 'ELECTRIC_SCOOTER'].contains(vt)) {
  //         t1.add(v);
  //       } else if (['CAR', 'SUV'].contains(vt)) {
  //         t2.add(v);
  //       } else if (vt == 'VAN') {
  //         t3.add(v);
  //       } else if (vt == 'TRUCK') {
  //         t4.add(v);
  //       } else {
  //         // skip other types
  //       }
  //     }
  //   }
  // }

  List<StackVehicle> getVehiclesForType(String tabKey) {
    // map older tab keys to categorized lists
    switch (tabKey) {
      case 'Courier':
        return t1;
      case 'Car':
        return t2;
      case 'Van':
        return t3;
      case 'Truck':
        return t4;
      default:
        return [];
    }
  }

  List<StackedAdditionalService> getAdditionalServicesForType(String type) {
    final vehicle = selectedVehicle.value;
    if (vehicle == null) return [];
    return _allServices
        .where((s) => s.applicableTo.contains(vehicle.type))
        .toList();
  }

  void selectVehicle(StackVehicle vehicle) {
    if (selectedVehicle.value == vehicle) {
      selectedVehicle.value = null;
      _syncTopVehicleCategory(null);
      selectedServices.clear();
      calculationHistory.clear();
    } else {
      selectedVehicle.value = vehicle;
      _syncTopVehicleCategory(vehicle.type);
      selectedServices.clear();
      _updateHistory();
    }
  }

  /// Toggle vehicle for order update (with API call)
  Future<void> toggleVehicle(
    StackVehicle vehicle,
    int orderId,
    int deliveryTypeId,
  ) async {
    if (vehicle.id == null) {
      debugPrint("❌ Vehicle ID is null, cannot update");
      EasyLoading.showError("Invalid vehicle");
      return;
    }

    try {
      // Optimistically update UI first
      selectedVehicle.value = vehicle;
      _syncTopVehicleCategory(vehicle.type);
      selectedServices.clear();
      _updateHistory();

      EasyLoading.show(status: "Updating vehicle...");

      // Call API
      final res = await VehicleTypeService.updateVehicleType(
        orderId: orderId,
        vehicleTypeId: vehicle.id!,
        deliveryTypeId: deliveryTypeId,
      );

      final status = res['statusCode'] as int? ?? 500;
      final body = res['body'] as Map<String, dynamic>? ?? {};

      if (status >= 200 && status < 300 && body['success'] == true) {
        debugPrint("✅ Successfully updated vehicle to: ${vehicle.name}");

        // Update order controller if available
        try {
          final orderCtrl = Get.find<StackedOrderController>();
          final data = body['data'] as Map<String, dynamic>? ?? {};
          orderCtrl.syncOrderData(data);
        } catch (_) {}
      } else {
        debugPrint("❌ Failed to update vehicle (Status: $status)");
        // Revert UI on failure
        selectedVehicle.value = null;
        _syncTopVehicleCategory(null);
        selectedServices.clear();
        calculationHistory.clear();

        final msgRaw = body['message'] ?? 'Failed to update vehicle';
        final msg = msgRaw is List ? msgRaw.join('\n') : msgRaw.toString();
        EasyLoading.showError(msg);
      }
    } catch (e) {
      debugPrint("❌ Error toggling vehicle: $e");
      // Revert UI on error
      selectedVehicle.value = null;
      _syncTopVehicleCategory(null);
      selectedServices.clear();
      calculationHistory.clear();
      EasyLoading.showError("Error updating vehicle");
    } finally {
      EasyLoading.dismiss();
    }
  }

  double calculateTotal() {
    // price calculation = basePrice + (perKmPrice * totalDistanceKm) + selected services
    final vehicle = selectedVehicle.value;
    double base = 0.0;
    double perKm = 0.0;
    if (vehicle != null) {
      base = vehicle.basePrice ?? vehicle.price;
      perKm = vehicle.perKmPrice ?? 0.0;
    }

    double vehicleCost = base + (perKm * totalDistanceKm.value);

    double total = vehicleCost;
    total += selectedServices.fold(0.0, (sum, item) => sum + item.price);
    return total;
  }

  void toggleService(StackedAdditionalService service) {
    selectedServices.contains(service)
        ? selectedServices.remove(service)
        : selectedServices.add(service);

    _updateHistory();
  }

  void _updateHistory() {
    calculationHistory.clear();

    if (selectedVehicle.value != null) {
      calculationHistory.add(
        "${selectedVehicle.value!.name}: S\$${selectedVehicle.value!.price.toStringAsFixed(2)}",
      );
    }

    for (var s in selectedServices) {
      calculationHistory.add("${s.name}: S\$${s.price.toStringAsFixed(2)}");
    }
  }
}
