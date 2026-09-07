import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/service/order_service.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:ZipBee/features/user/stacked/stacked_controller/stacked_controller.dart';
import 'package:ZipBee/features/user/stacked/widget/pic_date_time.dart';

class UpdateDetailsController extends GetxController {
  var isLoading = false.obs;
  var totalCost = 0.0.obs;

  /// Helper to parse and propagate total_cost from various response shapes
  void _applyServerTotal(Map<String, dynamic> body) {
    try {
      final data = body['data'] as Map<String, dynamic>? ?? {};

      double parsedCost = 0.0;
      double parsedFee = 0.0;

      // parse cost
      if (data.containsKey('total_cost')) {
        parsedCost =
            double.tryParse(data['total_cost']?.toString() ?? '') ?? 0.0;
      } else if (data.containsKey('order') &&
          data['order'] != null &&
          data['order']['total_cost'] != null) {
        parsedCost =
            double.tryParse(data['order']['total_cost']?.toString() ?? '') ??
            0.0;
      } else if (body.containsKey('total_cost')) {
        parsedCost =
            double.tryParse(body['total_cost']?.toString() ?? '') ?? 0.0;
      }

      // parse fee
      if (data.containsKey('total_fee')) {
        parsedFee = double.tryParse(data['total_fee']?.toString() ?? '') ?? 0.0;
      } else if (data.containsKey('order') &&
          data['order'] != null &&
          data['order']['total_fee'] != null) {
        parsedFee =
            double.tryParse(data['order']['total_fee']?.toString() ?? '') ??
            0.0;
      } else if (body.containsKey('total_fee')) {
        parsedFee = double.tryParse(body['total_fee']?.toString() ?? '') ?? 0.0;
      }

      debugPrint(
        'UpdateDetailsController parsed total_cost: $parsedCost total_fee: $parsedFee',
      );

      if (parsedFee > 0) {
        totalCost.value = parsedFee;
        try {
          final oc = Get.find<StackedOrderController>();
          oc.totalFee.value = parsedFee;
          // update totalAmount too if cost present
          if (parsedCost > 0) oc.totalAmount.value = parsedCost;
        } catch (_) {}
      } else if (parsedCost > 0) {
        totalCost.value = parsedCost;
        try {
          final oc = Get.find<StackedOrderController>();
          oc.totalAmount.value = parsedCost;
        } catch (_) {}
      }

      try {
        final oc = Get.find<StackedOrderController>();
        final orderLikeData = data['order'] is Map<String, dynamic>
            ? <String, dynamic>{
                ...(data['order'] as Map<String, dynamic>),
                if (data.containsKey('pricingSummary'))
                  'pricingSummary': data['pricingSummary'],
                if (data.containsKey('delivery_type'))
                  'delivery_type': data['delivery_type'],
                if (data.containsKey('delivery_type_id'))
                  'delivery_type_id': data['delivery_type_id'],
                if (data.containsKey('vehicle_type_id'))
                  'vehicle_type_id': data['vehicle_type_id'],
                if (data.containsKey('additional_cost'))
                  'additional_cost': data['additional_cost'],
              }
            : data;
        oc.syncOrderData(orderLikeData);
      } catch (_) {}

      // Sync collect_time and scheduled_time if present
      try {
        String? ct;
        String? st;
        if (data.containsKey('collect_time'))
          ct = data['collect_time']?.toString();
        else if (data.containsKey('order') &&
            data['order'] != null &&
            data['order']['collect_time'] != null)
          ct = data['order']['collect_time']?.toString();
        else if (body.containsKey('collect_time'))
          ct = body['collect_time']?.toString();

        if (data.containsKey('scheduled_time'))
          st = data['scheduled_time']?.toString();
        else if (data.containsKey('order') &&
            data['order'] != null &&
            data['order']['scheduled_time'] != null)
          st = data['order']['scheduled_time']?.toString();
        else if (body.containsKey('scheduled_time'))
          st = body['scheduled_time']?.toString();

        if (ct != null) {
          final loc = Get.find<StackedLocationController>();
          if (ct == 'ASAP') {
            loc.isNowSelected.value = true;
          } else if (ct == 'SCHEDULED') {
            loc.isNowSelected.value = false;
            if (st != null) {
              try {
                final sched = Get.find<StackedScheduleController>();
                final parsed = DateTime.parse(st);
                sched.setDateTime(parsed.toLocal());
                sched.setNow(false);
              } catch (_) {}
            }
          }
        }
      } catch (e) {
        debugPrint('Error syncing collect_time: $e');
      }
    } catch (e) {
      debugPrint('UpdateDetailsController._applyServerTotal parse error: $e');
    }
  }

