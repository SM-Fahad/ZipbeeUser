import 'dart:convert';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/service/order_confirmation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// ===============================
/// MODEL
/// ===============================
class AdditionalServiceModel {
  final int id;
  final String serviceName;
  final String value;
  final String desc;
  final bool isActive;

  AdditionalServiceModel({
    required this.id,
    required this.serviceName,
    required this.value,
    required this.desc,
    required this.isActive,
  });

  factory AdditionalServiceModel.fromJson(Map<String, dynamic> json) {
    return AdditionalServiceModel(
      id: json['id'],
      serviceName: json['service_name'],
      value: json['value'],
      desc: json['desc'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  double get price => double.tryParse(value) ?? 0.0;
}

/// ===============================
/// CONTROLLER
/// ===============================
class AdditionalServiceController extends GetxController {
  /// Services from API
  final services = <AdditionalServiceModel>[].obs;

  /// Selected service IDs for the current order
  final selectedServiceIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAdditionalServices();
  }

  /// ===============================
  /// FETCH SERVICES LIST
  /// ===============================
  Future<void> fetchAdditionalServices() async {
    try {
      EasyLoading.show(status: "Loading services...");

      final token = await SharedPreferencesHelper.getToken();

      final response = await http.get(
        Uri.parse(ApiEndPoint.additionalService),
        headers: {'Authorization': 'Bearer $token'},
      );

      final body = jsonDecode(response.body);

      debugPrint("Additional Services Fetch response: $body");

      if (response.statusCode == 200 && body['success'] == true) {
        services.value = (body['data'] as List)
            .map((e) => AdditionalServiceModel.fromJson(e))
            .where((e) => e.isActive)
            .toList();
      } else {
        debugPrint("Failed to fetch additional services: $body");
      }
    } catch (e) {
      debugPrint("fetchAdditionalServices error: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// ===============================
  /// TOGGLE SERVICE (ADD / DELETE)
  /// ===============================
  Future<void> toggleService(int serviceId, String orderId) async {
    if (selectedServiceIds.contains(serviceId)) {
      await _deleteService(serviceId, orderId);
    } else {
      await _addService(serviceId, orderId);
    }
  }

  /// Refresh order cost from API after service change
  Future<void> _refreshOrderCostAfterServiceChange() async {
    try {
      final oc = Get.find<StackedOrderController>();
      if (oc.lastOrderId == null) return;

      print('📞 [SERVICE CHANGE] Refreshing order cost from API...');
      final response = await OrderConfirmationService.getOrder(
        oc.lastOrderId ?? 0,
      );
      final data =
          (response['body'] as Map<String, dynamic>?)?['data']
              as Map<String, dynamic>?;

      if (data != null) {
        oc.syncOrderData(data);

        print(
          '✅ [SERVICE CHANGE] Updated order total_cost to: \$${oc.totalCost.value.toStringAsFixed(2)}',
        );
      }
    } catch (e) {
      print('❌ [SERVICE CHANGE] Error refreshing order cost: $e');
    }
  }

  /// ADD SERVICE
  Future<void> _addService(int serviceId, String orderId) async {
    try {
      // Toggle locally first → instant UI feedback
      selectedServiceIds.add(serviceId);
      debugPrint("Selecting serviceId=$serviceId for orderId=$orderId");

      EasyLoading.show(status: "Adding...");

      final token = await SharedPreferencesHelper.getToken();

      // Construct endpoint URL
      final url = ApiEndPoint.additionOrder
          .replaceAll("{order_id}", orderId)
          .replaceAll("{serviceId}", serviceId.toString());

      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      final body = jsonDecode(response.body);
      debugPrint("Add API response: $body");

      // If API fails, revert local selection
      // Check if status code is in success range (200-299) and success field is true
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      if (!isSuccess || body['success'] != true) {
        selectedServiceIds.remove(serviceId);
        debugPrint(
          "Failed to add service $serviceId (Status: ${response.statusCode}, Success: ${body['success']})",
        );
      } else {
        debugPrint("✅ Successfully added service $serviceId");
        // Refresh order cost immediately after adding service
        await _refreshOrderCostAfterServiceChange();
      }
    } catch (e) {
      debugPrint("❌ Error adding service $serviceId: $e");
      selectedServiceIds.remove(serviceId);
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// DELETE SERVICE
  Future<void> _deleteService(int serviceId, String orderId) async {
    try {
      // Toggle locally first → instant UI feedback
      selectedServiceIds.remove(serviceId);
      debugPrint("Unselecting serviceId=$serviceId for orderId=$orderId");

      EasyLoading.show(status: "Removing...");

      final token = await SharedPreferencesHelper.getToken();

      // Construct endpoint URL
      final url = ApiEndPoint.additionOrderD
          .replaceAll("{order_id}", orderId)
          .replaceAll("{serviceId}", serviceId.toString());

      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      final body = jsonDecode(response.body);
      debugPrint("Delete API response: $body");

      // If API fails, revert local unselection
      // Check if status code is in success range (200-299) and success field is true
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      if (!isSuccess || body['success'] != true) {
        selectedServiceIds.add(serviceId);
        debugPrint(
          "Failed to delete service $serviceId (Status: ${response.statusCode}, Success: ${body['success']})",
        );
      } else {
        debugPrint("✅ Successfully deleted service $serviceId");
        // Refresh order cost immediately after removing service
        await _refreshOrderCostAfterServiceChange();
      }
    } catch (e) {
      debugPrint("❌ Error deleting service $serviceId: $e");
      selectedServiceIds.add(serviceId);
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// ===============================
  /// HELPERS
  /// ===============================
  void syncSelectedServicesFromOrder(Map<String, dynamic> orderData) {
    final rawAdditionalServices = orderData['additional_services'];
    if (rawAdditionalServices is! List) {
      selectedServiceIds.clear();
      return;
    }

    final ids = rawAdditionalServices
        .map((item) {
          if (item is! Map<String, dynamic>) return null;
          final id = item['id'];
          return id is int ? id : int.tryParse(id?.toString() ?? '');
        })
        .whereType<int>()
        .toSet();

    selectedServiceIds
      ..clear()
      ..addAll(ids);
  }

  bool isServiceSelected(int id) => selectedServiceIds.contains(id);

  double getSelectedServicesTotal() {
    return services
        .where((s) => selectedServiceIds.contains(s.id))
        .fold(0.0, (sum, s) => sum + s.price);
  }
}
