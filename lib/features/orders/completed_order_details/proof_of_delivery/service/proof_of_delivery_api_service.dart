import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:http/http.dart' as http;
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';

class ProofOfDeliveryApiService {

  Future<http.Response> getOrderDetails(int orderId) async {
    final String? token = await SharedPreferencesHelper.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Access token not found");
    }

    final url = Uri.parse("${ApiEndPoint.baseUrl}/order/$orderId");
    return await http.get(
      url,
      headers: {
        "Accept": "*/*",
        "Authorization": "Bearer $token",
      },
    );
  }
}
