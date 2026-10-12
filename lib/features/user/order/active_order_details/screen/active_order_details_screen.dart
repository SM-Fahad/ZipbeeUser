// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/service/app_http_client.dart';
import 'package:ZipBee/core/service/socket_service.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:flutter/services.dart';
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
import 'package:ZipBee/features/user/order/completed_order_details/completed_order_details_screen/screen/completed_order_details_screen.dart';
import 'package:ZipBee/core/service/firebase/notification_receve.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  Timer? _orderSyncTimer;
  StreamSubscription<RemoteMessage>? _fcmSubscription;
  StreamSubscription<RemoteMessage>? _localFcmSubscription;
  StreamSubscription<MapEntry<String, dynamic>>? _socketEventsSubscription;
  bool _hasNavigatedToCompleted = false;
  Function(dynamic)? _riderAssignedHandler;
  Function(dynamic)? _orderStatusUpdatedHandler;
  Function(dynamic)? _orderAssignedHandler;
  Function(dynamic)? _orderCompletedHandler;

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

    // Reset singleOrder to current order if stale or switching orders
    if (orderCtrl.singleOrder.value?.orderId != initialOrder.orderId) {
      orderCtrl.singleOrder.value = initialOrder;
    }

    final currentStatus = (orderCtrl.singleOrder.value?.status ?? initialOrder.status).trim().toUpperCase();
    if (currentStatus == 'COMPLETED') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToCompletedScreen(orderCtrl.singleOrder.value ?? initialOrder);
      });
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialIdInt > 0) {
        riderCtrl.fetchOrderData(initialIdInt, showLoader: false);
      }
      orderCtrl.fetchOrderDetail(initialOrder.orderId);
      _initSocketAndRealtime();
      _initFcmListener();
      _startOrderSyncPolling();
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
        final status = single.status.trim().toUpperCase();
        if (status == 'COMPLETED') {
          _navigateToCompletedScreen(single);
        }
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

  void _navigateToCompletedScreen(OrderModel completedOrder) {
    if (_hasNavigatedToCompleted) return;
    _hasNavigatedToCompleted = true;

    debugPrint('🏁 Order #${completedOrder.orderId} completed! Transitioning to CompletedOrderDetailsScreen');
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    Get.off(() => CompletedOrderDetailsScreen(order: completedOrder));
  }

  void _onSocketConnected() {
    final initialIdInt = int.tryParse(initialOrder.orderId) ?? 0;
    if (initialIdInt > 0) {
      debugPrint('📡 Subscribing to order room: order:subscribe for orderId: $initialIdInt');
      final socketService = SocketService();
      socketService.emit('order:subscribe', {'orderId': initialIdInt});
    }
  }

  void _initFcmListener() {
    _fcmSubscription?.cancel();
    _localFcmSubscription?.cancel();

    _fcmSubscription = FirebaseMessaging.onMessage.listen(_handleIncomingFcmMessage);
    _localFcmSubscription = FirebaseNotificationReceive.onForegroundMessageStream.stream.listen(_handleIncomingFcmMessage);
  }

  void _handleIncomingFcmMessage(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title']?.toString() ?? '';
    final body = message.notification?.body ?? message.data['body']?.toString() ?? '';
    final data = message.data;
    debugPrint('📩 FCM message in ActiveOrderDetails: title="$title", body="$body", data=$data');

    final currentIdStr = initialOrder.orderId;
    final int currentIdInt = int.tryParse(currentIdStr) ?? 0;
    final String paddedOrderId = currentIdInt > 0 ? 'ORD-${currentIdInt.toString().padLeft(6, '0')}' : '';

    final bool matchesOrder = body.contains(currentIdStr) ||
        (paddedOrderId.isNotEmpty && body.contains(paddedOrderId)) ||
        data['orderId']?.toString() == currentIdStr ||
        data['order_id']?.toString() == currentIdStr ||
        data['id']?.toString() == currentIdStr;

    final titleLower = title.toLowerCase();
    final bodyLower = body.toLowerCase();

    // Check completion condition
    final bool isCompleted = titleLower.contains('trip completed') ||
        titleLower.contains('order completed') ||
        bodyLower.contains('completed successfully') ||
        (matchesOrder && (titleLower.contains('completed') || bodyLower.contains('completed'))) ||
        data['status']?.toString().toUpperCase() == 'COMPLETED' ||
        data['order_status']?.toString().toUpperCase() == 'COMPLETED';

    if (isCompleted) {
      debugPrint('🏁 FCM Trip Completed detected for order #$currentIdStr! Transitioning screen...');
      final current = orderCtrl.singleOrder.value ?? initialOrder;
      final updated = current.copyWith(status: 'COMPLETED');
      orderCtrl.singleOrder.value = updated;
      orderCtrl.fetchOrderDetail(currentIdStr, showLoader: false);
      orderCtrl.fetchOrders(isRefresh: true);
      _navigateToCompletedScreen(updated);
      return;
    }

    if (matchesOrder ||
        titleLower.contains('trip') ||
        titleLower.contains('driver') ||
        bodyLower.contains('driver')) {
      if (titleLower.contains('arrived') || bodyLower.contains('arrived')) {
        debugPrint('📍 Driver arrived detected for order #$currentIdStr');
        orderCtrl.fetchOrderDetail(currentIdStr, showLoader: false);
        if (currentIdInt > 0) {
          riderCtrl.fetchOrderData(currentIdInt, showLoader: false);
        }
      } else {
        orderCtrl.fetchOrderDetail(currentIdStr, showLoader: false);
      }
    }
  }

  Future<void> _initSocketAndRealtime() async {
    final initialIdInt = int.tryParse(initialOrder.orderId) ?? 0;
    if (initialIdInt <= 0) return;

    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final socketService = SocketService();
      if (!socketService.isConnected) {
        await socketService.connect(token);
      }

      // Ensure RiderController has location socket initialized as well
      riderCtrl.initLocationSocket();

      // Register connect callback (runs immediately if already connected, or on connect/reconnect)
      socketService.onConnect(_onSocketConnected);

      socketService.on('order:subscribed', (data) {
        debugPrint('✅ Order room subscription acknowledged by server: $data');
      });

      _riderAssignedHandler = (data) {
        debugPrint('⚡ Socket event received: driver assigned -> $data');
        _handleDriverAssigned(data);
      };

      _orderStatusUpdatedHandler = (data) {
        debugPrint('⚡ Socket event received: order:status_updated -> $data');
        if (data is Map) {
          final incomingOrderId = int.tryParse(
            (data['orderId'] ?? data['order_id'] ?? data['order']?['id'] ?? data['id'])?.toString() ?? '',
          );
          if (incomingOrderId != null && initialIdInt > 0 && incomingOrderId != initialIdInt) {
            return;
          }

          final status = (data['order_status'] ??
                  data['status'] ??
                  (data['order'] is Map ? (data['order']['order_status'] ?? data['order']['status']) : null))
              ?.toString()
              .toUpperCase();

          if (status == 'COMPLETED') {
            _handleOrderCompleted(data);
            return;
          }

          if (status != null && status.isNotEmpty) {
            final current = orderCtrl.singleOrder.value ?? initialOrder;
            orderCtrl.singleOrder.value = current.copyWith(status: status);
          }

          if (status == 'ONGOING' || data['driver'] != null || data['riderId'] != null) {
            _handleDriverAssigned(data);
          } else if (status != null && status != 'PENDING') {
            orderCtrl.fetchOrderDetail(initialOrder.orderId, showLoader: false);
          }
        }
      };

      _orderAssignedHandler = (data) {
        debugPrint('⚡ Socket event received: order:assigned -> $data');
        _handleDriverAssigned(data);
      };

      _orderCompletedHandler = (data) {
        debugPrint('⚡ Socket event received: completion event -> $data');
        _handleOrderCompleted(data);
      };

      socketService.on('user:rider_assigned', _riderAssignedHandler!);
      socketService.on('rider_assigned', _riderAssignedHandler!);
      socketService.on('order:status_updated', _orderStatusUpdatedHandler!);
      socketService.on('order:status_update', _orderStatusUpdatedHandler!);
      socketService.on('order:assigned', _orderAssignedHandler!);
      socketService.on('order_assigned', _orderAssignedHandler!);
      socketService.on('order:completed', _orderCompletedHandler!);
      socketService.on('order_completed', _orderCompletedHandler!);
      socketService.on('trip:completed', _orderCompletedHandler!);
      socketService.on('trip_completed', _orderCompletedHandler!);
      socketService.on('user:trip_completed', _orderCompletedHandler!);
      socketService.on('order:stop_completed', (data) {
        debugPrint('⚡ Socket event received: order:stop_completed -> $data');
        orderCtrl.fetchOrderDetail(initialOrder.orderId, showLoader: false);
      });
      socketService.on('driver:arrived', (data) {
        debugPrint('⚡ Socket event received: driver:arrived -> $data');
        orderCtrl.fetchOrderDetail(initialOrder.orderId, showLoader: false);
      });
      socketService.on('order:arrived', (data) {
        debugPrint('⚡ Socket event received: order:arrived -> $data');
        orderCtrl.fetchOrderDetail(initialOrder.orderId, showLoader: false);
      });
      // Listen to all socket events as a comprehensive safety net
      _socketEventsSubscription?.cancel();
      _socketEventsSubscription = socketService.incomingEvents.listen((entry) {
        final eventName = entry.key;
        final eventData = entry.value;

        final lower = eventName.toLowerCase();
        if (lower.contains('complete') ||
            (eventData is Map &&
                (eventData['status']?.toString().toUpperCase() == 'COMPLETED' ||
                    eventData['order_status']?.toString().toUpperCase() == 'COMPLETED'))) {
          debugPrint('🏁 Incoming socket event indicated completion ($eventName): $eventData');
          _handleOrderCompleted(eventData);
        } else if (lower.contains('arrived')) {
          debugPrint('📍 Incoming socket event indicated driver arrival ($eventName)');
          orderCtrl.fetchOrderDetail(initialOrder.orderId, showLoader: false);
          if (initialIdInt > 0) {
            riderCtrl.fetchOrderData(initialIdInt, showLoader: false);
          }
        }
      });
    } catch (e) {
      debugPrint('❌ _initSocketAndRealtime error: $e');
    }
  }

  void _handleOrderCompleted(dynamic data) {
    final initialIdInt = int.tryParse(initialOrder.orderId) ?? 0;
    if (data is Map) {
      final incomingOrderId = int.tryParse(
        (data['orderId'] ?? data['order_id'] ?? data['order']?['id'] ?? data['id'])?.toString() ?? '',
      );
      if (incomingOrderId != null && initialIdInt > 0 && incomingOrderId != initialIdInt) {
        return;
      }
    }

    debugPrint('🏁 Order completion event processed for #${initialOrder.orderId}');
    final current = orderCtrl.singleOrder.value ?? initialOrder;
    final updated = current.copyWith(status: 'COMPLETED');
    orderCtrl.singleOrder.value = updated;
    orderCtrl.fetchOrderDetail(initialOrder.orderId, showLoader: false);
    orderCtrl.fetchOrders(isRefresh: true);
    _navigateToCompletedScreen(updated);
  }

  void _handleDriverAssigned(dynamic data) {
    final initialIdInt = int.tryParse(initialOrder.orderId) ?? 0;
    if (data is Map) {
      final incomingOrderId = int.tryParse(
        (data['orderId'] ?? data['order_id'] ?? data['order']?['id'] ?? data['id'])?.toString() ?? '',
      );
      if (incomingOrderId != null && initialIdInt > 0 && incomingOrderId != initialIdInt) {
        debugPrint('⏭️ Event is for order $incomingOrderId, but current order is $initialIdInt. Ignoring.');
        return;
      }
    }

    debugPrint('🎉 Driver assigned! Updating order details in real-time. Data: $data');

    // 1. Subtle haptic feedback as per backend instructions
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    // Extract driver data
    final driverData = (data is Map && data['driver'] is Map)
        ? data['driver'] as Map
        : (data is Map && data['order'] is Map && data['order']['assign_rider'] is Map)
            ? data['order']['assign_rider'] as Map
            : null;

    final riderName = driverData?['name']?.toString() ??
        driverData?['raider_name']?.toString() ??
        '';
    final riderPhone = driverData?['phone']?.toString() ??
        driverData?['contact_number']?.toString() ??
        '';
    final riderPhoto = driverData?['photo']?.toString() ??
        driverData?['image']?.toString() ??
        '';
    final vehicleType = driverData?['vehicleType']?.toString() ??
        driverData?['vehicle_type']?.toString() ??
        '';
    final riderRating = double.tryParse((driverData?['rating'] ?? '0').toString()) ?? 0.0;
    final riderId = int.tryParse((data is Map ? (data['riderId'] ?? driverData?['id']) : null)?.toString() ?? '');

    // 2. Immediate driver location update if available
    if (driverData != null && driverData['location'] is Map) {
      final loc = driverData['location'] as Map;
      final lat = double.tryParse(loc['lat']?.toString() ?? '');
      final lng = double.tryParse(loc['lng']?.toString() ?? '');
      if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
        riderCtrl.riderLocation.value = LatLng(lat, lng);
        riderCtrl.lastLocationUpdateTime.value = DateTime.now();
        riderCtrl.isRiderActive.value = true;
      }
    }

    // 3. IMMEDIATE reactive state update so header and status update in REAL TIME
    String newStatus = 'ONGOING';
    if (data is Map) {
      final s = (data['order_status'] ??
              data['status'] ??
              (data['order'] is Map ? (data['order']['order_status'] ?? data['order']['status']) : null))
          ?.toString();
      if (s != null && s.isNotEmpty) {
        newStatus = s.toUpperCase();
      }
    }

    if (newStatus == 'COMPLETED') {
      _handleOrderCompleted(data);
      return;
    }

    if (data is Map && data['order'] is Map) {
      try {
        final orderMap = Map<String, dynamic>.from(data['order'] as Map);
        if (driverData != null && orderMap['driver'] == null) {
          orderMap['driver'] = driverData;
        }
        orderMap['status'] = newStatus;
        orderMap['order_status'] = newStatus;

        final stops = orderMap['orderStops'] ?? [];
        if (stops is List && stops.isNotEmpty) {
          final pickup = stops.firstWhere((s) => s['type'] == 'PICKUP', orElse: () => {});
          final drops = stops.where((s) => s['type'] == 'DROP').toList();
          orderMap['pickup_address'] ??= pickup['address'];
          orderMap['pickup_lat'] ??= pickup['latitude'];
          orderMap['pickup_long'] ??= pickup['longitude'];
          if (drops.isNotEmpty) {
            orderMap['drop_off_address'] ??= drops.first['address'];
            orderMap['drop_off_lat'] ??= drops.first['latitude'];
            orderMap['drop_off_long'] ??= drops.first['longitude'];
          }
        }
        orderCtrl.singleOrder.value = OrderModel.fromJson(orderMap);
      } catch (e) {
        debugPrint('⚠️ Error parsing order from payload: $e');
      }
    } else {
      // If data['order'] is not present, update singleOrder immediately via copyWith
      final current = orderCtrl.singleOrder.value ?? initialOrder;
      orderCtrl.singleOrder.value = current.copyWith(
        status: newStatus,
        assignRiderName: riderName.isNotEmpty ? riderName : current.assignRiderName,
        assignRiderPhone: riderPhone.isNotEmpty ? riderPhone : current.assignRiderPhone,
        assignRiderImage: riderPhoto.isNotEmpty ? riderPhoto : current.assignRiderImage,
        assignRiderRating: riderRating > 0 ? riderRating : current.assignRiderRating,
        riderId: riderId ?? current.riderId,
        assignedRiderId: riderId ?? current.assignedRiderId,
        vehicleType: vehicleType.isNotEmpty ? vehicleType : current.vehicleType,
      );
    }

    // 4. Also update rider controller immediately
    if (riderName.isNotEmpty) {
      riderCtrl.assignRiderName.value = riderName;
    }
    if (riderPhone.isNotEmpty) {
      riderCtrl.assignRiderPhone.value = riderPhone;
    }
    if (vehicleType.isNotEmpty) {
      riderCtrl.vehicleType.value = vehicleType;
    }
    riderCtrl.assignRiderNull.value = false;

    // 5. Re-fetch full order details and rider controller data from backend in background
    orderCtrl.fetchOrderDetail(initialOrder.orderId, showLoader: false);
    if (initialIdInt > 0) {
      riderCtrl.fetchOrderData(initialIdInt, showLoader: false);
    }
    orderCtrl.fetchOrders(isRefresh: true);
  }

  void _startOrderSyncPolling() {
    _orderSyncTimer?.cancel();
    _orderSyncTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      final currentOrder = orderCtrl.singleOrder.value ?? initialOrder;
      final liveStatus = currentOrder.status.trim().toUpperCase();

      if (liveStatus == 'COMPLETED' || liveStatus == 'CANCELLED' || _hasNavigatedToCompleted) {
        _orderSyncTimer?.cancel();
        return;
      }

      try {
        final token = await SharedPreferencesHelper.getAccessToken();
        if (token == null || token.isEmpty) return;

        final url = ApiEndPoint.getOrder.replaceAll("{orderId}", initialOrder.orderId);
        final response = await AppHttpClient.get(
          Uri.parse(url),
          headers: {"Authorization": "Bearer $token"},
        );

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          final orderData = decoded['data'];
          if (orderData is Map) {
            final status = (orderData['order_status'] ?? orderData['status'] ?? '').toString().toUpperCase();
            final assignRiderId = orderData['assign_rider_id'] ?? orderData['assign_rider']?['id'];

            if (status == 'COMPLETED') {
              debugPrint('🏁 Order sync poll detected COMPLETED! Redirecting...');
              _orderSyncTimer?.cancel();
              final updated = (orderCtrl.singleOrder.value ?? initialOrder).copyWith(status: 'COMPLETED');
              orderCtrl.singleOrder.value = updated;
              _navigateToCompletedScreen(updated);
            } else if (liveStatus == 'PENDING' && status != 'PENDING' && assignRiderId != null) {
              debugPrint('✅ Order sync poll found driver assigned! Status: $status, Rider: $assignRiderId');
              _handleDriverAssigned({
                'orderId': orderData['id'] ?? initialOrder.orderId,
                'order_status': status,
                'status': status,
                'driver': orderData['assign_rider'],
                'order': orderData,
              });
            } else if (status != liveStatus) {
              debugPrint('🔄 Order sync poll detected status change: $liveStatus -> $status');
              final updated = (orderCtrl.singleOrder.value ?? initialOrder).copyWith(status: status);
              orderCtrl.singleOrder.value = updated;
              orderCtrl.fetchOrderDetail(initialOrder.orderId, showLoader: false);
            }
          }
        }
      } catch (err) {
        debugPrint('⚠️ Order sync polling error: $err');
      }
    });
  }

  @override
  void onClose() {
    _orderSyncTimer?.cancel();
    _fcmSubscription?.cancel();
    _localFcmSubscription?.cancel();
    _socketEventsSubscription?.cancel();
    final initialIdInt = int.tryParse(initialOrder.orderId) ?? 0;
    final socketService = SocketService();
    socketService.offConnect(_onSocketConnected);
    if (socketService.hasSocket) {
      if (initialIdInt > 0) {
        debugPrint('🔌 Emitting order:unsubscribe for order $initialIdInt');
        socketService.emit('order:unsubscribe', {'orderId': initialIdInt});
      }
      if (_riderAssignedHandler != null) {
        socketService.off('user:rider_assigned', _riderAssignedHandler!);
        socketService.off('rider_assigned', _riderAssignedHandler!);
      }
      if (_orderStatusUpdatedHandler != null) {
        socketService.off('order:status_updated', _orderStatusUpdatedHandler!);
        socketService.off('order:status_update', _orderStatusUpdatedHandler!);
      }
      if (_orderAssignedHandler != null) {
        socketService.off('order:assigned', _orderAssignedHandler!);
        socketService.off('order_assigned', _orderAssignedHandler!);
      }
      if (_orderCompletedHandler != null) {
        socketService.off('order:completed', _orderCompletedHandler!);
        socketService.off('order_completed', _orderCompletedHandler!);
        socketService.off('trip:completed', _orderCompletedHandler!);
        socketService.off('trip_completed', _orderCompletedHandler!);
        socketService.off('user:trip_completed', _orderCompletedHandler!);
      }
      socketService.off('order:subscribed');
    }
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

class ActiveOrderDetailsScreen extends StatefulWidget {
  final OrderModel order;

  const ActiveOrderDetailsScreen({super.key, required this.order});

  @override
  State<ActiveOrderDetailsScreen> createState() =>
      _ActiveOrderDetailsScreenState();
}

class _ActiveOrderDetailsScreenState extends State<ActiveOrderDetailsScreen> {
  late final ActiveOrderDetailsController activeOrderCtrl;

  @override
  void initState() {
    super.initState();
    activeOrderCtrl = Get.put(
      ActiveOrderDetailsController(widget.order),
      tag: widget.order.orderId,
    );
  }

  @override
  void dispose() {
    Get.delete<ActiveOrderDetailsController>(
      tag: widget.order.orderId,
      force: true,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      body: SafeArea(
        child: Obx(() {
          final liveOrder =
              activeOrderCtrl.orderCtrl.singleOrder.value ?? widget.order;
          final routeStops =
              activeOrderCtrl.orderCtrl.getOrderedRouteStops(liveOrder);
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
            'latitude': widget.order.pickupLat ?? 1.3521,
            'longitude': widget.order.pickupLong ?? 103.8198,
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
