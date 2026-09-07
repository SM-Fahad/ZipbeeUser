import 'dart:convert';
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../model/place_model.dart';

class SavedPlacesService {
  /// Fetch all saved destinations for the authenticated user.
  Future<List<PlaceModel>> getPlaces({int page = 1, int limit = 10}) async {
    final token = await SharedPreferencesHelper.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing access token');
    }

    final uri = Uri.parse('${ApiEndPoint.getDestination}?filter=saved&page=$page&limit=$limit');
    debugPrint('DEBUG SavedPlacesService.getPlaces -> GET $uri');

    final response = await http
        .get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 12));

    debugPrint('DEBUG SavedPlacesService.getPlaces -> status: ${response.statusCode}, body: ${response.body}',
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final dynamic dataNode = body['data'];

      // API sometimes wraps list differently; handle both.
      final List<dynamic> dataList = switch (dataNode) {
        List<dynamic> list => list,
        Map<String, dynamic> map when map['data'] is List<dynamic> =>
          List<dynamic>.from(map['data'] as List),
        _ => <dynamic>[],
      };

      return dataList
          .map((e) => PlaceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Failed to load places (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> addPlace({
    required String name,
    required String address,
    required String postalCode,
    required String shortName,
    required double latitude,
    required double longitude,
    String type = 'SENDER',
    bool isSaved = true,
  }) async {
    final token = await SharedPreferencesHelper.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing access token');
    }

    final uri = Uri.parse(ApiEndPoint.createDestination);
    final response = await http
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            "address": address,
            "postal_code": postalCode,
            "shortName": shortName,
            "contact_name": name,
            "is_saved": isSaved,
            "type": type,
            "latitude": latitude,
            "longitude": longitude,
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Add place failed (${response.statusCode})');
    }
  }

  Future<void> updatePlace({
    required int id,
    required String name,
    required String address,
    required String postalCode,
    required String shortName,
    required double latitude,
    required double longitude,
    String type = 'SENDER',
    bool isSaved = true,
  }) async {
    final token = await SharedPreferencesHelper.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing access token');
    }

    final uri = Uri.parse(ApiEndPoint.destinationById(id));
    final response = await http
        .patch(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            "address": address,
            "postal_code": postalCode,
            "shortName": shortName,
            "contact_name": name,
            "is_saved": isSaved,
            "type": type,
            "latitude": latitude,
            "longitude": longitude,
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Update place failed (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> deletePlace(int id) async {
    final token = await SharedPreferencesHelper.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing access token');
    }

    final uri = Uri.parse(ApiEndPoint.destinationById(id));
    final response = await http
        .delete(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Delete failed (${response.statusCode})');
    }
  }
}
