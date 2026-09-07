import 'dart:convert';
import 'dart:io';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class DisputeType {
  final String id;
  final String name;

  DisputeType({required this.id, required this.name});

  factory DisputeType.fromJson(Map<String, dynamic> json) {
    return DisputeType(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class CreateDisputeController extends GetxController {
  static const String createdByType = 'USER';

  final TextEditingController orderIdController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final RxList<DisputeType> disputeTypes = <DisputeType>[].obs;
  final RxnString selectedDisputeTypeId = RxnString();
  final RxList<String> evidenceUrls = <String>[].obs;
  final RxList<File> pickedImages = <File>[].obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isUploadingImages = false.obs;
  final RxBool isLoadingDisputeTypes = false.obs;
  final RxnString userId = RxnString();
  final RxBool isOrderIdLocked = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserId();
    _fetchDisputeTypes();
  }

  Future<void> _loadUserId() async {
    final storedUserId = await SharedPreferencesHelper.getUserId();
    userId.value = (storedUserId != null && storedUserId.isNotEmpty)
        ? storedUserId
        : await SharedPreferencesHelper.getOrExtractUserId();
  }

  void configureOrderId(String orderId, {bool lock = true}) {
    final trimmedOrderId = orderId.trim();
    if (trimmedOrderId.isEmpty) return;

    orderIdController.text = trimmedOrderId;
    isOrderIdLocked.value = lock;
  }

  Future<void> _fetchDisputeTypes() async {
    try {
      isLoadingDisputeTypes.value = true;
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        debugPrint('Access token not found for dispute types');
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiEndPoint.baseUrl}/admin/dispute-types/USER'),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> json =
            _tryDecodeMap(response.body) ?? <String, dynamic>{};
        final List<dynamic> data = json['data'] as List<dynamic>? ?? [];

        final fetchedTypes = data
            .map((item) => DisputeType.fromJson(item as Map<String, dynamic>))
            .toList();

        disputeTypes.assignAll(fetchedTypes);

        // Set first dispute type as default
        if (fetchedTypes.isNotEmpty) {
          selectedDisputeTypeId.value = fetchedTypes.first.id;
        }
      } else {
        debugPrint('Failed to fetch dispute types: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching dispute types: $e');
    } finally {
      isLoadingDisputeTypes.value = false;
    }
  }

  Future<void> pickAndUploadImages() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage(imageQuality: 80);
      if (files.isEmpty) return;

      isUploadingImages.value = true;
      var uploadedCount = 0;
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError('Access token not found');
        return;
      }

      for (final file in files) {
        final localFile = File(file.path);
        final uploadedUrl = await _uploadImage(localFile, token);
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          pickedImages.add(localFile);
          evidenceUrls.add(uploadedUrl);
          uploadedCount++;
        }
      }

      if (uploadedCount > 0) {
        EasyLoading.showSuccess('Proof uploaded successfully');
      }
    } catch (e) {
      debugPrint('Dispute image pick/upload error: $e');
      EasyLoading.showError('Failed to upload proof');
    } finally {
      isUploadingImages.value = false;
    }
  }

  Future<String?> _uploadImage(File file, String token) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndPoint.upload),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': '*/*',
      });
      request.files.add(await http.MultipartFile.fromPath('images', file.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> json = Map<String, dynamic>.from(
          jsonDecode(body) as Map,
        );
        final List<dynamic> data = json['data'] as List<dynamic>? ?? [];
        if (data.isNotEmpty) {
          return data.first.toString();
        }
      }

      final Map<String, dynamic>? json = _tryDecodeMap(body);
      EasyLoading.showError(
        json?['message']?.toString() ?? 'Failed to upload image',
      );
    } catch (e) {
      debugPrint('Dispute upload image error: $e');
      EasyLoading.showError('Failed to upload image');
    }
    return null;
  }

  void removeEvidence(int index) {
    if (index < 0 || index >= evidenceUrls.length) return;
    evidenceUrls.removeAt(index);
    if (index < pickedImages.length) {
      pickedImages.removeAt(index);
    }
  }

  Future<void> submitDispute() async {
    final orderIdText = orderIdController.text.trim();
    final description = descriptionController.text.trim();
    final createdById = userId.value?.trim();

    if (orderIdText.isEmpty) {
      EasyLoading.showError('Order ID is required');
      return;
    }

    final orderId = int.tryParse(orderIdText);
    if (orderId == null) {
      EasyLoading.showError('Enter a valid numeric Order ID');
      return;
    }

    if (description.isEmpty) {
      EasyLoading.showError('Description is required');
      return;
    }

    if (createdById == null || createdById.isEmpty) {
      await _loadUserId();
      if (userId.value == null || userId.value!.trim().isEmpty) {
        EasyLoading.showError('User ID not found');
        return;
      }
    }

    if (isUploadingImages.value) {
      EasyLoading.showInfo('Please wait for proof upload to finish');
      return;
    }

    try {
      isSubmitting.value = true;
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError('Access token not found');
        return;
      }

      if (selectedDisputeTypeId.value == null ||
          selectedDisputeTypeId.value!.isEmpty) {
        EasyLoading.showError('Please select a dispute type');
        return;
      }

      final response = await http.post(
        Uri.parse(ApiEndPoint.disputes),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'orderId': orderId,
          'disputeTypeId': selectedDisputeTypeId.value,
          'evidenceids': evidenceUrls.toList(),
          'description': description,
        }),
      );

      final Map<String, dynamic> body =
          _tryDecodeMap(response.body) ?? <String, dynamic>{};

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body['success'] == true) {
        EasyLoading.showSuccess(
          body['message']?.toString() ?? 'Dispute created successfully',
        );
        Get.back(result: true);
        return;
      }

      EasyLoading.showError(
        body['message']?.toString() ?? 'Failed to create dispute',
      );
    } catch (e) {
      debugPrint('Create dispute error: $e');
      EasyLoading.showError('Something went wrong');
    } finally {
      isSubmitting.value = false;
    }
  }

  Map<String, dynamic>? _tryDecodeMap(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  String getDisputeTypeName(String typeId) {
    try {
      final type = disputeTypes.firstWhere((t) => t.id == typeId);
      return type.name;
    } catch (_) {
      return typeId;
    }
  }

  @override
  void onClose() {
    orderIdController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
