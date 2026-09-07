import 'package:ZipBee/features/user/google_map/service/one_map_service.dart';
import 'package:ZipBee/features/user/saved_places/controller/saved_places_controller.dart';
import 'package:ZipBee/features/user/saved_places/name_places/screen/name_places_screen.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class AddPlaceController extends GetxController {
  void onLocationSelected(OneMapResolvedAddress location) {
    debugPrint("--- Selected Saved Place ---");
    debugPrint("Address: ${location.address}");
    debugPrint("Postal Code: ${location.postalCode}");
    debugPrint("Latitude: ${location.lat}");
    debugPrint("Longitude: ${location.lng}");
    debugPrint("----------------------------");

    final savedPlaceController = Get.isRegistered<SavedPlaceController>()
        ? Get.find<SavedPlaceController>()
        : Get.put(SavedPlaceController());
    savedPlaceController.selectLocation(
      location,
      type: savedPlaceController.selectedType.value,
    );
    Get.to(() => NamePlaceScreen());
  }
}
