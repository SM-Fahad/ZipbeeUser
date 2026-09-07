import 'dart:async';

// ignore_for_file: deprecated_member_use

import 'package:ZipBee/features/user/finding_raider/controller/rider_controller.dart';
import 'package:ZipBee/features/user/google_map/service/one_map_service.dart';
import 'package:ZipBee/features/user/google_map/service/service_zone_service.dart';
import 'package:ZipBee/features/user/google_map/widget/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ZipBee/core/utils/custom_map_marker_helper.dart';
import 'package:ZipBee/core/service/osrm_route_service.dart';
import 'package:location/location.dart';

enum GoogleMapWidgetMode { display, addressPicker }

class GoogleMapWidget extends StatelessWidget {
  const GoogleMapWidget({
    super.key,
    this.mode = GoogleMapWidgetMode.display,
    this.initialQuery,
    this.onLocationConfirmed,
  });

  final GoogleMapWidgetMode mode;
  final String? initialQuery;
  final ValueChanged<OneMapResolvedAddress>? onLocationConfirmed;

  @override
  Widget build(BuildContext context) {
    final enablePickupSync = mode == GoogleMapWidgetMode.display;

    return FutureBuilder<MapData>(
      future: initializeMap(enablePickupSync: enablePickupSync),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(color: Colors.amber));
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: CircularProgressIndicator(color: Colors.amber));
        }

        return GoogleMapContent(
          key: ValueKey('map_content_${mode.name}_${snapshot.data?.riderController?.orderId.value ?? 0}'),
          data: snapshot.data!,
          mode: mode,
          initialQuery: initialQuery,
          onLocationConfirmed: onLocationConfirmed,
        );
      },
    );
  }

  static Future<void> warmUp({bool enablePickupSync = false}) async {
    await initializeMap(enablePickupSync: enablePickupSync);
  }

  static Future<MapData> initializeMap({required bool enablePickupSync}) async {
    final location = Location();
    final riderController = enablePickupSync
        ? (Get.isRegistered<RiderController>()
              ? Get.find<RiderController>()
              : Get.put(RiderController()))
        : null;

    final zoneCenter = await ServiceZoneService.getFirstZoneCenter();
    final initialFocus = zoneCenter ?? const LatLng(1.3521, 103.8198);

    LatLng? currentPosition;
    try {
      final serviceEnabled = await location.serviceEnabled();
      final permission = await location.hasPermission();
      if (serviceEnabled && permission != PermissionStatus.denied) {
        final locData = await location.getLocation();
        if (locData.latitude != null && locData.longitude != null) {
          currentPosition = LatLng(locData.latitude!, locData.longitude!);
        }
      }
    } catch (_) {}

    return MapData(
      riderController: riderController,
      initialFocus: initialFocus,
      currentPosition: currentPosition,
      location: location,
    );
  }
}

class MapData {
  final RiderController? riderController;
  final LatLng initialFocus;
  final LatLng? currentPosition;
  final Location location;

  const MapData({
    required this.riderController,
    required this.initialFocus,
    this.currentPosition,
    required this.location,
  });
}

class GoogleMapContentController extends GetxController {
  final MapData data;
  final GoogleMapWidgetMode mode;
  final String? initialQuery;

  GoogleMapContentController({
    required this.data,
    required this.mode,
    this.initialQuery,
  });

  String? lastInitialQuery;

  final Completer<GoogleMapController> mapController = Completer();
  late final TextEditingController searchController;

  final RxList<OneMapAddressSuggestion> suggestions = <OneMapAddressSuggestion>[].obs;

  StreamSubscription<LocationData>? locSub;
  Timer? debounce;
  Worker? routeWorker;
  Worker? riderLocWorker;
  Worker? routeTypeWorker;
  final RxList<LatLng> driverToPickupPolylinePoints = <LatLng>[].obs;
  int driverPolylineRequestId = 0;
  DateTime? _lastDriverPolylineFetchTime;
  LatLng? _lastDriverPolylineLoc;

  late final Rx<LatLng> currentPosition;
  final RxList<LatLng> routePolylinePoints = <LatLng>[].obs;
  final Rxn<Marker> selectedMarker = Rxn<Marker>();
  final RxSet<Marker> displayMarkers = <Marker>{}.obs;
  final Rxn<OneMapResolvedAddress> pendingSelection = Rxn<OneMapResolvedAddress>();

