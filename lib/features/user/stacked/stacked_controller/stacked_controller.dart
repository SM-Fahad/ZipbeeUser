import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:get/get.dart';

class StackedVehicleModel {
  final String vehicleType;
  final String iconPath;
  StackedVehicleModel(this.vehicleType, this.iconPath);
}

/// Model to store address data returned from destination API
class AddressData {
  final int id;
  final String address;
  final String addressFromApr;
  final String floorUnit;
  final String contactName;
  final String contactNumber;
  final String noteToDriver;
  final bool isSaved;
  final String type; // SENDER or RECEIVER

  AddressData({
    required this.id,
    required this.address,
    required this.addressFromApr,
    required this.floorUnit,
    required this.contactName,
    required this.contactNumber,
    required this.noteToDriver,
    required this.isSaved,
    required this.type,
  });
}

class StackedLocationController extends GetxController {
  // trip/time state
  var isRoundTrip = false.obs;
  var isNowSelected = true.obs;
  var collectTimeSubtitle = "Pick Date and Time".obs;

  void selectNow() {
    isNowSelected.value = true;
    collectTimeSubtitle.value = "Pick Date and Time"; // রিসেট
  }

  void selectSchedule() {
    isNowSelected.value = false;
  }

  void updateSubtitle(String newTime) {
    collectTimeSubtitle.value = newTime;
  }

  // editing state used by widgets that allow inline title edit
  var isEditing = false.obs;

  // Sender and Receiver address data (primary)
  var senderData = Rxn<AddressData>();
  var receiverData = Rxn<AddressData>();

  // Allow multiple collected / recipient stops for stacked flow
  var collectedStops = <AddressData>[].obs;
  var recipientStops = <AddressData>[].obs;

  // vehicles
  var vehicleList = <StackedVehicleModel>[].obs;

  // selected vehicle state
  var selectedVehicle = Rxn<StackedVehicleModel>();

  @override
  void onInit() {
    super.onInit();
    loadVehicleData();
  }

  // Load initial vehicles
  void loadVehicleData() {
    vehicleList.value = [
      StackedVehicleModel('Bike', IconPath.bike2),
      StackedVehicleModel('Car', IconPath.car2),
      StackedVehicleModel('Van', IconPath.shopcar),
      StackedVehicleModel('Truck', IconPath.shipment),
    ];
  }

  // void selectNow() => isNowSelected.value = true;
  // void selectSchedule() => isNowSelected.value = false;
  void toggleTripType(bool isRound) => isRoundTrip.value = isRound;

  void selectVehicle(StackedVehicleModel vehicle) {
    selectedVehicle.value = vehicle;
  }

  String? normalizeVehicleCategory(String? rawVehicleType) {
    final type = rawVehicleType?.trim().toUpperCase();
    if (type == null || type.isEmpty) return null;

    if (['MOTORCYCLE', 'BICYCLE', 'ELECTRIC_SCOOTER'].contains(type)) {
      return 'Bike';
    }
    if (['CAR', 'SUV'].contains(type)) {
      return 'Car';
    }
    if (type == 'VAN') {
      return 'Van';
    }
    if (type == 'TRUCK') {
      return 'Truck';
    }

    return null;
  }

  void selectVehicleByCategory(String? category) {
    if (category == null || category.trim().isEmpty) {
      selectedVehicle.value = null;
      return;
    }

    for (final vehicle in vehicleList) {
      if (vehicle.vehicleType.toUpperCase() == category.toUpperCase()) {
        selectedVehicle.value = vehicle;
        return;
      }
    }
  }

  void selectVehicleByRawType(String? rawVehicleType) {
    selectVehicleByCategory(normalizeVehicleCategory(rawVehicleType));
  }

  /// Update sender data when saved from schedule sender screen
  void updateSenderData(AddressData data) {
    senderData.value = data;
    // keep first collected stop in sync with primary sender
    if (collectedStops.isEmpty) {
      collectedStops.add(data);
    } else {
      collectedStops[0] = data;
    }
  }

  /// Update receiver data when saved from schedule recipient screen
  void updateReceiverData(AddressData data) {
    receiverData.value = data;
    // keep first recipient stop in sync with primary receiver
    if (recipientStops.isEmpty) {
      recipientStops.add(data);
    } else {
      recipientStops[0] = data;
    }
  }

  /// Add an additional collected stop
  void addCollectedStop(AddressData data) {
    collectedStops.add(data);
  }

  /// Add an additional recipient stop
  void addRecipientStop(AddressData data) {
    recipientStops.add(data);
  }

  /// Get sender display text (name + address)
  String get senderDisplayName => senderData.value?.contactName ?? '';
  String get senderDisplayAddress =>
      senderData.value?.addressFromApr ?? 'Sender Address';

  /// Get receiver display text (name + address)
  String get receiverDisplayName => receiverData.value?.contactName ?? '';
  String get receiverDisplayAddress =>
      receiverData.value?.addressFromApr ?? 'Delivered Address';
}
