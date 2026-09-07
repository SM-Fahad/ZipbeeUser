// Unused file: lib/features/user/express_delivery_1/service/order_api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:http/http.dart' as http;

class OrderService {
  static String get createOrder => ApiEndPoint.orderCreate;

  static Future<http.Response> createOrderApi({
    required Map<String, dynamic> body,
    required String token,
  }) async {
    debugPrint('Express OrderService.request -> $createOrder body: $body');
    final resp = await http.post(
      Uri.parse(createOrder),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    debugPrint(
      'Express OrderService.response -> ${resp.statusCode} ${resp.body}',
    );
    return resp;
  }

  // Apply discount (promo code + redeem coins)
  static Future<http.Response> applyDiscountApi({
    required int orderId,
    required Map<String, dynamic> body,
    required String token,
  }) async {
    final String url = ApiEndPoint.applyDiscount.replaceFirst(
      '{orderId}',
      orderId.toString(),
    );
    debugPrint('Express OrderService.applyDiscount -> $url body: $body');
    final resp = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    debugPrint(
      'Express OrderService.applyDiscount response -> ${resp.statusCode} ${resp.body}',
    );
    return resp;
  }

  // Notify rider
  static Future<http.Response> notifyRiderApi({
    required int orderId,
    required Map<String, dynamic> body,
    required String token,
  }) async {
    final String url = ApiEndPoint.notifyRider.replaceFirst(
      '{orderId}',
      orderId.toString(),
    );
    debugPrint('Express OrderService.notifyRider -> $url body: $body');
    final resp = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    debugPrint(
      'Express OrderService.notifyRider response -> ${resp.statusCode} ${resp.body}',
    );
    return resp;
  }

  // Follow/favorite rider
  static Future<http.Response> followRiderApi({
    required int orderId,
    required String token,
  }) async {
    final String url = ApiEndPoint.followedRider.replaceFirst(
      '{orderId}',
      orderId.toString(),
    );
    debugPrint('Express OrderService.followRider -> $url');
    final resp = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    debugPrint(
      'Express OrderService.followRider response -> ${resp.statusCode} ${resp.body}',
    );
    return resp;
  }
}