  Future<bool> patchRouteType(int orderId, String routeType) async {
    isLoading.value = true;
    final res = await OrderService.updateOrderDetails(orderId, {
      'route_type': routeType,
    });
    isLoading.value = false;

    debugPrint('patchRouteType response: ${res['body']}');
    try {
      final bodyMap = res['body'] as Map<String, dynamic>? ?? {};
      if (bodyMap.containsKey('message'))
        debugPrint('patchRouteType message: ${bodyMap['message']}');
    } catch (_) {}

    final status = res['statusCode'] as int? ?? 500;
    if (status == 200) {
      _applyServerTotal(res['body'] as Map<String, dynamic>);

      // debug total_fee if present
      try {
        final b = res['body'] as Map<String, dynamic>;
        double fee = 0.0;
        if (b['data'] != null && b['data']['total_fee'] != null)
          fee = double.tryParse(b['data']['total_fee'].toString()) ?? 0.0;
        else if (b['data'] != null &&
            b['data']['order'] != null &&
            b['data']['order']['total_fee'] != null)
          fee =
              double.tryParse(b['data']['order']['total_fee'].toString()) ??
              0.0;
        else if (b['total_fee'] != null)
          fee = double.tryParse(b['total_fee'].toString()) ?? 0.0;
        debugPrint('patchRouteType total_fee: $fee');
      } catch (_) {}

      return true;
    }

    return false;
  }

  Future<bool> patchIsFixed(int orderId, bool isFixed) async {
    isLoading.value = true;
    final res = await OrderService.updateOrderDetails(orderId, {
      'isFixed': isFixed,
    });
    isLoading.value = false;

    debugPrint('patchIsFixed response: ${res['body']}');
    try {
      final bodyMap = res['body'] as Map<String, dynamic>? ?? {};
      if (bodyMap.containsKey('message'))
        debugPrint('patchIsFixed message: ${bodyMap['message']}');
    } catch (_) {}

    final status = res['statusCode'] as int? ?? 500;
    if (status == 200) {
      _applyServerTotal(res['body'] as Map<String, dynamic>);
      // debug total_fee
      try {
        final b = res['body'] as Map<String, dynamic>;
        double fee = 0.0;
        if (b['data'] != null && b['data']['total_fee'] != null)
          fee = double.tryParse(b['data']['total_fee'].toString()) ?? 0.0;
        else if (b['data'] != null &&
            b['data']['order'] != null &&
            b['data']['order']['total_fee'] != null)
          fee =
              double.tryParse(b['data']['order']['total_fee'].toString()) ??
              0.0;
        else if (b['total_fee'] != null)
          fee = double.tryParse(b['total_fee'].toString()) ?? 0.0;
        debugPrint('patchIsFixed total_fee: $fee');
      } catch (_) {}

      // update StackedOrderController.isFixed as well
      try {
        final oc = Get.find<StackedOrderController>();
        oc.isFixed.value = isFixed;
      } catch (_) {}
      return true;
    }

    return false;
  }

