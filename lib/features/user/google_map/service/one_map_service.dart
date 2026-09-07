import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OneMapResolvedAddress {
  final String postalCode;
  final String address;
  final String shortName;
  final double lat;
  final double lng;

  const OneMapResolvedAddress({
    required this.postalCode,
    required this.address,
    required this.shortName,
    required this.lat,
    required this.lng,
  });
}

class OneMapAddressSuggestion {
  final String label;
  final String building;
  final String road;
  final String postalCode;
  final double lat;
  final double lng;

  const OneMapAddressSuggestion({
    required this.label,
    required this.building,
    required this.road,
    required this.postalCode,
    required this.lat,
    required this.lng,
  });

  OneMapResolvedAddress toResolvedAddress() {
    return OneMapResolvedAddress(
      postalCode: postalCode,
      address: label,
      shortName: building.isNotEmpty ? building : road,
      lat: lat,
      lng: lng,
    );
  }
}

class OneMapSearchResult {
  final String searchValue;
  final String blockNo;
  final String roadName;
  final String building;
  final String address;
  final String postalCode;
  final String latitude;
  final String longitude;

  const OneMapSearchResult({
    required this.searchValue,
    required this.blockNo,
    required this.roadName,
    required this.building,
    required this.address,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
  });

  factory OneMapSearchResult.fromSearchJson(Map<String, dynamic> json) {
    return OneMapSearchResult(
      searchValue: (json['SEARCHVAL'] ?? '').toString(),
      blockNo: (json['BLK_NO'] ?? '').toString(),
      roadName: (json['ROAD_NAME'] ?? '').toString(),
      building: (json['BUILDING'] ?? '').toString(),
      address: (json['ADDRESS'] ?? '').toString(),
      postalCode: (json['POSTAL'] ?? '').toString(),
      latitude: (json['LATITUDE'] ?? '').toString(),
      longitude: (json['LONGITUDE'] ?? '').toString(),
    );
  }

  factory OneMapSearchResult.fromReverseJson(
    Map<String, dynamic> json, {
    required double lat,
    required double lng,
  }) {
    return OneMapSearchResult(
      searchValue: (json['BUILDINGNAME'] ?? json['ROAD'] ?? '').toString(),
      blockNo: (json['BLOCK'] ?? '').toString(),
      roadName: (json['ROAD'] ?? '').toString(),
      building: (json['BUILDINGNAME'] ?? '').toString(),
      address: (json['ADDRESS'] ?? '').toString(),
      postalCode: (json['POSTALCODE'] ?? '').toString(),
      latitude: lat.toString(),
      longitude: lng.toString(),
    );
  }
}

class OneMapService {
  static const String _authority = 'www.onemap.gov.sg';

  static Future<List<OneMapSearchResult>> searchAddresses(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return const [];

    final firstPage = await _fetchSearchPage(trimmed, 1);
    if (firstPage.results.isEmpty) return const [];

    if (firstPage.totalPages <= 1) {
      return firstPage.results;
    }

    final extraPages = firstPage.totalPages > 6 ? 6 : firstPage.totalPages;
    final futures = <Future<_OneMapSearchPage>>[];
    for (var page = 2; page <= extraPages; page++) {
      futures.add(_fetchSearchPage(trimmed, page));
    }

    final remainingPages = await Future.wait(futures);
    return [
      ...firstPage.results,
      for (final page in remainingPages) ...page.results,
    ];
  }

  static Future<List<OneMapAddressSuggestion>> searchSuggestions(
    String query,
  ) async {
    return toSuggestions(await searchAddresses(query));
  }

  static Future<OneMapResolvedAddress?> resolveQuery(String query) async {
    final suggestions = await searchSuggestions(query);
    if (suggestions.isEmpty) return null;
    return suggestions.first.toResolvedAddress();
  }