  final RxBool hasDeviceLocation = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool showSuggestions = false.obs;
  final RxBool didRunInitialQuery = false.obs;
  bool isMutatingSearchField = false;
  bool hasUserMovedMap = false;
  bool isProgrammaticCameraMove = false;
  int routeRequestId = 0;
  String? _loadedRouteSignature;
  bool _hasFittedCameraToRoute = false;

  final RxnString helperMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    lastInitialQuery = initialQuery;
    searchController = TextEditingController(text: initialQuery ?? '');
    currentPosition = (data.currentPosition ?? data.initialFocus).obs;
    hasDeviceLocation.value = data.currentPosition != null;

    // Warm up markers
    _updateMarkers();

    listenLocation();
    _listenRouteStopsTrigger();

    ever(currentPosition, (_) => _updateMarkers());
    ever(hasDeviceLocation, (_) => _updateMarkers());
    ever(selectedMarker, (_) => _updateMarkers());

    if (data.riderController != null) {
      ever(data.riderController!.riderLocation, (_) => _updateMarkers());
      ever(data.riderController!.isRiderActive, (active) {
        if (active == false) {
          driverToPickupPolylinePoints.clear();
        }
        _updateMarkers();
      });
      ever(data.riderController!.routeStops, (_) => _updateMarkers());
      routeTypeWorker = ever(data.riderController!.routeType, (_) {
        _loadedRouteSignature = null;
        _listenRouteStopsTrigger();
        _updateMarkers();
      });
    }

    _updateMarkers();