  Future<bool> patchCollectTime(
    int orderId,
    String collectTime, {
    String? scheduledTime,
  }) async {
    isLoading.value = true;

    final body = <String, dynamic>{'collect_time': collectTime};
    if (scheduledTime != null) body['scheduled_time'] = scheduledTime;

    final res = await OrderService.updateOrderDetails(orderId, body);

    isLoading.value = false;
    debugPrint('patchCollectTime response: ${res['body']}');
    try {
      final bodyMap = res['body'] as Map<String, dynamic>? ?? {};
      if (bodyMap.containsKey('message'))
        debugPrint('patchCollectTime message: ${bodyMap['message']}');
    } catch (_) {}

    final status = res['statusCode'] as int? ?? 500;
    if (status == 200) {
      _applyServerTotal(res['body'] as Map<String, dynamic>);

      // debug total_cost and total_fee if present
      try {
        final b = res['body'] as Map<String, dynamic>;
        double cost = 0.0;
        double fee = 0.0;
        if (b['data'] != null) {
          final d = b['data'];
          if (d['total_cost'] != null)
            cost = double.tryParse(d['total_cost'].toString()) ?? 0.0;
          else if (d['order'] != null && d['order']['total_cost'] != null)
            cost = double.tryParse(d['order']['total_cost'].toString()) ?? 0.0;
          if (d['total_fee'] != null)
            fee = double.tryParse(d['total_fee'].toString()) ?? 0.0;
          else if (d['order'] != null && d['order']['total_fee'] != null)
            fee = double.tryParse(d['order']['total_fee'].toString()) ?? 0.0;
        }
        if (b['total_cost'] != null)
          cost = double.tryParse(b['total_cost'].toString()) ?? cost;
        if (b['total_fee'] != null)
          fee = double.tryParse(b['total_fee'].toString()) ?? fee;
        debugPrint('patchCollectTime parsed total_cost: $cost total_fee: $fee');
      } catch (_) {}

      return true;
    }

    return false;
  }

  /// Update vehicle type for an existing order
  Future<bool> patchVehicleType(int orderId, int vehicleTypeId) async {
    isLoading.value = true;
    final res = await OrderService.updateOrderDetails(orderId, {
      'vehicle_type_id': vehicleTypeId,
    });
    isLoading.value = false;

    debugPrint('patchVehicleType response: ${res['body']}');
    try {
      final bodyMap = res['body'] as Map<String, dynamic>? ?? {};
      if (bodyMap.containsKey('message'))
        debugPrint('patchVehicleType message: ${bodyMap['message']}');
    } catch (_) {}

    final status = res['statusCode'] as int? ?? 500;
    if (status == 200) {
      _applyServerTotal(res['body'] as Map<String, dynamic>);

      // debug and return total_cost
      try {
        final b = res['body'] as Map<String, dynamic>;
        double cost = 0.0;
        if (b['data'] != null && b['data']['total_cost'] != null)
          cost = double.tryParse(b['data']['total_cost'].toString()) ?? 0.0;
        else if (b['data'] != null &&
            b['data']['order'] != null &&
            b['data']['order']['total_cost'] != null)
          cost =
              double.tryParse(b['data']['order']['total_cost'].toString()) ??
              0.0;
        else if (b['total_cost'] != null)
          cost = double.tryParse(b['total_cost'].toString()) ?? 0.0;

        debugPrint('patchVehicleType total_cost: $cost');
      } catch (_) {}

      return true;
    }

    return false;
  }

  // Update delivery type
  Future<bool> patchDeliveryType(int orderId, int deliveryTypeId) async {
    isLoading.value = true;

    final res = await OrderService.updateOrderDetails(orderId, {
      'delivery_type_id': deliveryTypeId,
    });

    isLoading.value = false;

    debugPrint('patchDeliveryType response: ${res['body']}');

    final status = res['statusCode'] as int? ?? 500;
    if (status == 200) {
      _applyServerTotal(res['body'] as Map<String, dynamic>);
      return true;
    } else {
      debugPrint('Failed to patch Delivery Type: ${res['body']}');
      final body = res['body'];
      final message =
          body is Map<String, dynamic>
              ? body['message']?.toString()
              : null;
      EasyLoading.showError(
        (message != null && message.isNotEmpty)
            ? message
            : 'Failed to update delivery type',
      );
      return false;
    }
  }
}
