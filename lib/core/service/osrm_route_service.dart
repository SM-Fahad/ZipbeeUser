import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class OsrmRouteService {
  /// Calculate distance in meters between two LatLng coordinates
  static double calculateDistanceMeters(LatLng p1, LatLng p2) {
    const earthRadius = 6371000.0; // meters
    final dLat = (p2.latitude - p1.latitude) * (math.pi / 180.0);
    final dLng = (p2.longitude - p1.longitude) * (math.pi / 180.0);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(p1.latitude * (math.pi / 180.0)) *
            math.cos(p2.latitude * (math.pi / 180.0)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  /// Fetches a real road polyline using OSRM (Open Source Routing Machine)
  /// given a list of waypoints.
  static Future<List<LatLng>> fetchRoadPolyline(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return waypoints;

    final coordinates =
        waypoints.map((p) => '${p.longitude},${p.latitude}').join(';');

    final endpoints = [
      'https://router.project-osrm.org/route/v1/driving/$coordinates?overview=full&geometries=geojson',
      'https://routing.openstreetmap.de/routed-car/route/v1/driving/$coordinates?overview=full&geometries=geojson',
    ];

    for (final ep in endpoints) {
      try {
        final url = Uri.parse(ep);
        debugPrint('🛣️ Fetching OSRM road polyline...');
        final response =
            await http.get(url).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['code'] == 'Ok' &&
              data['routes'] != null &&
              (data['routes'] as List).isNotEmpty) {
            final geometry = data['routes'][0]['geometry'];
            if (geometry != null && geometry['coordinates'] != null) {
              final coords = geometry['coordinates'] as List;
              final List<LatLng> points = [];
              for (final c in coords) {
                if (c is List && c.length >= 2) {
                  final lng = (c[0] as num).toDouble();
                  final lat = (c[1] as num).toDouble();
                  points.add(LatLng(lat, lng));
                }
              }
              if (points.length >= 2) {
                debugPrint(
                  '✅ OSRM road polyline loaded successfully with ${points.length} points',
                );
                return points;
              }
            }
          }
        }
      } catch (e) {
        debugPrint('❌ OSRM route fetch attempt failed: $e');
      }
    }
    return [];
  }
}
