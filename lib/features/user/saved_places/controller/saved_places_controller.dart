import 'package:flutter/material.dart';
import 'package:ZipBee/features/user/google_map/service/one_map_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../model/place_model.dart';
import '../service/saved_places_service.dart';

class SavedPlaceController extends GetxController {
  final SavedPlacesService service = SavedPlacesService();
  final ScrollController scrollController = ScrollController();

  final RxList<PlaceModel> savedPlaces = <PlaceModel>[].obs;
  final RxString selectedAddress = ''.obs;
  final RxString selectedPostalCode = ''.obs;
  final RxDouble selectedLatitude = 0.0.obs;
  final RxDouble selectedLongitude = 0.0.obs;
  final RxString selectedType = 'SENDER'.obs;
  final RxInt editingPlaceId = 0.obs;
  final RxString editingPlaceName = ''.obs;
  
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  int _currentPage = 1;
  final int _limit = 10;

  @override
  void onInit() {
    fetchPlaces();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        fetchPlaces(refresh: false);
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchPlaces({bool refresh = true}) async {
    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
      isLoading.value = true;
    } else {
      if (!hasMore.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
    }

    try {
      print('DEBUG SavedPlaceController.fetchPlaces -> called, page: $_currentPage');
      final data = await service.getPlaces(page: _currentPage, limit: _limit);
      print(
        'DEBUG SavedPlaceController.fetchPlaces -> fetched ${data.length} items',
      );
      if (data.length < _limit) {
        hasMore.value = false;
      }
      if (refresh) {
        savedPlaces.assignAll(data);
      } else {
        savedPlaces.addAll(data);
      }
      if (data.isNotEmpty) {
        _currentPage++;
      }
    } catch (e, st) {
      print('DEBUG SavedPlaceController.fetchPlaces -> error: $e');
      print(st);
      EasyLoading.showError('Could not load saved places: $e');
    } finally {
      if (refresh) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
    }
  }

  bool get isEditing => editingPlaceId.value != 0;

  void selectLocation(
    OneMapResolvedAddress location, {
    String type = 'SENDER',
  }) {
    selectedAddress.value = location.address;
    selectedPostalCode.value = location.postalCode;
    selectedLatitude.value = location.lat;
    selectedLongitude.value = location.lng;
    selectedType.value = type;
  }

  void startEditing(PlaceModel place) {
    editingPlaceId.value = place.id;
    editingPlaceName.value = place.name;
    selectedAddress.value = place.address;
    selectedPostalCode.value = place.postalCode;
    selectedLatitude.value = place.latitude;
    selectedLongitude.value = place.longitude;
    selectedType.value = place.type.isEmpty ? 'SENDER' : place.type;
  }

  void clearSelectedPlace() {
    selectedAddress.value = '';
    selectedPostalCode.value = '';
    selectedLatitude.value = 0.0;
    selectedLongitude.value = 0.0;
    selectedType.value = 'SENDER';
    editingPlaceId.value = 0;
    editingPlaceName.value = '';
  }

  String _formatDisplayText(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;

    final hasLetters = RegExp(r'[A-Za-z]').hasMatch(trimmed);
    final isAllUppercase = hasLetters && trimmed == trimmed.toUpperCase();
    if (!isAllUppercase) return trimmed;

    return trimmed.split(RegExp(r'(\s+)')).map((part) {
      if (part.trim().isEmpty) return part;

      return part
          .split('-')
          .map((segment) {
            if (segment.isEmpty) return segment;
            final lower = segment.toLowerCase();
            return '${lower[0].toUpperCase()}${lower.substring(1)}';
          })
          .join('-');
    }).join();
  }

  Future<bool> savePlace(String name) async {
    if (selectedAddress.value.isEmpty) {
      EasyLoading.showError('Address not selected');
      return false;
    }

    if (selectedPostalCode.value.isEmpty) {
      EasyLoading.showError('Postal code not selected');
      return false;
    }

    try {
      isLoading.value = true;

      final String address = selectedAddress.value;
      final String shortName = address.isNotEmpty ? _formatDisplayText(address.split(',').first) : '';

      if (isEditing) {
        await service.updatePlace(
          id: editingPlaceId.value,
          name: name,
          address: selectedAddress.value,
          postalCode: selectedPostalCode.value,
          shortName: shortName,
          latitude: selectedLatitude.value,
          longitude: selectedLongitude.value,
          type: selectedType.value,
          isSaved: true,
        );
      } else {
        await service.addPlace(
          name: name,
          address: selectedAddress.value,
          postalCode: selectedPostalCode.value,
          shortName: shortName,
          latitude: selectedLatitude.value,
          longitude: selectedLongitude.value,
          type: selectedType.value,
          isSaved: true,
        );
      }

      EasyLoading.showSuccess(
        isEditing ? 'Place updated successfully' : 'Place saved successfully',
      );

      clearSelectedPlace();
      await fetchPlaces();

      return true;
    } catch (e) {
      EasyLoading.showError('Unable to save place');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removePlace(int id) async {
    try {
      await service.deletePlace(id);
      savedPlaces.removeWhere((e) => e.id == id);

      EasyLoading.showSuccess('Place removed');
    } catch (e) {
      EasyLoading.showError('Unable to delete place');
    }
  }
}