  static Future<OneMapResolvedAddress?> reverseGeocode(
    double lat,
    double lng,
  ) async {
    final uri = Uri.https(_authority, '/api/public/revgeocode', {
      'location': '$lat,$lng',
      'buffer': '40',
      'addressType': 'All',
      'otherFeatures': 'N',
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final info = body['GeocodeInfo'];
      if (info is! List || info.isEmpty) return null;

      final result = OneMapSearchResult.fromReverseJson(
        (info.first as Map).cast<String, dynamic>(),
        lat: lat,
        lng: lng,
      );

      return OneMapResolvedAddress(
        postalCode: result.postalCode,
        address: formatAddressLine(result),
        shortName: shortNameForResult(result),
        lat: lat,
        lng: lng,
      );
    } catch (e) {
      debugPrint('OneMap reverse geocode error: $e');
      return null;
    }
  }

  static List<OneMapAddressSuggestion> toSuggestions(
    List<OneMapSearchResult> results,
  ) {
    final seen = <String>{};
    final suggestions = <OneMapAddressSuggestion>[];

    for (final result in results) {
      if (result.postalCode.isEmpty ||
          result.postalCode.toUpperCase() == 'NIL' ||
          result.latitude.isEmpty ||
          result.longitude.isEmpty) {
        continue;
      }

      final lat = double.tryParse(result.latitude);
      final lng = double.tryParse(result.longitude);
      if (lat == null || lng == null) continue;

      final label = formatAddressLine(result);
      if (!seen.add(label)) continue;

      suggestions.add(
        OneMapAddressSuggestion(
          label: label,
          building: _normalizePart(result.building),
          road: _normalizePart(result.roadName),
          postalCode: result.postalCode,
          lat: lat,
          lng: lng,
        ),
      );
    }

    return suggestions;
  }

  static String formatAddress(OneMapSearchResult result) {
    final parts = <String>[];
    final building = _normalizePart(result.building);
    final block = _normalizePart(result.blockNo);
    final road = _normalizePart(result.roadName);

    if (building.isNotEmpty && building != block) {
      parts.add(building);
    }

    final street = [block, road].where((part) => part.isNotEmpty).join(' ');
    if (street.isNotEmpty) {
      parts.add(street);
    }

    if (result.postalCode.isNotEmpty &&
        result.postalCode.toUpperCase() != 'NIL') {
      parts.add('Singapore ${result.postalCode}');
    } else {
      parts.add('Singapore');
    }

    return parts.join('\n');
  }

  static String formatAddressLine(OneMapSearchResult result) {
    return formatAddress(result).replaceAll('\n', ', ');
  }

  static String shortNameForResult(OneMapSearchResult result) {
    final building = _normalizePart(result.building);
    if (building.isNotEmpty) return building;
    return _normalizePart(result.roadName);
  }

  static Future<_OneMapSearchPage> _fetchSearchPage(
    String query,
    int page,
  ) async {
    final uri = Uri.https(_authority, '/api/common/elastic/search', {
      'searchVal': query,
      'returnGeom': 'Y',
      'getAddrDetails': 'Y',
      'pageNum': '$page',
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        return const _OneMapSearchPage(results: [], totalPages: 1);
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final rawResults = body['results'];
      final items = rawResults is List
          ? rawResults
                .whereType<Map>()
                .map(
                  (item) => OneMapSearchResult.fromSearchJson(
                    item.cast<String, dynamic>(),
                  ),
                )
                .toList()
          : <OneMapSearchResult>[];

      return _OneMapSearchPage(
        results: items,
        totalPages: _parsePageCount(body['totalNumPages']),
      );
    } catch (e) {
      debugPrint('OneMap search error: $e');
      return const _OneMapSearchPage(results: [], totalPages: 1);
    }
  }

  static int _parsePageCount(dynamic value) {
    if (value is int && value > 0) return value;
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed == null || parsed <= 0) return 1;
    return parsed;
  }

  static String _normalizePart(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toUpperCase() == 'NIL') {
      return '';
    }
    return trimmed;
  }
}

class _OneMapSearchPage {
  final List<OneMapSearchResult> results;
  final int totalPages;

  const _OneMapSearchPage({required this.results, required this.totalPages});
}
