import 'dart:convert';
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/service/app_http_client.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:ZipBee/features/user/home/model/order_response_model.dart';
import 'package:flutter/foundation.dart';

class OrderService {
  static String get createOrderUrl => ApiEndPoint.cancelOrder;
  static Future<OrderResponseModel?> createOrder({
    required String deliveryType,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      
      final response = await AppHttpClient.post(
        Uri.parse(createOrderUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "route_type": "ONE_WAY",
          "isFixed": false,
          "delivery_type": deliveryType.toUpperCase(),
          "collect_time": "ASAP"
        }),
      );
      debugPrint('Create order request body: ${jsonEncode({
        "route_type": "ONE_WAY",
        "isFixed": false,
        "delivery_type": deliveryType.toUpperCase(),
        "collect_time": "ASAP"
      })}');
      debugPrint('Create Order Body: ${response.body}');
      debugPrint('Create Order Status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return OrderResponseModel.fromJson(jsonDecode(response.body));
      } else {
        // API theke asha error message parse korar try kora
        final errorBody = jsonDecode(response.body);
        return OrderResponseModel(
          success: false, 
          message: errorBody['message'] ?? "Server Error ${response.statusCode}"
        );
      }
    } catch (e) {
      debugPrint('Error creating order: $e');
      return null;
    }
  }
}