    if (mode == GoogleMapWidgetMode.display && data.riderController != null) {
      riderLocWorker = ever<LatLng?>(
        data.riderController!.riderLocation,
        (loc) async {
          if (loc == null) {
            driverToPickupPolylinePoints.clear();
            return;
          }
          final stops = data.riderController!.routeStops;
          if (stops.isNotEmpty) {
            final pickup = stops.firstWhere(
              (s) => s.stopType == 'PICKUP',
              orElse: () => stops.first,
            );
            await _throttledRefreshDriverToPickupPolyline(
              loc,
              LatLng(pickup.latitude, pickup.longitude),
            );
          }
        },
      );

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final loc = data.riderController!.riderLocation.value;
        final stops = data.riderController!.routeStops;
        if (loc != null && stops.isNotEmpty) {
          final pickup = stops.firstWhere(
            (s) => s.stopType == 'PICKUP',
            orElse: () => stops.first,
          );
          await _throttledRefreshDriverToPickupPolyline(
            loc,
            LatLng(pickup.latitude, pickup.longitude),
          );
        }
      });
    }
  }

  void updateInitialQuery(String newQuery) {
    lastInitialQuery = newQuery;
    if (newQuery.isNotEmpty && searchController.text.trim().isEmpty) {
      _setSearchField(newQuery);
    }
  }

  @override
  void onClose() {
    debounce?.cancel();
    locSub?.cancel();
    routeWorker?.dispose();
    riderLocWorker?.dispose();
    routeTypeWorker?.dispose();
    super.onClose();
  }

  List<OrderStopMapPoint> _getOrderedStops(
    List<OrderStopMapPoint> stops, {
    bool isRoundTrip = false,
  }) {
    final pickups = stops.where((stop) => stop.stopType == 'PICKUP').toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    final drops = stops.where((stop) => stop.stopType != 'PICKUP').toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));

    if (isRoundTrip && pickups.isNotEmpty) {
      return [...pickups, ...drops, ...pickups];
    }
    return [...pickups, ...drops];
  }

  Future<void> _updateMarkers() async {
    final nextMarkers = <Marker>{};

    final riderController = data.riderController;
    final isDisplayWithStops = mode == GoogleMapWidgetMode.display &&
        riderController != null &&
        riderController.routeStops.isNotEmpty;

    if (hasDeviceLocation.value && !isDisplayWithStops) {
      final deviceLocationIcon =
          await CustomMapMarkerHelper.getDeviceLocationMarker();
      nextMarkers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: currentPosition.value,
          anchor: CustomMapMarkerHelper.defaultAnchor,
          icon: deviceLocationIcon,
        ),
      );
    }

    if (selectedMarker.value != null) {
      nextMarkers.add(selectedMarker.value!);
    }

    if (mode == GoogleMapWidgetMode.display && riderController != null) {
      final isRound =
          riderController.routeType.value.toUpperCase() == 'ROUND';
      final stops = riderController.routeStops;

      if (stops.isNotEmpty) {
        final pickups = stops.where((s) => s.stopType == 'PICKUP').toList()
          ..sort((a, b) => a.sequence.compareTo(b.sequence));
        final drops = stops.where((s) => s.stopType != 'PICKUP').toList()
          ..sort((a, b) => a.sequence.compareTo(b.sequence));

        final showDropNumbers = drops.length > 1;

        // 1. Pickups (Collected from / Sender)
        for (var i = 0; i < pickups.length; i++) {
          final stop = pickups[i];
          final icon = await CustomMapMarkerHelper.getPickupMarker();
          final title = stop.name.trim().isNotEmpty
              ? 'Collected from (Sender: ${stop.name.trim()})'
              : 'Collected from (Sender)';

          nextMarkers.add(
            Marker(
              markerId: MarkerId('order_stop_pickup_${stop.sequence}_$i'),
              position: LatLng(stop.latitude, stop.longitude),
              anchor: CustomMapMarkerHelper.defaultAnchor,
              infoWindow: InfoWindow(title: title, snippet: stop.address),
              icon: icon,
            ),
          );
        }

        // 2. Drops (Deliver to / Recipient)
        for (var i = 0; i < drops.length; i++) {
          final stop = drops[i];
          final dropNumber = i + 1;
          final BitmapDescriptor icon;
          if (showDropNumbers) {
            icon = await CustomMapMarkerHelper.getNumberedDropMarker(
              number: dropNumber,
            );
          } else {
            icon = await CustomMapMarkerHelper.getDropMarker();
          }

          final title = showDropNumbers
              ? (stop.name.trim().isNotEmpty
                  ? 'Deliver to (Drop $dropNumber: ${stop.name.trim()})'
                  : 'Deliver to (Drop $dropNumber)')
              : (stop.name.trim().isNotEmpty
                  ? 'Deliver to (Recipient: ${stop.name.trim()})'
                  : 'Deliver to (Recipient)');

          nextMarkers.add(
            Marker(
              markerId: MarkerId('order_stop_drop_${stop.sequence}_$i'),
              position: LatLng(stop.latitude, stop.longitude),
              anchor: CustomMapMarkerHelper.defaultAnchor,
              infoWindow: InfoWindow(title: title, snippet: stop.address),
              icon: icon,
            ),
          );
        }

        // 3. Return (if Round Trip)
        if (isRound && pickups.isNotEmpty) {
          for (var i = 0; i < pickups.length; i++) {
            final stop = pickups[i];
            final icon = await CustomMapMarkerHelper.getPickupMarker();
            final title = stop.name.trim().isNotEmpty
                ? 'Return (Sender: ${stop.name.trim()})'
                : 'Return (Sender)';

            nextMarkers.add(
              Marker(
                markerId: MarkerId('order_stop_return_${stop.sequence}_$i'),
                position: LatLng(stop.latitude, stop.longitude),
                anchor: CustomMapMarkerHelper.defaultAnchor,
                infoWindow: InfoWindow(title: title, snippet: stop.address),
                icon: icon,
              ),
            );
          }
        }
      }

      if (riderController.riderLocation.value != null &&
          riderController.isRiderActive.value) {
        final riderIcon = await CustomMapMarkerHelper.getRiderMarker();
        nextMarkers.add(
          Marker(
            markerId: const MarkerId('driver'),
            position: riderController.riderLocation.value!,
            anchor: CustomMapMarkerHelper.defaultAnchor,
            icon: riderIcon,
            infoWindow: const InfoWindow(
              title: 'Rider',
            ),
          ),
        );
      }
    }

    // Compare with displayMarkers to avoid unnecessary state changes
    if (displayMarkers.length == nextMarkers.length) {
      bool identical = true;
      for (final m in nextMarkers) {
        Marker? existing;
        for (final e in displayMarkers) {
          if (e.markerId == m.markerId) {
            existing = e;
            break;
          }
        }
        if (existing == null ||
            existing.position != m.position ||
            existing.icon != m.icon) {
          identical = false;
          break;
        }
      }
      if (identical) return;
    }

    displayMarkers.assignAll(nextMarkers);
  }

  Future<void> listenLocation() async {
    // Only track continuous GPS in address picker mode.
    // In display mode with fixed order stops, do not poll GPS to avoid rebuilding map continuously.
    if (mode == GoogleMapWidgetMode.display) {
      return;
    }

    if (!await data.location.serviceEnabled()) {
      final enabled = await data.location.requestService();
      if (!enabled) return;
    }

    final permission = await data.location.hasPermission();
    if (permission == PermissionStatus.denied) {
      final requested = await data.location.requestPermission();
      if (requested != PermissionStatus.granted &&
          requested != PermissionStatus.grantedLimited) {
        return;
      }
    }

    locSub = data.location.onLocationChanged.listen((loc) {
      if (loc.latitude == null || loc.longitude == null) return;

      hasDeviceLocation.value = true;
      currentPosition.value = LatLng(loc.latitude!, loc.longitude!);
    });
  }

  Future<void> moveCamera(LatLng position, {double zoom = 16}) async {
    try {
      final controller = await mapController.future;
      isProgrammaticCameraMove = true;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: zoom),
        ),
      );
    } catch (e) {
      debugPrint('⚠️ moveCamera error: $e');
    }
  }

  Future<void> _changeZoom(double delta) async {
    try {
      final controller = await mapController.future;
      isProgrammaticCameraMove = true;
      await controller.animateCamera(CameraUpdate.zoomBy(delta));
    } catch (e) {
      debugPrint('⚠️ _changeZoom error: $e');
    }
  }

  void dropPin(LatLng position) {
    selectedMarker.value = Marker(
      markerId: const MarkerId('selected'),
      position: position,
    );
  }

  void _listenRouteStopsTrigger() {
    final List<OrderStopMapPoint> stops =
        data.riderController?.routeStops.toList() ?? <OrderStopMapPoint>[];
    if (stops.isEmpty) {
      routePolylinePoints.clear();
      _loadedRouteSignature = null;
      _hasFittedCameraToRoute = false;
      return;
    }
    final isRound =
        data.riderController?.routeType.value.toUpperCase() == 'ROUND';
    final orderedStops = _getOrderedStops(stops, isRoundTrip: isRound);
    final String signature =
        '${isRound ? "ROUND" : "ONE_WAY"}_${orderedStops.map((s) => '${s.stopType}_${s.latitude}_${s.longitude}_${s.sequence}').join('|')}';

    if (signature == _loadedRouteSignature && routePolylinePoints.isNotEmpty) {
      return;
    }

    _refreshRoutePolyline(orderedStops, signature);
    if (!hasUserMovedMap) {
      _hasFittedCameraToRoute = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitCameraToRoute(orderedStops);
      });
    }
  }



  Future<void> _throttledRefreshDriverToPickupPolyline(
    LatLng driverLoc,
    LatLng pickupLoc,
  ) async {
    final now = DateTime.now();

    if (driverToPickupPolylinePoints.isNotEmpty &&
        _lastDriverPolylineFetchTime != null &&
        _lastDriverPolylineLoc != null) {
      final elapsedSeconds = now.difference(_lastDriverPolylineFetchTime!).inSeconds;
      final distanceMovedMeters = OsrmRouteService.calculateDistanceMeters(
        _lastDriverPolylineLoc!,
        driverLoc,
      );

      // Skip API if rider moved < 25 meters (even after 60s, if stationary don't hit API)
      if (distanceMovedMeters < 25.0) {
        return;
      }

      // Throttle to at most once every 15 seconds
      if (elapsedSeconds < 15) {
        return;
      }
    }

    _lastDriverPolylineFetchTime = now;
    _lastDriverPolylineLoc = driverLoc;
    await _refreshDriverToPickupPolyline(driverLoc, pickupLoc);
  }

  Future<void> _refreshDriverToPickupPolyline(
    LatLng driverLoc,
    LatLng pickupLoc,
  ) async {
    final requestId = ++driverPolylineRequestId;
    try {
      final points = await _fetchRoadRoutePointsForTwoPoints(driverLoc, pickupLoc);
      if (requestId != driverPolylineRequestId) return;
      driverToPickupPolylinePoints.assignAll(points);
    } catch (error) {
      debugPrint('❌ Failed to load driver to pickup road route polyline: $error');
      if (requestId != driverPolylineRequestId) return;
      driverToPickupPolylinePoints.assignAll([driverLoc, pickupLoc]);
    }
  }

  Future<List<LatLng>> _fetchRoadRoutePointsForTwoPoints(
    LatLng origin,
    LatLng destination,
  ) async {
    final osrmPoints = await OsrmRouteService.fetchRoadPolyline([
      origin,
      destination,
    ]);
    if (osrmPoints.length > 2) {
      return osrmPoints;
    }

    try {
      final legacyClient = PolylinePoints.legacy(GoogleMapAPIKey);
      final legacyResult = await legacyClient.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      final legacyPoints = legacyResult.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      if (legacyPoints.length > 2) {
        return legacyPoints;
      }
    } catch (_) {}

    if (osrmPoints.length >= 2) {
      return osrmPoints;
    }

    return [origin, destination];
  }

  Future<void> _refreshRoutePolyline(
    List<OrderStopMapPoint> orderedStops,
    String signature,
  ) async {
    if (orderedStops.length < 2) {
      routePolylinePoints.clear();
      _loadedRouteSignature = null;
      return;
    }

    if (signature == _loadedRouteSignature && routePolylinePoints.isNotEmpty) {
      debugPrint('⏩ Polyline already loaded for signature. Skipping API call.');
      return;
    }

    final requestId = ++routeRequestId;

    try {
      final points = await _fetchRoadRoutePoints(orderedStops);

      if (requestId != routeRequestId) return;

      _loadedRouteSignature = signature;
      routePolylinePoints.assignAll(points);
    } catch (error) {
      debugPrint('❌ Failed to load road route polyline: $error');
      if (requestId != routeRequestId) return;
      _loadedRouteSignature = signature;
      final fallbackPoints = orderedStops
          .map((s) => LatLng(s.latitude, s.longitude))
          .toList();
      routePolylinePoints.assignAll(fallbackPoints);
    }
  }

  Future<List<LatLng>> _fetchRoadRoutePoints(
    List<OrderStopMapPoint> orderedStops,
  ) async {
    final waypoints =
        orderedStops.map((s) => LatLng(s.latitude, s.longitude)).toList();

    // 1️⃣ Try OSRM road routing first (fast & road-following)
    final osrmPoints = await OsrmRouteService.fetchRoadPolyline(waypoints);
    if (osrmPoints.length > 2) {
      return osrmPoints;
    }

    // 2️⃣ Fallback to Google Directions API
    try {
      final legacyClient = PolylinePoints.legacy(GoogleMapAPIKey);
      final legacyResult = await legacyClient.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(waypoints.first.latitude, waypoints.first.longitude),
          destination: PointLatLng(waypoints.last.latitude, waypoints.last.longitude),
          mode: TravelMode.driving,
          wayPoints: waypoints.length > 2
              ? waypoints
                  .sublist(1, waypoints.length - 1)
                  .map(
                    (p) => PolylineWayPoint(
                      location: '${p.latitude},${p.longitude}',
                    ),
                  )
                  .toList()
              : [],
        ),
      );

      final legacyPoints = legacyResult.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      if (legacyPoints.length > 2) {
        return legacyPoints;
      }
    } catch (e) {
      debugPrint('⚠️ Directions API failed in GoogleMapWidget: $e');
    }

    if (osrmPoints.length >= 2) {
      return osrmPoints;
    }

    return waypoints;
  }

  Future<void> _fitCameraToRoute(List<OrderStopMapPoint> stops) async {
    if (stops.isEmpty) return;

    try {
      if (stops.length == 1) {
        await moveCamera(
          LatLng(stops.first.latitude, stops.first.longitude),
          zoom: 14,
        );
        return;
      }

      double minLat = stops.first.latitude;
      double maxLat = stops.first.latitude;
      double minLng = stops.first.longitude;
      double maxLng = stops.first.longitude;

      for (final stop in stops.skip(1)) {
        if (stop.latitude < minLat) minLat = stop.latitude;
        if (stop.latitude > maxLat) maxLat = stop.latitude;
        if (stop.longitude < minLng) minLng = stop.longitude;
        if (stop.longitude > maxLng) maxLng = stop.longitude;
      }

      final controller = await mapController.future;
      isProgrammaticCameraMove = true;
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          60,
        ),
      );
    } catch (e) {
      debugPrint('⚠️ _fitCameraToRoute error: $e');
    }
  }

  Set<Marker> _buildDisplayMarkers() {
    return displayMarkers.toSet();
  }

  Set<Polyline> _buildDisplayPolylines() {
    final polylines = <Polyline>{};
    final riderController = data.riderController;
    if (mode != GoogleMapWidgetMode.display || riderController == null) {
      return polylines;
    }

    if (routePolylinePoints.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('order_route'),
          color: const Color(0xFF1565C0), // Blue
          width: 5,
          geodesic: false,
          points: routePolylinePoints.toList(),
        ),
      );
    }

    if (riderController.riderLocation.value != null &&
        riderController.isRiderActive.value &&
        driverToPickupPolylinePoints.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('driver_to_pickup'),
          color: const Color(0xFFFFCC00), // ZipBee yellow
          width: 5,
          geodesic: false,
          points: driverToPickupPolylinePoints.toList(),
        ),
      );
    }

    return polylines;
  }

  Future<void> handleMapTap(LatLng latLng) async {
    dropPin(latLng);

    if (mode == GoogleMapWidgetMode.display) {
      data.riderController?.setPickupLocation(
        latLng.latitude,
        latLng.longitude,
      );
      return;
    }

    await _resolveFromTap(latLng);
  }

  Future<void> _resolveFromTap(LatLng latLng) async {
    isSearching.value = true;
    helperMessage.value = null;
    showSuggestions.value = false;

    final resolved = await OneMapService.reverseGeocode(
      latLng.latitude,
      latLng.longitude,
    );

    isSearching.value = false;
    if (resolved == null) {
      pendingSelection.value = null;
      helperMessage.value = "Couldn't detect address here. Try clicking nearby.";
      return;
    }

    pendingSelection.value = resolved;
    helperMessage.value = null;
    _setSearchField(
      resolved.postalCode.isNotEmpty ? resolved.postalCode : resolved.address,
    );

    await moveCamera(latLng);
  }

  Future<void> _runSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return;

    isSearching.value = true;
    helperMessage.value = null;
    showSuggestions.value = false;
    suggestions.clear();

    final currentQuery = trimmed;
    final results = await OneMapService.searchSuggestions(trimmed);

    if (searchController.text.trim() != currentQuery) {
      return;
    }

    if (results.isEmpty) {
      isSearching.value = false;
      pendingSelection.value = null;
      helperMessage.value =
          'No location found. Try a building name, road, or postal code.';
      return;
    }

    isSearching.value = false;
    helperMessage.value = null;
    suggestions.assignAll(results);
    showSuggestions.value = true;

    await _selectSuggestion(results.first, updateSearchField: false);
  }

  Future<void> _selectSuggestion(
    OneMapAddressSuggestion suggestion, {
    bool updateSearchField = true,
  }) async {
    final resolved = suggestion.toResolvedAddress();
    final target = LatLng(suggestion.lat, suggestion.lng);

    pendingSelection.value = resolved;
    helperMessage.value = null;
    if (updateSearchField) {
      _setSearchField(suggestion.postalCode);
    }
    selectedMarker.value = Marker(
      markerId: const MarkerId('selected'),
      position: target,
    );

    await moveCamera(target, zoom: 17);
  }

  String _displaySuggestionText(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;

    final hasLetters = RegExp(r'[A-Za-z]').hasMatch(trimmed);
    final isAllUppercase = hasLetters && trimmed == trimmed.toUpperCase();
    if (!isAllUppercase) return trimmed;

    return trimmed.split(RegExp(r'(\s+)')).map((part) {
      if (part.trim().isEmpty) return part;

      return part
          .split('-')
          .map((segment) {
            if (segment.isEmpty) return segment;
            final lower = segment.toLowerCase();
            return '${lower[0].toUpperCase()}${lower.substring(1)}';
          })
          .join('-');
    }).join();
  }

  void _setSearchField(String value) {
    isMutatingSearchField = true;
    searchController
      ..text = value
      ..selection = TextSelection.collapsed(offset: value.length);
    isMutatingSearchField = false;
  }

  void _handleSearchInputChanged(String value) {
    if (isMutatingSearchField) return;

    debounce?.cancel();
    if (value.trim().length < 3) {
      showSuggestions.value = false;
      suggestions.clear();
      helperMessage.value = null;
      return;
    }

    debounce = Timer(
      const Duration(milliseconds: 700),
      () => _runSearch(value),
    );
  }
}

