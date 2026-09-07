import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PracticeMap extends StatefulWidget {
  const PracticeMap({super.key});

  @override
  State<PracticeMap> createState() => _PracticeMapState();
}

class _PracticeMapState extends State<PracticeMap> {
  // Define initial camera position (Example: Dhaka, Bangladesh)
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(23.8103, 90.4125), // Latitude, Longitude
    zoom: 14.0, // Zoom level
  );

  // Controller to manage map interactions
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    debugPrint('🗺️ [PracticeMap] Initializing PracticeMap widget...');
    debugPrint(
        '🗺️ [PracticeMap] API Key in .env: ${apiKey != null && apiKey.isNotEmpty ? "FOUND (${apiKey.substring(0, 6)}...)" : "NOT FOUND!"}');
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        // Set the initial camera coordinates
        initialCameraPosition: _initialCameraPosition,
        // Callback when the map is fully loaded
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          debugPrint(
              '🗺️ [PracticeMap] GoogleMap created successfully! Controller ID: ${controller.mapId}');
        },
        // Enable basic map UI controls
        zoomControlsEnabled: true,
        myLocationButtonEnabled: false,
      ),
    );
  }
}

// Alias for MapScreen if needed
typedef MapScreen = PracticeMap;
