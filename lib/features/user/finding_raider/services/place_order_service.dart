import 'dart:convert';
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/service/app_http_client.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';

class PlaceOrderService {
  static String _devicePlacedAtIso() {
    final now = DateTime.now();
    return DateTime.utc(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
    ).toIso8601String();
  }

  static Future<bool> placeOrder({
    required int orderId,
    required String paymentMethod,
    required String paymentMethodId,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) return false;

      final uri =
          Uri.parse('${ApiEndPoint.baseUrl}/order/$orderId/place');

      final body = {
        "paymentMethod": paymentMethod,
        "placedAt": _devicePlacedAtIso(),
        if (paymentMethodId.isNotEmpty) "paymentMethodId": paymentMethodId,
      };

      print('📡 PLACE ORDER BODY: $body');

      final response = await AppHttpClient.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('🔹 STATUS: ${response.statusCode}');
      print('📝 RESPONSE: ${response.body}');

      final decoded = jsonDecode(response.body);

      return decoded['success'] == true;
    } catch (e) {
      print(' PLACE ORDER ERROR: $e');
      return false;
    }
  }
}