class GoogleMapContent extends StatefulWidget {
  const GoogleMapContent({
    super.key,
    required this.data,
    required this.mode,
    this.initialQuery,
    this.onLocationConfirmed,
  });

  final MapData data;
  final GoogleMapWidgetMode mode;
  final String? initialQuery;
  final ValueChanged<OneMapResolvedAddress>? onLocationConfirmed;

  @override
  State<GoogleMapContent> createState() => _GoogleMapContentState();
}

class _GoogleMapContentState extends State<GoogleMapContent> {
  late final GoogleMapContentController controller;

  @override
  void initState() {
    super.initState();
    controller = GoogleMapContentController(
      data: widget.data,
      mode: widget.mode,
      initialQuery: widget.initialQuery,
    );
    controller.onInit();

    if (widget.mode == GoogleMapWidgetMode.addressPicker &&
        (widget.initialQuery?.trim().length ?? 0) >= 3) {
      controller.didRunInitialQuery.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller._runSearch(widget.initialQuery!.trim());
      });
    }
  }

  @override
  void didUpdateWidget(covariant GoogleMapContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != null &&
        widget.initialQuery != controller.lastInitialQuery) {
      controller.updateInitialQuery(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    controller.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(
          () => GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: widget.data.currentPosition ?? widget.data.initialFocus,
              zoom: widget.mode == GoogleMapWidgetMode.addressPicker ? 13 : 11,
            ),
            onCameraMoveStarted: () {
              if (!controller.isProgrammaticCameraMove) {
                controller.hasUserMovedMap = true;
              }
            },
            onCameraIdle: () {
              controller.isProgrammaticCameraMove = false;
            },
            onMapCreated: (mapControllerInst) async {
              if (!controller.mapController.isCompleted) {
                controller.mapController.complete(mapControllerInst);
              }
              await controller.moveCamera(
                widget.data.currentPosition ?? widget.data.initialFocus,
                zoom: widget.mode == GoogleMapWidgetMode.addressPicker ? 13 : 11,
              );
              if (widget.mode == GoogleMapWidgetMode.display &&
                  widget.data.riderController != null &&
                  widget.data.riderController!.routeStops.isNotEmpty) {
                final isRound = widget.data.riderController!.routeType.value
                        .toUpperCase() ==
                    'ROUND';
                final orderedStops = controller._getOrderedStops(
                  widget.data.riderController!.routeStops,
                  isRoundTrip: isRound,
                );
                final String signature =
                    '${isRound ? "ROUND" : "ONE_WAY"}_${orderedStops.map((s) => '${s.stopType}_${s.latitude}_${s.longitude}_${s.sequence}').join('|')}';

                await controller._refreshRoutePolyline(
                  orderedStops,
                  signature,
                );
                if (!controller._hasFittedCameraToRoute &&
                    !controller.hasUserMovedMap) {
                  controller._hasFittedCameraToRoute = true;
                  await controller._fitCameraToRoute(orderedStops);
                }
              }
            },
            myLocationEnabled: widget.mode == GoogleMapWidgetMode.addressPicker &&
                controller.hasDeviceLocation.value,
            myLocationButtonEnabled:
                widget.mode == GoogleMapWidgetMode.addressPicker,
            onTap: controller.handleMapTap,
            markers: controller._buildDisplayMarkers(),
            polylines: controller._buildDisplayPolylines(),
          ),
        ),
        Positioned(
          right: 12,
          top: widget.mode == GoogleMapWidgetMode.addressPicker ? 84 : 24,
          child: Column(
            children: [
              _buildZoomButton(
                icon: Icons.add,
                onTap: () => controller._changeZoom(1),
              ),
              const SizedBox(height: 10),
              _buildZoomButton(
                icon: Icons.remove,
                onTap: () => controller._changeZoom(-1),
              ),
            ],
          ),
        ),
        if (widget.mode == GoogleMapWidgetMode.addressPicker) ...[
          _buildSearchOverlay(controller),
          Obx(
            () => controller.showSuggestions.value &&
                    controller.suggestions.isNotEmpty
                ? _buildSuggestionsOverlay(controller)
                : const SizedBox.shrink(),
          ),
          Obx(
            () => controller.isSearching.value
                ? _buildLoadingOverlay()
                : const SizedBox.shrink(),
          ),
          Obx(() => _buildBottomSelectionCard(controller)),
        ],
        if (widget.mode == GoogleMapWidgetMode.display &&
            widget.data.riderController != null)
          _buildRiderStatusBadge(widget.data.riderController!),
      ],
    );
  }

  Widget _buildRiderStatusBadge(RiderController riderController) {
    return Positioned(
      top: 16,
      right: 16,
      child: Obx(() {
        final orderId = riderController.orderId.value;
        if (orderId <= 0) return const SizedBox.shrink();

        final hasLocation = riderController.riderLocation.value != null;
        final isActive = riderController.isRiderActive.value && hasLocation;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF2E7D32)
                : const Color(0xFFD32F2F),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isActive ? "Rider Active" : "Rider Not Active",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildSearchOverlay(GoogleMapContentController controller) {
    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: Column(
        children: [
          Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            child: Obx(
              () => TextField(
                controller: controller.searchController,
                onChanged: controller._handleSearchInputChanged,
                onSubmitted: controller._runSearch,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search postal code, building, or road',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: controller.isSearching.value
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.my_location_outlined),
                          onPressed: controller.hasDeviceLocation.value
                              ? () => controller.moveCamera(
                                    controller.currentPosition.value,
                                    zoom: 16,
                                  )
                              : null,
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          Obx(
            () => controller.helperMessage.value != null
                ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      controller.helperMessage.value!,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            controller.helperMessage.value!.startsWith('No') ||
                                    controller.helperMessage.value!
                                        .startsWith("Couldn't")
                                ? Colors.red.shade600
                                : Colors.grey.shade700,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsOverlay(GoogleMapContentController controller) {
    return Positioned(
      top: 74,
      left: 12,
      right: 12,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 180),
          child: Obx(
            () => ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shrinkWrap: true,
              itemCount: controller.suggestions.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final suggestion = controller.suggestions[index];
                final isSelected = controller
                            .pendingSelection.value?.postalCode ==
                        suggestion.postalCode &&
                    controller.pendingSelection.value?.address ==
                        suggestion.label;

                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.location_on_outlined,
                    color: isSelected ? Colors.amber.shade700 : Colors.grey,
                  ),
                  title: Text(
                    controller._displaySuggestionText(
                      suggestion.building.isNotEmpty
                          ? suggestion.building
                          : suggestion.road,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    controller._displaySuggestionText(suggestion.label),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Colors.green.shade600,
                          size: 18,
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () async {
                    controller.showSuggestions.value = false;
                    await controller._selectSuggestion(suggestion);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.amber,
                  ),
                ),
                SizedBox(width: 10),
                Text('Finding address...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSelectionCard(GoogleMapContentController controller) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.97),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: controller.pendingSelection.value == null
              ? Row(
                  children: [
                    Icon(Icons.place_outlined, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Search or tap the map to select a location.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Selected Address',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.pendingSelection.value!.address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Postal Code: ${controller.pendingSelection.value!.postalCode.isEmpty ? 'N/A' : controller.pendingSelection.value!.postalCode}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: widget.onLocationConfirmed == null
                          ? null
                          : () => widget.onLocationConfirmed!(
                                controller.pendingSelection.value!,
                              ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Use',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
