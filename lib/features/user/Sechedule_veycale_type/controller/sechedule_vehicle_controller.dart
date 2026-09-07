import 'package:get/get.dart';
import '../models/vehicle_data_model.dart';

class VehicleSelectionController extends GetxController {
  final Rxn<Vehicle> selectedVehicle = Rxn<Vehicle>();
  final RxList<AdditionalService> selectedServices = <AdditionalService>[].obs;

  double get totalAmount {
    final base = selectedVehicle.value?.price ?? 0;
    final services =
        selectedServices.fold(0.0, (sum, s) => sum + s.price);
    return base + services;
  }

  bool get isOrderReady => selectedVehicle.value != null;

  List<Vehicle> getVehiclesByType(String type) {
    return VehicleData.allVehicles
        .where((v) => v.type == type)
        .toList();
  }

  List<AdditionalService> get availableServices {
    final vehicle = selectedVehicle.value;
    if (vehicle == null) return [];
    return VehicleData.allServices
        .where((s) => s.applicableTo.contains(vehicle.type))
        .toList();
  }

  void selectVehicle(Vehicle vehicle) {
    if (selectedVehicle.value?.id == vehicle.id) {
      selectedVehicle.value = null;
      selectedServices.clear();
    } else {
      selectedVehicle.value = vehicle;
      selectedServices.clear();
    }
  }

  void toggleService(AdditionalService service) {
    selectedServices.contains(service)
        ? selectedServices.remove(service)
        : selectedServices.add(service);
  }

  List<String> get calculationHistory {
    final list = <String>[];
    if (selectedVehicle.value != null) {
      list.add(
        '${selectedVehicle.value!.name}: S\$${selectedVehicle.value!.price}',
      );
    }
    for (final s in selectedServices) {
      list.add('${s.name}: S\$${s.price}');
    }
    return list;
  }
}
