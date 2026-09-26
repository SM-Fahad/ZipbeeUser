import 'dart:convert';
import 'package:ZipBee/features/user/google_map/service/one_map_service.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ZipBee/features/user/stacked/schedule_stacked_%20delivey/Schedule_recepent/service/destination_service.dart';
import 'package:get/get.dart';

class RecipientController extends GetxController {
  final postalCodeController = TextEditingController();
  final addressController = TextEditingController();
  final floorController = TextEditingController();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final noteController = TextEditingController();
  String shortName = '';

  final selectedCountryCode = '+65'.obs;
  final isFormValid = false.obs;
  final saveAddress = false.obs;
  final isLoading = false.obs;
  final totalCost = 0.0.obs;

  bool _isApplyingResolvedLocation = false;

  @override
  void onInit() {
    super.onInit();
    postalCodeController.addListener(() {
      onPostalCodeChanged(postalCodeController.text);
      validateForm();
    });
    addressController.addListener(validateForm);
    floorController.addListener(validateForm);
    nameController.addListener(validateForm);
    numberController.addListener(validateForm);
  }

  void validateForm() {
    isFormValid.value =
        addressController.text.isNotEmpty &&
        floorController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        numberController.text.isNotEmpty;
  }

  void clearForm() {
    postalCodeController.clear();
    addressController.clear();
    floorController.clear();
    nameController.clear();
    selectedCountryCode.value = '+65';
    numberController.clear();
    noteController.clear();
    shortName = '';
    saveAddress.value = false;
    isFormValid.value = false;
  }

  void onPostalCodeChanged(String value) async {
    if (_isApplyingResolvedLocation) return;

    final query = value.trim();
    if (query.length < 3) return;

    try {
      final resolved = await OneMapService.resolveQuery(query);
      if (postalCodeController.text.trim() != query || resolved == null) {
        return;
      }

      if (addressController.text != resolved.address) {
        addressController.text = resolved.address;
      }
      shortName = resolved.shortName;
    } catch (e) {
      debugPrint("Postal Code lookup error: $e");
    }
  }

  void applyResolvedLocation(OneMapResolvedAddress resolved) {
    _isApplyingResolvedLocation = true;
    postalCodeController.text = resolved.postalCode;
    addressController.text = resolved.address;
    shortName = resolved.shortName;
    _isApplyingResolvedLocation = false;
    validateForm();
  }

  void updateCountryCode(String code) {
    selectedCountryCode.value = code;
    validateForm();
  }

  String get fullContactNumber =>
      '${selectedCountryCode.value}${numberController.text.trim()}';

  void setContactNumber(String contactNumber) {
    final normalizedNumber = contactNumber.trim().replaceAll(' ', '');

    if (normalizedNumber.isEmpty) {
      selectedCountryCode.value = '+65';
      numberController.clear();
      return;
    }

    if (!normalizedNumber.startsWith('+')) {
      numberController.text = normalizedNumber;
      return;
    }

    final maxDialCodeLength = normalizedNumber.length < 5
        ? normalizedNumber.length
        : 5;

    for (int end = maxDialCodeLength; end >= 2; end--) {
      final dialCode = normalizedNumber.substring(0, end);
      if (CountryCode.tryFromDialCode(dialCode) != null) {
        selectedCountryCode.value = dialCode;
        numberController.text = normalizedNumber.substring(end);
        return;
      }
    }

    selectedCountryCode.value = '+65';
    numberController.text = normalizedNumber.replaceFirst('+', '');
  }

  /// Creates a destination record on the server and links it to order. Returns destination data on success, otherwise null.
  Future<Map<String, dynamic>?> saveDestination({
    String type = 'RECEIVER',
    required int orderId,
  }) async {
    if (!isFormValid.value) return null;
    isLoading.value = true;
    EasyLoading.show(status: 'Saving...');

    final body = {
      'address': addressController.text,
      'postal_code': postalCodeController.text,
      'shortName': shortName,
      'floor_unit': floorController.text,
      'contact_name': nameController.text,
      'contact_number': fullContactNumber,
      'note_to_driver': noteController.text,
      'is_saved': saveAddress.value,
      'type': type, // SENDER / RECEIVER
    };

    // 1️⃣ POST: Create destination
    final destRes = await DestinationService.createDestination(body);
    final destSuccess = destRes['success'] as bool? ?? false;

    debugPrint('📊 CREATE DESTINATION - Success: $destSuccess');

    if (!destSuccess) {
      isLoading.value = false;
      EasyLoading.dismiss();
      final msg =
          (destRes['body'] as Map<String, dynamic>?)?['message'] ??
          'Failed to create destination';
      EasyLoading.showError(msg.toString());
      return null;
    }

    // Extract destination ID from nested response
    final destData = destRes['body'] as Map<String, dynamic>? ?? {};
    final dataWrapper = destData['data'] as Map<String, dynamic>? ?? {};

    // Try to extract ID from either dataWrapper directly, 'result', or nested 'data'
    Map<String, dynamic> actualDestData = {};
    if (dataWrapper.containsKey('id')) {
      actualDestData = dataWrapper;
    } else if (dataWrapper['result'] is Map<String, dynamic>) {
      actualDestData = dataWrapper['result'] as Map<String, dynamic>;
    } else if (dataWrapper['data'] is Map<String, dynamic>) {
      actualDestData = dataWrapper['data'] as Map<String, dynamic>;
    } else if (destData.containsKey('id')) {
      actualDestData = destData;
    }

    debugPrint('✅ DESTINATION CREATED: ${jsonEncode(actualDestData)}');

    final destinationId = actualDestData['id'] is int
        ? actualDestData['id'] as int
        : int.tryParse(actualDestData['id']?.toString() ?? '') ?? 0;
    debugPrint('📋 Destination ID: $destinationId');

    if (destinationId == 0) {
      isLoading.value = false;
      EasyLoading.dismiss();
      EasyLoading.showError('Invalid destination ID received');
      return null;
    }

    // 2️⃣ PATCH: Link destination to order (ONLY if CREATE succeeded)
    final stopType = type == 'SENDER' ? 'PICKUP' : 'DROP';
    final patchRes = await DestinationService.addDestinationToOrder(
      orderId: orderId,
      destinationId: destinationId,
      stopType: stopType,
    );
    debugPrint('ei je salay  - Success: $patchRes');
    final patchSuccess = patchRes['success'] as bool? ?? false;

    if (!patchSuccess) {
      isLoading.value = false;
      EasyLoading.dismiss();
      // final msg = (patchRes['body'] as Map<String, dynamic>?)?['message'] ?? 'Failed to link destination';
      final msg =
          (patchRes['body'] as Map<String, dynamic>?)?['error']?['message'] ??
          (patchRes['body'] as Map<String, dynamic>?)?['message'] ??
          'Failed to link destination';
      // final msg = "Go to Sleep with master oil";
      EasyLoading.showError(msg.toString());
      return null;
    }

    final patchData = patchRes['body'] as Map<String, dynamic>? ?? {};
    debugPrint('✅ DESTINATION LINKED: ${jsonEncode(patchData)}');

    final patchTotalCost = patchData['totalCost'] as num? ?? 0;
    totalCost.value = patchTotalCost.toDouble();
    debugPrint('💰 Total Cost Updated: \$${totalCost.value}');

    isLoading.value = false;
    EasyLoading.dismiss();
    EasyLoading.showSuccess('Order updated');

    return actualDestData;
  }

  @override
  void onClose() {
    postalCodeController.dispose();
    addressController.dispose();
    floorController.dispose();
    nameController.dispose();
    numberController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
