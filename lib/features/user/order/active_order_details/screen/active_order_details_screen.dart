// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:ZipBee/features/user/finding_raider/screnn/review_view.dart';
import 'package:ZipBee/features/user/finding_raider/services/share_reward_service.dart';
import 'package:ZipBee/features/user/finding_raider/utils/ride_share_message_builder.dart';
import 'package:ZipBee/features/user/finding_raider/widget/cancel_order_dialog.dart';
import 'package:ZipBee/features/user/finding_raider/widget/finding_rider_options_widget.dart';
import 'package:ZipBee/features/user/google_map/widget/consts.dart';
import 'package:ZipBee/features/user/order/controller/order_controller.dart';
import 'package:ZipBee/features/user/order/model/order_model.dart';
import 'package:ZipBee/features/user/order/active_order_details/widgets/message_call_section.dart';
import 'package:ZipBee/features/user/order/active_order_details/widgets/order_rating_bar.dart';
import 'package:ZipBee/features/user/order/active_order_details/widgets/order_stops_list.dart';
import 'package:ZipBee/features/user/order/active_order_details/widgets/payment_and_time_info.dart';
import 'package:ZipBee/features/user/order/active_order_details/widgets/rider_details_card.dart';
import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/core/common/widgets/custom_button.dart';
import 'package:ZipBee/features/user/finding_raider/controller/rider_controller.dart';
import 'package:ZipBee/core/utils/custom_map_marker_helper.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/service/notify_rider.dart';
import 'package:ZipBee/core/service/osrm_route_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ActiveOrderDetailsController extends GetxController {
  final OrderModel initialOrder;

  ActiveOrderDetailsController(this.initialOrder);

  final OrderController orderCtrl = Get.isRegistered<OrderController>()
      ? Get.find<OrderController>()
      : Get.put(OrderController());
  final StackedOrderController stackedOrderCtrl = Get.isRegistered<StackedOrderController>()
      ? Get.find<StackedOrderController>()
      : Get.put(StackedOrderController());
  final RiderController riderCtrl = Get.isRegistered<RiderController>()
      ? Get.find<RiderController>()
      : Get.put(RiderController());

  GoogleMapController? mapController;

  final routePolylinePoints = <LatLng>[].obs;
  final RxSet<Marker> displayMarkers = <Marker>{}.obs;
  String _routeSignature = '';
  int _routeRequestId = 0;
  final driverToPickupPolylinePoints = <LatLng>[].obs;
  int _driverRouteRequestId = 0;
  DateTime? _lastDriverPolylineFetchTime;
  LatLng? _lastDriverPolylineLoc;
  Worker? _riderLocWorker;

  @override
  void onInit() {
    super.onInit();
    final initialIdInt = int.tryParse(initialOrder.orderId) ?? 0;
    stackedOrderCtrl.lastOrderId = initialIdInt;
    stackedOrderCtrl.orderNumber.value = '#${initialOrder.orderId}';
    if (riderCtrl.orderId.value != 0 && riderCtrl.orderId.value != initialIdInt) {
      riderCtrl.clearOrderData();
    }
    riderCtrl.orderId.value = initialIdInt;
    riderCtrl.priorityFee.value = initialOrder.priorityFee;
    riderCtrl.isPriorited.value =
        initialOrder.isPriorited || initialOrder.priorityFee > 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idInt = int.tryParse(initialOrder.orderId) ?? 0;
      if (idInt > 0) {
        riderCtrl.fetchOrderData(idInt, showLoader: false);
      }
      orderCtrl.fetchOrderDetail(initialOrder.orderId);
    });

    ever(riderCtrl.riderLocation, (_) => _updateMarkers());
    ever(riderCtrl.isRiderActive, (active) {
      if (active == false) {
        driverToPickupPolylinePoints.clear();
      }
      _updateMarkers();
    });
    ever(orderCtrl.singleOrder, (OrderModel? single) {
      if (single != null) {
        riderCtrl.priorityFee.value = single.priorityFee;
        riderCtrl.isPriorited.value =
            single.isPriorited || single.priorityFee > 0;
      }
      _updateMarkers();
    });
    _updateMarkers();

    _riderLocWorker = ever<LatLng?>(
      riderCtrl.riderLocation,
      (loc) async {
        if (loc == null) {
          driverToPickupPolylinePoints.clear();
          return;
        }
        final routeStops = orderCtrl.getOrderedRouteStops(orderCtrl.singleOrder.value ?? initialOrder);
        if (routeStops.isNotEmpty) {
          final pickup = routeStops.first;
          final pickupLat = pickup['latitude'] as double?;
          final pickupLng = pickup['longitude'] as double?;
          if (pickupLat != null && pickupLng != null) {
            await _throttledRefreshDriverToPickupPolyline(loc, LatLng(pickupLat, pickupLng));
          }
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loc = riderCtrl.riderLocation.value;
      final routeStops = orderCtrl.getOrderedRouteStops(orderCtrl.singleOrder.value ?? initialOrder);
      if (loc != null && routeStops.isNotEmpty) {
        final pickup = routeStops.first;
        final pickupLat = pickup['latitude'] as double?;
        final pickupLng = pickup['longitude'] as double?;
        if (pickupLat != null && pickupLng != null) {
          await _throttledRefreshDriverToPickupPolyline(loc, LatLng(pickupLat, pickupLng));
        }
      }
    });
  }

  @override
  void onClose() {
    _riderLocWorker?.dispose();
    mapController = null;
    super.onClose();
  }

  void syncRoute(List<Map<String, dynamic>> routeStops) {
    final signature = routeStops
        .map(
          (stop) =>
              '${stop['type']}_${stop['latitude']}_${stop['longitude']}_${stop['sequence']}',
        )
        .join('|');

    if (signature == _routeSignature) return;
    _routeSignature = signature;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refreshRoutePolyline(routeStops);
      await _fitCameraToRoute(routeStops);
    });
  }

  Future<void> _refreshRoutePolyline(List<Map<String, dynamic>> stops) async {
    final requestId = ++_routeRequestId;

    if (stops.length < 2) {
      routePolylinePoints.value = const [];
      return;
    }

    try {
      final points = await _fetchRoadRoutePoints(stops);
      if (requestId != _routeRequestId) return;
      routePolylinePoints.assignAll(points);
    } catch (error) {
      debugPrint('❌ Failed to load active order road route polyline: $error');
      if (requestId != _routeRequestId) return;
      final fallbackPoints = stops
          .map((stop) => LatLng(
                (stop['latitude'] as num).toDouble(),
                (stop['longitude'] as num).toDouble(),
              ))
          .toList();
      routePolylinePoints.assignAll(fallbackPoints);
    }
  }

  Future<List<LatLng>> _fetchRoadRoutePoints(
      List<Map<String, dynamic>> stops) async {
    final waypoints = stops
        .map((stop) => LatLng(
              (stop['latitude'] as num).toDouble(),
              (stop['longitude'] as num).toDouble(),
            ))
        .toList();

    // 1️⃣ Try OSRM road routing first (fast & accurate road-following polyline)
    final osrmPoints = await OsrmRouteService.fetchRoadPolyline(waypoints);
    if (osrmPoints.length > 2) {
      return osrmPoints;
    }

    // 2️⃣ Fallback to Google Directions API
    try {
      final legacyClient = PolylinePoints.legacy(GoogleMapAPIKey);
      final legacyResult = await legacyClient.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(
            (stops.first['latitude'] as num).toDouble(),
            (stops.first['longitude'] as num).toDouble(),
          ),
          destination: PointLatLng(
            (stops.last['latitude'] as num).toDouble(),
            (stops.last['longitude'] as num).toDouble(),
          ),
          mode: TravelMode.driving,
          wayPoints: stops
              .sublist(1, stops.length - 1)
              .map(
                (stop) => PolylineWayPoint(
                  location: '${stop['latitude']},${stop['longitude']}',
                ),
              )
              .toList(),
        ),
      );

      final legacyPoints = legacyResult.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      if (legacyPoints.length > 2) {
        return legacyPoints;
      }
    } catch (e) {
      debugPrint('⚠️ Directions API failed: $e');
    }

    if (osrmPoints.length >= 2) {
      return osrmPoints;
    }

    return waypoints;
  }

  Future<void> _fitCameraToRoute(List<Map<String, dynamic>> stops) async {
    final mController = mapController;
    if (mController == null || stops.isEmpty) return;

    try {
      if (stops.length == 1) {
        final lat = (stops.first['latitude'] as num?)?.toDouble();
        final lng = (stops.first['longitude'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          await mController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(lat, lng),
                zoom: 15,
              ),
            ),
          );
        }
        return;
      }

      double? minLat, maxLat, minLng, maxLng;
      for (final stop in stops) {
        final lat = (stop['latitude'] as num?)?.toDouble();
        final lng = (stop['longitude'] as num?)?.toDouble();
        if (lat == null || lng == null) continue;

        minLat = minLat == null ? lat : (lat < minLat ? lat : minLat);
        maxLat = maxLat == null ? lat : (lat > maxLat ? lat : maxLat);
        minLng = minLng == null ? lng : (lng < minLng ? lng : minLng);
        maxLng = maxLng == null ? lng : (lng > maxLng ? lng : maxLng);
      }

      if (minLat != null && maxLat != null && minLng != null && maxLng != null) {
        await mController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(minLat, minLng),
              northeast: LatLng(maxLat, maxLng),
            ),
            72,
          ),
        );
      }
    } catch (e) {
      debugPrint('⚠️ Error fitting camera to route: $e');
    }
  }

  Future<void> _throttledRefreshDriverToPickupPolyline(
    LatLng driverLoc,
    LatLng pickupLoc,
  ) async {
    final now = DateTime.now();

    // If polyline was previously loaded and we have a reference driver position
    if (driverToPickupPolylinePoints.isNotEmpty &&
        _lastDriverPolylineFetchTime != null &&
        _lastDriverPolylineLoc != null) {
      final elapsedSeconds = now.difference(_lastDriverPolylineFetchTime!).inSeconds;
      final distanceMovedMeters = OsrmRouteService.calculateDistanceMeters(
        _lastDriverPolylineLoc!,
        driverLoc,
      );

      // 1. If driver moved less than 25 meters, skip hitting the routing API completely
      // (even after 60s, if stationary don't hit map API)
      if (distanceMovedMeters < 25.0) {
        return;
      }

      // 2. If driver moved, throttle API requests to at most once every 15 seconds
      if (elapsedSeconds < 15) {
        return;
      }
    }

    _lastDriverPolylineFetchTime = now;
    _lastDriverPolylineLoc = driverLoc;
    await _refreshDriverToPickupPolyline(driverLoc, pickupLoc);
  }

  Future<void> _refreshDriverToPickupPolyline(LatLng driverLoc, LatLng pickupLoc) async {
    final requestId = ++_driverRouteRequestId;
    try {
      final points = await _fetchRoadRoutePointsForTwoPoints(driverLoc, pickupLoc);
      if (requestId != _driverRouteRequestId) return;
      driverToPickupPolylinePoints.assignAll(points);
    } catch (error) {
      debugPrint('❌ Failed to load driver to pickup road route polyline in active order screen: $error');
      if (requestId != _driverRouteRequestId) return;
      driverToPickupPolylinePoints.assignAll([driverLoc, pickupLoc]);
    }
  }

  Future<List<LatLng>> _fetchRoadRoutePointsForTwoPoints(LatLng origin, LatLng destination) async {
    final osrmPoints = await OsrmRouteService.fetchRoadPolyline([origin, destination]);
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

  Future<void> _updateMarkers() async {
    final nextMarkers = <Marker>{};
    final liveOrder = orderCtrl.singleOrder.value ?? initialOrder;
    final routeStops = orderCtrl.getOrderedRouteStops(liveOrder);

    final totalDrops = routeStops.where((stop) => stop['type'] != 'PICKUP').length;
    final showNumbers = totalDrops > 1;

    int dropCount = 0;

    for (var i = 0; i < routeStops.length; i++) {
      final stop = routeStops[i];
      final isPickup = stop['type'] == 'PICKUP';

      String title;
      BitmapDescriptor icon;

      if (isPickup) {
        title = 'Collection';
        icon = await CustomMapMarkerHelper.getPickupMarker();
      } else {
        dropCount++;
        title = 'Delivery';
        if (showNumbers) {
          icon = await CustomMapMarkerHelper.getNumberedDropMarker(
            number: dropCount,
          );
        } else {
          icon = await CustomMapMarkerHelper.getDropMarker();
        }
      }

      final latitude = stop['latitude'] as double?;
      final longitude = stop['longitude'] as double?;
      if (latitude != null && longitude != null) {
        nextMarkers.add(
          Marker(
            markerId: MarkerId(
              '${stop['type']}_${stop['sequence']}_${latitude}_$longitude',
            ),
            position: LatLng(latitude, longitude),
            anchor: CustomMapMarkerHelper.defaultAnchor,
            icon: icon,
            infoWindow: InfoWindow(
              title: title,
              snippet: stop['address']?.toString() ?? '',
            ),
          ),
        );
      }
    }

    if (riderCtrl.riderLocation.value != null && riderCtrl.isRiderActive.value) {
      final riderIcon = await CustomMapMarkerHelper.getRiderMarker();
      nextMarkers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: riderCtrl.riderLocation.value!,
          anchor: CustomMapMarkerHelper.defaultAnchor,
          icon: riderIcon,
          infoWindow: const InfoWindow(
            title: 'Rider',
          ),
        ),
      );
    }

    displayMarkers.assignAll(nextMarkers);
  }
}

class ActiveOrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const ActiveOrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final activeOrderCtrl = Get.put(
      ActiveOrderDetailsController(order),
      tag: order.orderId,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      body: SafeArea(
        child: Obx(() {
          final liveOrder = activeOrderCtrl.orderCtrl.singleOrder.value ?? order;
          final routeStops = activeOrderCtrl.orderCtrl.getOrderedRouteStops(liveOrder);
          activeOrderCtrl.syncRoute(routeStops);

          return Stack(
            children: [
              Positioned.fill(child: _buildMap(activeOrderCtrl, routeStops)),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildHeader(liveOrder),
              ),
              _buildRiderStatusBadge(activeOrderCtrl, liveOrder),
              _OrderDetailsBottomSheet(
                order: liveOrder,
                controller: activeOrderCtrl.orderCtrl,
                riderController: activeOrderCtrl.riderCtrl,
                stackedOrderController: activeOrderCtrl.stackedOrderCtrl,
              ),
              if (activeOrderCtrl.orderCtrl.isDetailLoading.value)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(OrderModel liveOrder) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          Expanded(
            child: Center(
              child: Text(
                "Order #${liveOrder.orderId} is ${liveOrder.status.toLowerCase()}",
                style: getTextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildRiderStatusBadge(
    ActiveOrderDetailsController activeOrderCtrl,
    OrderModel liveOrder,
  ) {
    final status = liveOrder.status.trim().toUpperCase();
    final isTerminalOrPending = status == 'PENDING' ||
        status == 'CANCELLED' ||
        status == 'COMPLETED' ||
        status == 'EXPIRED';

    if (isTerminalOrPending) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 68,
      right: 20,
      child: Obx(() {
        final hasLocation =
            activeOrderCtrl.riderCtrl.riderLocation.value != null;
        final isActive =
            activeOrderCtrl.riderCtrl.isRiderActive.value && hasLocation;

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

  Widget _buildMap(ActiveOrderDetailsController activeOrderCtrl, List<Map<String, dynamic>> routeStops) {
    final initialStop = routeStops.isNotEmpty
        ? routeStops.first
        : {
            'latitude': order.pickupLat ?? 1.3521,
            'longitude': order.pickupLong ?? 103.8198,
          };

    final lat = (initialStop['latitude'] as num?)?.toDouble() ?? 1.3521;
    final lng = (initialStop['longitude'] as num?)?.toDouble() ?? 103.8198;

    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(lat, lng),
        zoom: 12,
      ),
      onMapCreated: (mapController) async {
        activeOrderCtrl.mapController = mapController;
        await activeOrderCtrl._fitCameraToRoute(routeStops);
      },
      markers: activeOrderCtrl.displayMarkers.toSet(),
      polylines: _buildPolylines(activeOrderCtrl),
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
    );
  }

  Set<Polyline> _buildPolylines(ActiveOrderDetailsController activeOrderCtrl) {
    final polylines = <Polyline>{};

    if (activeOrderCtrl.routePolylinePoints.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('active_order_route'),
          color: const Color(0xFF1565C0), // Blue
          width: 5,
          geodesic: false,
          points: activeOrderCtrl.routePolylinePoints,
        ),
      );
    }

    if (activeOrderCtrl.riderCtrl.riderLocation.value != null &&
        activeOrderCtrl.riderCtrl.isRiderActive.value &&
        activeOrderCtrl.driverToPickupPolylinePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('driver_to_pickup'),
          color: const Color(0xFFFFCC00), // ZipBee primary yellow
          width: 5,
          geodesic: false,
          points: activeOrderCtrl.driverToPickupPolylinePoints,
        ),
      );
    }

    return polylines;
  }
}

class _OrderDetailsBottomSheet extends StatelessWidget {
  final OrderModel order;
  final OrderController controller;
  final RiderController riderController;
  final StackedOrderController stackedOrderController;

  const _OrderDetailsBottomSheet({
    required this.order,
    required this.controller,
    required this.riderController,
    required this.stackedOrderController,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = order.status.trim().toUpperCase() == 'PENDING';

    return DraggableScrollableSheet(
      initialChildSize: 0.30,
      minChildSize: 0.22,
      maxChildSize: 0.68,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                if (!isPending) ...[
                  RiderDetailsCard(order: order),
                  SizedBox(height: 16),
                  MessageCallSection(order: order),
                  SizedBox(height: 12),
                  _buildConfirmationStatusWidget(context, order),
                  SizedBox(height: 12),
                  OrderRatingBar(
                    rating: order.assignRiderRating,
                    totalReviews: order.assignRiderReviews,
                    onTap: () {
                      Get.to(
                        () => ReviewView(
                          orderId: order.orderId,
                          riderId: order.riderId,
                        ),
                      );
                    },
                  ),
                  Divider(height: 32),
                ],
                PaymentAndTimeInfo(order: order),
                SizedBox(height: 24),
                OrderStopsList(
                  pickupStops: controller.getPickupStops(order),
                  dropStops: controller.getDropStops(order),
                  showReturnSection: order.routeType.toUpperCase() == 'ROUND',
                ),
                if (isPending) ...[
                  const SizedBox(height: 20),
                  FindingRiderOptionsWidget(
                    riderController: riderController,
                  ),
                ],
                SizedBox(height: 32),
                CustomButton(
                  label: 'Share Ride Information',
                  onPressed: () async {
                    final shareMessage = RideShareMessageBuilder.build(
                      orderId: '#${order.orderId}',
                      assignedRiderId: (order.assignedRiderId ?? order.riderId)
                              ?.toString() ??
                          'N/A',
                      riderName: order.assignRiderName.isNotEmpty
                          ? order.assignRiderName
                          : 'Not Assigned',
                      totalFare: order.total.toStringAsFixed(2),
                      paymentType: RideShareMessageBuilder.paymentMethodLabel(
                        order.paymentType,
                      ),
                      pickupStops: controller.getPickupStops(order),
                      dropStops: controller.getDropStops(order),
                      routeType: order.routeType,
                      scheduledDateTime:
                          RideShareMessageBuilder.scheduledDateTimeLabel(
                        scheduledTime: order.scheduledTime,
                        fallbackCreatedAt: order.placedAt,
                      ),
                      jobAcceptedTime: RideShareMessageBuilder.formatDateTime(
                        order.updatedAt,
                      ),
                    );

                    await ShareRewardService.share();
                    await SharePlus.instance.share(
                      ShareParams(text: shareMessage),
                    );
                  },
                  color: AppColors.primaryButtonColor,
                  textColor: AppColors.fontColor,
                ),
                if (isPending) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => showCancelOrderDialog(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: const BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Cancel order',
                            style: getTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Image.asset(IconPath.cancel),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfirmationStatusWidget(BuildContext context, OrderModel order) {
    if (order.isAutoConfirmation) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text(
              "Order Auto Confirmed",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (!order.raiderConfirmation) {
      return const SizedBox.shrink();
    }

    if (order.userConfirmationAt == null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showConfirmationDialog(context, order),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_empty, color: Colors.black, size: 18),
              SizedBox(width: 8),
              Text(
                "Pending Confirmation",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text(
              "Order Confirmed",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showConfirmationDialog(BuildContext context, OrderModel order) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Confirm Order",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Did the driver call you to confirm the order?",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              "No",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // close dialog
              EasyLoading.show(status: 'Confirming...');
              try {
                final res = await NotifyRider.userConfirmation(
                  orderId: order.orderId,
                );
                final success = res['success'] as bool? ?? false;
                if (success) {
                  EasyLoading.showSuccess('Order confirmed successfully');
                  controller.fetchOrderDetail(order.orderId);
                } else {
                  final msg = res['body']?['message'] ?? 'Failed to confirm order';
                  EasyLoading.showError(msg.toString());
                }
              } catch (e) {
                debugPrint('Error confirming order: $e');
                EasyLoading.showError('An error occurred');
              }
            },
            child: const Text(
              "Yes",
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
