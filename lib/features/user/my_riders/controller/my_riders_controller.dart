import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:ZipBee/core/utils/constants/image_path.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class MyRidersController extends GetxController {
  var ridersList = <Map<String, dynamic>>[].obs;
  var loveState =
      <int, bool>{}.obs; // keyed by myRaiderId to avoid name collisions
  var swipeProgress = <String, double>{}.obs;

  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final RxString selectedCountryCode = '+65'.obs;

  final GetConnect _connect = GetConnect();
  var token = ''.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadToken().then((_) => fetchRiders());
  }

  Future<void> addRider() async {
    final phoneNumber = phoneController.text.trim();
    final email = emailController.text.trim();
    final fullPhoneNumber = _buildFullPhoneNumber(phoneNumber);

    if (fullPhoneNumber.isEmpty && email.isEmpty) {
      EasyLoading.showError("Please enter phone number or email");
      return;
    }

    if (phoneNumber.isNotEmpty && phoneNumber.length <= 4) {
      EasyLoading.showError("Phone number too short");
      return;
    }

    if (token.value.isEmpty) await _loadToken();

    try {
      isLoading.value = true;
      EasyLoading.show(status: "Adding rider...");

      Map<String, dynamic> body = {"is_fav": false};
      if (fullPhoneNumber.isNotEmpty) body["find_by"] = fullPhoneNumber;
      if (email.isNotEmpty) body["email"] = email;

      final response = await _connect.post(
        ApiEndPoint.addRaider,
        body,
        headers: {
          "Authorization": "Bearer ${token.value}",
          "Content-Type": "application/json",
        },
      );

      debugPrint("[ADD RIDER] Status Code: ${response.statusCode}");
      debugPrint("[ADD RIDER] Response Body: ${response.body}");

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body?['success'] == true) {
        phoneController.clear();
        selectedCountryCode.value = '+65';
        emailController.clear();
        Get.back();

        EasyLoading.showSuccess("Rider added successfully");

        await fetchRiders();
      } else {
        EasyLoading.showError(
          response.body?['message'] ?? "Failed to add rider",
        );
      }
    } catch (e) {
      debugPrint("[ADD RIDER] Exception: $e");
      EasyLoading.showError("Network error or server issue");
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  Future<void> deleteRider(int myRaiderId) async {
    if (token.value.isEmpty) await _loadToken();

    try {
      isLoading.value = true;
      EasyLoading.show(status: "Deleting rider...");

      final response = await _connect.delete(
        "${ApiEndPoint.deleteRaider}/$myRaiderId",
        headers: {
          "Authorization": "Bearer ${token.value}",
          "Content-Type": "application/json",
        },
      );

      debugPrint("[DELETE RIDER] Status Code: ${response.statusCode}");
      debugPrint("[DELETE RIDER] Response Body: ${response.body}");

      if (response.statusCode == 200 && response.body?['success'] == true) {
        ridersList.removeWhere((rider) => rider['myRaiderId'] == myRaiderId);
        ridersList.refresh();

        EasyLoading.showSuccess("Rider deleted successfully");
        await fetchRiders();
      } else {
        EasyLoading.showError(
          response.body?['message'] ?? "Failed to delete rider",
        );
      }
    } catch (e) {
      debugPrint("[DELETE RIDER] Exception: $e");
      EasyLoading.showError("Network error or server issue");
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  Future<void> fetchRiders() async {
    if (token.value.isEmpty) await _loadToken();

    try {
      isLoading.value = true;
      EasyLoading.show(status: "Fetching riders...");

      final response = await _connect.get(
        ApiEndPoint.getRaider,
        headers: {
          "Authorization": "Bearer ${token.value}",
          "Content-Type": "application/json",
        },
      );

      debugPrint("Fetch Riders Status Code: ${response.statusCode}");
      debugPrint("Fetch Riders Response Body: ${response.body}");

      if (response.statusCode == 200 && response.body?['success'] == true) {
        final List data = response.body['data']['data'] ?? [];
        ridersList.clear();

        for (var rider in data) {
          final raiderData = rider['raider'] ?? {};
          final driverPhotos = raiderData['driver_photos'] is List
              ? raiderData['driver_photos'] as List
              : [];
          final riderImage = driverPhotos.isNotEmpty
              ? (driverPhotos.first ?? '').toString()
              : '';

          final riderMap = {
            'name': raiderData['raider_name'] ?? 'Unknown',
            'findBy': rider['find_by'] ?? '',
            'raiderId': raiderData['id'],
            'myRaiderId': rider['id'],
            'driverPhotos': driverPhotos,
            'image': riderImage.isNotEmpty ? riderImage : ImagePath.profile1,
          };

          ridersList.add(riderMap);
          final isFav = rider['is_fav'] == true;
          loveState[riderMap['myRaiderId']] = isFav;
        }

        debugPrint("[FETCH RIDERS] Fetched ${ridersList.length} riders.");
      } else {
        EasyLoading.showError(
          response.body?['message'] ?? "Unable to fetch riders",
        );
      }
    } catch (e) {
      debugPrint("[FETCH RIDERS] Exception: $e");
      EasyLoading.showError("Network error or server issue");
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  Future<void> toggleFavoriteApi(int myRaiderId, String name) async {
    debugPrint("[FAV] Tapped favorite for $name (myRaiderId: $myRaiderId)");
    if (token.value.isEmpty) await _loadToken();

    final previous = loveState[myRaiderId] ?? false;
    try {
      loveState[myRaiderId] = !previous;
      loveState.refresh();

      final response = await _connect.patch(
        "${ApiEndPoint.addRaider}/$myRaiderId",
        {"is_fav": loveState[myRaiderId]},
        headers: {
          "Authorization": "Bearer ${token.value}",
          "Content-Type": "application/json",
        },
      );

      debugPrint("[FAV] Response code: ${response.statusCode}");
      debugPrint("[FAV] Response body: ${response.body}");

      final success =
          (response.statusCode == 200 || response.statusCode == 201) &&
              response.body?['success'] == true;

      if (!success) {
        loveState[myRaiderId] = previous; // revert on failure
        loveState.refresh();
        EasyLoading.showError(
          response.body?['message'] ?? "Failed to update favorite",
        );
      }
    } catch (e) {
      loveState[myRaiderId] = previous;
      loveState.refresh();
      EasyLoading.showError("Network error or server issue");
    }
  }

  void toggleLove(int myRaiderId) {
    loveState[myRaiderId] = !(loveState[myRaiderId] ?? false);
  }

  void updateSwipeProgress(String name, double progress) {
    swipeProgress[name] = progress;
  }

  void updateCountryCode(String code) {
    selectedCountryCode.value = code;
  }

  void setContactNumber(String rawPhoneNumber) {
    final normalized = rawPhoneNumber.trim();
    if (normalized.isEmpty) {
      phoneController.clear();
      return;
    }

    if (normalized.startsWith('+')) {
      final dialCode = _extractDialCode(normalized);
      if (dialCode != null) {
        selectedCountryCode.value = dialCode;
        phoneController.text = normalized.substring(dialCode.length);
        return;
      }
    }

    phoneController.text = normalized.replaceAll(RegExp(r'[^\d]'), '');
  }

  String? _extractDialCode(String phoneNumber) {
    String? matchedCode;
    for (final code in codes) {
      final dialCode = code['dial_code'];
      if (dialCode == null) continue;
      if (phoneNumber.startsWith(dialCode)) {
        if (matchedCode == null || dialCode.length > matchedCode.length) {
          matchedCode = dialCode;
        }
      }
    }

    if (matchedCode != null &&
        CountryCode.tryFromDialCode(matchedCode) != null) {
      return matchedCode;
    }

    if (CountryCode.tryFromDialCode(selectedCountryCode.value) != null) {
      return selectedCountryCode.value;
    }

    if (CountryCode.tryFromDialCode('+65') != null) {
      return '+65';
    }
    return null;
  }

  String _buildFullPhoneNumber(String phoneNumber) {
    final localNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (localNumber.isEmpty) {
      return '';
    }
    return '${selectedCountryCode.value}$localNumber';
  }

  Future<void> _loadToken() async {
    token.value = await SharedPreferencesHelper.getAccessToken() ?? '';
    print("[TOKEN] Loaded: ${token.value}");
  }

  @override
  void onClose() {
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
