import 'package:ZipBee/features/user/finding_raider/services/priority_order_service.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:async';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/finding_raider/model/payment_option_model.dart';
import 'package:ZipBee/features/user/finding_raider/screnn/connecting_rider_page.dart';
import 'package:ZipBee/features/user/finding_raider/services/place_order_service.dart';
import 'package:ZipBee/features/user/finding_raider/services/get_order_api_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:ZipBee/core/service/socket_service.dart';

class OrderStopMapPoint {
  final String stopType;
  final String address;
  final String name;
  final double latitude;
  final double longitude;
  final int sequence;

  const OrderStopMapPoint({
    required this.stopType,
    required this.address,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.sequence,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderStopMapPoint &&
          runtimeType == other.runtimeType &&
          stopType == other.stopType &&
          address == other.address &&
          name == other.name &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          sequence == other.sequence;

  @override
  int get hashCode =>
      stopType.hashCode ^
      address.hashCode ^
      name.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      sequence.hashCode;
}

class RiderController extends GetxController {
  final _box = GetStorage(); // GetStorage instance
  RxInt orderId = 0.obs;
  Rxn<LatLng> riderLocation = Rxn<LatLng>();
  Rxn<DateTime> lastLocationUpdateTime = Rxn<DateTime>();
  RxBool isRiderActive = false.obs;
  Timer? _activeCheckTimer;

  RxInt selectedFare = 0.obs;

  RxString riderName = 'Dylan Simpson'.obs;
  RxString vehicleType = 'Truck'.obs;
  RxString arrivalTime = '10 min'.obs;
  RxString dateTime = '25 September 2025 / 9:40 am'.obs;

  RxBool firstActive = true.obs;
  RxBool secondActive = false.obs;

  RxDouble pickupLat = 0.0.obs;
  RxDouble pickupLng = 0.0.obs;

  RxString pickupName = ''.obs;
  RxString pickupAddress = ''.obs;
  RxString dropName = ''.obs;
  RxString dropAddress = ''.obs;

  // --- New Lists for Multiple Stops ---
  RxList<Map<String, String>> pickupStops = <Map<String, String>>[].obs;
  RxList<Map<String, String>> dropStops = <Map<String, String>>[].obs;
  RxList<OrderStopMapPoint> routeStops = <OrderStopMapPoint>[].obs;

  // New loading state for API
  RxBool isLoading = false.obs;

  // Order Payment Information
  RxDouble totalCost = 0.0.obs;
  RxString paymentType = ''.obs; // COD, WALLET, ONLINE_PAY
  RxBool isPriorited = false.obs;
  RxDouble priorityFee = 0.0.obs;
  RxString routeType = 'ONE_WAY'.obs;
  RxBool assignRiderNull = true.obs;
  Rx<dynamic> assignRiderData = Rx<dynamic>(null);
  RxString orderCreatedAt = ''.obs;
  RxString scheduledTime = ''.obs;
  RxString orderUpdatedAt = ''.obs;
  RxString riderFormattedAverage = '0'.obs;
  RxString assignRiderName = ''.obs;
  RxString assignRiderPhone = ''.obs;
  RxString assignRiderUserId = ''.obs;

  Timer? _pollTimer;
  bool _isPolling = false;

  // fareOptions এখন রিয়েল-টাইম আপডেট হবে এবং ক্যাশ থেকে ডাটা নিবে
  final RxList<double> fareOptions = <double>[5, 10, 15, 20].obs;

  /// Clear old order data when starting a new order or navigating
  void clearOrderData() {
    stopPollingAssignRider();
    orderId.value = 0;
    riderLocation.value = null;
    lastLocationUpdateTime.value = null;
    isRiderActive.value = false;
    pickupStops.clear();
    dropStops.clear();
    routeStops.clear();
    pickupName.value = '';
    pickupAddress.value = '';
    dropName.value = '';
    dropAddress.value = '';
    totalCost.value = 0.0;
    paymentType.value = '';
    isPriorited.value = false;
    priorityFee.value = 0.0;
    routeType.value = 'ONE_WAY';
    assignRiderNull.value = true;
    assignRiderData.value = null;
    orderCreatedAt.value = '';
    scheduledTime.value = '';
    orderUpdatedAt.value = '';
    assignRiderName.value = '';
    assignRiderPhone.value = '';
    assignRiderUserId.value = '';
    isLoading.value = false;
    debugPrint('🧹 RiderController order data cleared');
  }

  @override
  void onInit() {
    super.onInit();
    _loadFareOptionsFromCache(); // কন্ট্রোলার স্টার্ট হওয়ার সময় ক্যাশ লোড হবে
    _startActiveCheckTimer();
    initLocationSocket();
  }

  void _startActiveCheckTimer() {
    _activeCheckTimer?.cancel();
    _activeCheckTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (lastLocationUpdateTime.value == null || riderLocation.value == null) {
        if (isRiderActive.value) isRiderActive.value = false;
        return;
      }
      final diff = DateTime.now().difference(lastLocationUpdateTime.value!).inSeconds;
      final active = diff <= 60;
      if (isRiderActive.value != active) {
        isRiderActive.value = active;
        if (!active) {
          riderLocation.value = null; // Clear location so marker & polyline remove immediately
          debugPrint("🔴 Rider marked OFFLINE / Inactive (60s without location)");
        }
      }
    });
  }

  void initLocationSocket() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final userId = await SharedPreferencesHelper.getOrExtractUserId();
      debugPrint("🔌 initLocationSocket: token presence = ${token != null && token.isNotEmpty}, userId = $userId");
      if (token != null && token.isNotEmpty) {
        final socketService = SocketService();
        if (!socketService.isConnected) {
          await socketService.connect(token);
        }

        socketService.socket.off("user:rider_location");
        socketService.socket.on("user:rider_location", (data) {
          debugPrint("🚴 Rider location socket event received. Data: $data");
          if (data is Map) {
            final incomingOrderId = int.tryParse(
              (data['orderId'] ?? data['order_id'] ?? data['id'])?.toString() ?? '',
            );

            // If an order is currently active, ignore location updates for other orders
            if (orderId.value > 0 && incomingOrderId != null && incomingOrderId != orderId.value) {
              debugPrint(
                "⏭️ Ignoring rider location for order $incomingOrderId (currently viewing order ${orderId.value})",
              );
              return;
            }

            final lat = double.tryParse(data['lat']?.toString() ?? '');
            final lng = double.tryParse(data['lng']?.toString() ?? '');

            // If valid lat/lng coordinates are received for this order's rider
            if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
              riderLocation.value = LatLng(lat, lng);
              lastLocationUpdateTime.value = DateTime.now();
              isRiderActive.value = true;
              debugPrint(
                "📍 Updated rider location: $lat, $lng (Order: ${incomingOrderId ?? orderId.value})",
              );
            } else {
              // If lat/lng not found or invalid, mark as offline
              isRiderActive.value = false;
              riderLocation.value = null;
              debugPrint(
                "🔴 Lat/Lng not found for order ${incomingOrderId ?? orderId.value}, marking rider offline",
              );
            }
          }
        });
      }
    } catch (e) {
      debugPrint("❌ initLocationSocket error: $e");
    }
  }

  // ক্যাশ থেকে ইউনিক ৪টি অ্যামাউন্ট লোড করার মেথড
  void _loadFareOptionsFromCache() {
    List? savedFares = _box.read<List>('fare_cache');
    if (savedFares != null && savedFares.isNotEmpty) {
      fareOptions.assignAll(savedFares.cast<double>());
      debugPrint('✅ Cache Loaded: $savedFares');
    }
  }

  // নতুন অ্যামাউন্ট অ্যাড এবং ক্যাশ সেভ করার মেথড (ইউনিক ৪টি)
  void addNewAmount(double amount) {
    debugPrint('🚀 Adding new amount to cache: $amount');

    List<double> currentList = List<double>.from(fareOptions);

    // যদি অ্যামাউন্টটি আগে থেকেই থাকে, তবে সেটি রিমুভ করে শুরুতে নিয়ে আসবো (ইউনিক রাখতে)
    currentList.remove(amount);
    currentList.insert(0, amount);

    // ৪টির বেশি ডাটা রাখবো না
    if (currentList.length > 4) {
      currentList = currentList.sublist(0, 4);
    }

    fareOptions.assignAll(currentList);
    _box.write('fare_cache', currentList); // ক্যাশে পার্মানেন্টলি সেভ
    selectedFare.value = 0; // নতুন অ্যামাউন্টটি সিলেক্টেড থাকবে
    debugPrint('✅ Storage Updated: $currentList');
  }

  // --- নতুন ডাটা ফেচিং মেথড ---
  Future<void> fetchOrderData(int id, {bool showLoader = true}) async {
    // If order changed, clear old stops so previous order markers do not appear
    if (orderId.value != 0 && orderId.value != id) {
      clearOrderData();
    }
    orderId.value = id;

    if (showLoader) {
      isLoading.value = true;
    }
    debugPrint('🚀 fetchOrderData started for ID: $id');

    try {
      final result = await GetOrderApiService.fetchOrderDetails(id);

      debugPrint(
        '📊 API Response: Success=${result['success']}, HasData=${result['data'] != null}',
      );

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
        final pricingSummary = data['pricingSummary'] as Map<String, dynamic>?;
        final deliveryTypeData = data['delivery_type'] as Map<String, dynamic>?;
        final vehicleTypeId = data['vehicle_type_id'];

        // =========================
        // Payment Information
        // =========================
        totalCost.value = double.tryParse(
              pricingSummary?['totalCost']?.toString() ??
                  data['total_cost']?.toString() ??
                  '0',
            ) ??
            0.0;
        paymentType.value = data['pay_type'] ?? '';
        isPriorited.value = data['isPriorited'] == true ||
            data['is_priorited'] == true ||
            data['isPriorited']?.toString() == 'true' ||
            data['is_priorited']?.toString() == 'true';
        priorityFee.value = double.tryParse(
              data['priority_fee']?.toString() ??
                  pricingSummary?['priorityFee']?.toString() ??
                  '0',
            ) ??
            0.0;
        routeType.value = (data['route_type'] ?? 'ONE_WAY').toString();
        final placedAt = data['placed_at']?.toString();
        final createdAt = data['created_at']?.toString() ?? '';
        orderCreatedAt.value =
            placedAt != null && placedAt != 'null' && placedAt.isNotEmpty
                ? placedAt
                : createdAt;
        scheduledTime.value = data['scheduled_time'] ?? '';
        orderUpdatedAt.value = data['updated_at'] ?? '';
        riderFormattedAverage.value =
            (data['formattedAverage'] ?? '0').toString();

        final deliveryVehicles =
            deliveryTypeData?['vehicle_types'] as List<dynamic>? ?? [];
        Map<String, dynamic>? selectedVehicle;

        for (final item in deliveryVehicles) {
          if (item is! Map<String, dynamic>) continue;

          if (item['vehicle_type_id'] == vehicleTypeId) {
            selectedVehicle = item['vehicle_type'] as Map<String, dynamic>?;
            break;
          }
        }

        selectedVehicle ??= deliveryVehicles.isNotEmpty &&
                deliveryVehicles.first is Map<String, dynamic>
            ? (deliveryVehicles.first as Map<String, dynamic>)['vehicle_type']
                as Map<String, dynamic>?
            : null;

        vehicleType.value =
            selectedVehicle?['vehicle_name']?.toString().trim().isNotEmpty ==
                    true
                ? selectedVehicle!['vehicle_name'].toString()
                : (selectedVehicle?['vehicle_type']?.toString() ?? '');

        // =========================
        // Assign Rider Info
        // =========================
        assignRiderData.value = data['assign_rider'];
        assignRiderNull.value = data['assign_rider'] == null;
        assignRiderName.value = '';
        assignRiderPhone.value = '';
        assignRiderUserId.value = '';

        final assignRider = data['assign_rider'];
        final riderRegistration = assignRider != null &&
                assignRider['registrations'] is List &&
                (assignRider['registrations'] as List).isNotEmpty
            ? (assignRider['registrations'] as List).first
                as Map<String, dynamic>?
            : null;

        if (assignRider != null) {
          final riderId = assignRider['id'];
          final riderUserId = assignRider['userId'];

          assignRiderUserId.value = riderUserId?.toString() ?? '';
          assignRiderName.value =
              riderRegistration?['raider_name']?.toString() ?? '';
          assignRiderPhone.value =
              riderRegistration?['contact_number']?.toString() ??
                  assignRider['phone']?.toString() ??
                  '';

          debugPrint('🚴 Assign Rider ID: $riderId');
          debugPrint('👤 Assign Rider UserID: $riderUserId');
        } else {
          debugPrint('❌ No Assign Rider Found');
        }

        // =========================
        // Save orderId to controller
        // =========================
        orderId.value = id;

        debugPrint('✅ Order Fetched Successfully:');
        debugPrint('   - Order ID: $id');
        debugPrint('   - Total Cost: ${totalCost.value}');
        debugPrint('   - Payment Type: ${paymentType.value}');
        debugPrint('   - Route Type: ${routeType.value}');
        debugPrint('   - Created At: ${orderCreatedAt.value}');

        // =========================
        // Order Stops
        // =========================
        final List orderStops = data['orderStops'] ?? [];

        final List<OrderStopMapPoint> newRouteStops = [];
        final List<Map<String, String>> newPickupStops = [];
        final List<Map<String, String>> newDropStops = [];

        String tempPickupName = '';
        String tempPickupAddress = '';
        String tempDropName = '';
        String tempDropAddress = '';

        for (var stop in orderStops) {
          if (stop is! Map<String, dynamic>) continue;
          final destination = stop['destination'] as Map<String, dynamic>?;

          final String stopType = (stop['type'] ?? '').toString().toUpperCase();
          final String destinationType =
              (destination?['type'] ?? '').toString().toUpperCase();

          final bool isPickup =
              stopType == 'PICKUP' || destinationType == 'SENDER';

          final double? lat = (stop['latitude'] as num?)?.toDouble() ??
              (destination?['latitude'] as num?)?.toDouble();
          final double? lng = (stop['longitude'] as num?)?.toDouble() ??
              (destination?['longitude'] as num?)?.toDouble();
          final int sequence = (stop['sequence'] as num?)?.toInt() ?? 0;

          final String address = (destination?['addressFromApr'] ??
                  destination?['address'] ??
                  stop['address'] ??
                  '')
              .toString();
          final String name = (destination?['contact_name'] ??
                  destination?['name'] ??
                  stop['contact_name'] ??
                  stop['name'] ??
                  '')
              .toString();
          final String contactNumber = (destination?['contact_number'] ??
                  destination?['phone'] ??
                  stop['contact_number'] ??
                  stop['phone'] ??
                  '')
              .toString();

          if (lat != null && lng != null) {
            newRouteStops.add(
              OrderStopMapPoint(
                stopType: isPickup ? 'PICKUP' : 'DROP',
                address: address,
                name: name,
                latitude: lat,
                longitude: lng,
                sequence: sequence,
              ),
            );
          }

          if (isPickup) {
            newPickupStops.add({
              'name': name,
              'address': address,
              'contactNumber': contactNumber,
            });
            tempPickupName = name;
            tempPickupAddress = address;
          } else {
            newDropStops.add({
              'name': name,
              'address': address,
              'contactNumber': contactNumber,
            });
            tempDropName = name;
            tempDropAddress = address;
          }
        }

        newRouteStops.sort((a, b) => a.sequence.compareTo(b.sequence));

        // Check if routeStops changed before updating RxList to avoid unnecessary reactive notifications
        bool routeStopsChanged = routeStops.length != newRouteStops.length;
        if (!routeStopsChanged) {
          for (int i = 0; i < routeStops.length; i++) {
            if (routeStops[i] != newRouteStops[i]) {
              routeStopsChanged = true;
              break;
            }
          }
        }
        if (routeStopsChanged) {
          routeStops.assignAll(newRouteStops);
        }

        // Check if pickupStops changed
        bool pickupStopsChanged = pickupStops.length != newPickupStops.length;
        if (!pickupStopsChanged) {
          for (int i = 0; i < pickupStops.length; i++) {
            if (pickupStops[i]['address'] != newPickupStops[i]['address'] ||
                pickupStops[i]['name'] != newPickupStops[i]['name'] ||
                pickupStops[i]['contactNumber'] != newPickupStops[i]['contactNumber']) {
              pickupStopsChanged = true;
              break;
            }
          }
        }
        if (pickupStopsChanged) {
          pickupStops.assignAll(newPickupStops);
        }

        // Check if dropStops changed
        bool dropStopsChanged = dropStops.length != newDropStops.length;
        if (!dropStopsChanged) {
          for (int i = 0; i < dropStops.length; i++) {
            if (dropStops[i]['address'] != newDropStops[i]['address'] ||
                dropStops[i]['name'] != newDropStops[i]['name'] ||
                dropStops[i]['contactNumber'] != newDropStops[i]['contactNumber']) {
              dropStopsChanged = true;
              break;
            }
          }
        }
        if (dropStopsChanged) {
          dropStops.assignAll(newDropStops);
        }

        if (pickupName.value != tempPickupName) pickupName.value = tempPickupName;
        if (pickupAddress.value != tempPickupAddress) pickupAddress.value = tempPickupAddress;
        if (dropName.value != tempDropName) dropName.value = tempDropName;
        if (dropAddress.value != tempDropAddress) dropAddress.value = tempDropAddress;

        debugPrint(
          '📦 Total Pickups: ${pickupStops.length}, Total Drops: ${dropStops.length}',
        );
      } else {
        debugPrint('❌ API Success was false or data was null');
        debugPrint('❌ Response: $result');
      }
    } catch (e) {
      debugPrint('❌ Controller Error: $e');
    } finally {
      if (showLoader) {
        isLoading.value = false;
      }
    }
  }

  // Poll order to check assign_rider status
  Future<void> startPollingAssignRider(VoidCallback? onAssignedRider) async {
    if (_isPolling) {
      debugPrint('Already polling. Skipping duplicate poll request.');
      return;
    }
    _isPolling = true;

    // Get order ID from orderId or StackedOrderController
    int? id = orderId.value > 0 ? orderId.value : null;
    if (id == null && Get.isRegistered<StackedOrderController>()) {
      final StackedOrderController orderController =
          Get.find<StackedOrderController>();
      String rawId = orderController.orderNumber.value.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      id = int.tryParse(rawId) ?? orderController.lastOrderId;
    }

    if (id == null || id == 0) {
      debugPrint('❌ Invalid Order ID for polling');
      _isPolling = false;
      return;
    }

    _pollTimer?.cancel();

    // Initial fetch
    await fetchOrderData(id, showLoader: routeStops.isEmpty);

    // If controller was disposed/unregistered during the async call, abort
    if (!Get.isRegistered<RiderController>() || !_isPolling) {
      _isPolling = false;
      return;
    }

    if (!assignRiderNull.value) {
      _isPolling = false;
      onAssignedRider?.call();
      return;
    }

    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!Get.isRegistered<RiderController>() || !_isPolling) {
        timer.cancel();
        _isPolling = false;
        return;
      }

      await fetchOrderData(id!, showLoader: false);

      if (!Get.isRegistered<RiderController>() || !_isPolling) {
        timer.cancel();
        _isPolling = false;
        return;
      }

      if (!assignRiderNull.value) {
        debugPrint('✅ Rider assigned! Stopping poll.');
        _isPolling = false;
        timer.cancel();
        onAssignedRider?.call();
      }
    });
  }

  void stopPollingAssignRider() {
    _isPolling = false;
    _pollTimer?.cancel();
    _pollTimer = null;
    debugPrint('⏹️ Polling stopped');
  }

  @override
  void onClose() {
    _isPolling = false;
    _pollTimer?.cancel();
    _activeCheckTimer?.cancel();
    final socketService = SocketService();
    if (socketService.isConnected) {
      try {
        socketService.socket.off("user:rider_location");
      } catch (e) {
        debugPrint("Error removing socket listener: $e");
      }
      socketService.disconnect();
    }
    super.onClose();
  }

  void setPickupLocation(double lat, double lng) {
    pickupLat.value = lat;
    pickupLng.value = lng;
    debugPrint('📍 Pickup set: $lat, $lng');
  }

  void setLocationFromApi({
    required String pickupName,
    required String pickupAddress,
    required String dropName,
    required String dropAddress,
  }) {
    this.pickupName.value = pickupName;
    this.pickupAddress.value = pickupAddress;
    this.dropName.value = dropName;
    this.dropAddress.value = dropAddress;
  }

  RxInt rating = 0.obs;
  void setRating(int value) => rating.value = value;

  RxInt selectedMethod = 0.obs;

  final paymentOptions = <PaymentOptionModel>[
    PaymentOptionModel(
      title: 'Stripe',
      subtitle: 'Instant payment',
      assetPath: IconPath.stripe,
    ),
    PaymentOptionModel(
      title: 'Wallet (with balance)',
      subtitle: 'S\$10.50',
      assetPath: IconPath.wallet,
    ),
  ];

  void selectMethod(int index) => selectedMethod.value = index;

  // fareOptions এখন RxList থেকে ডাইনামিকলি কাজ করবে
  void selectFare(int index) => selectedFare.value = index;

  RxInt selectedRaiderTip = 0.obs;
  final List<double> raiderTipOptions = [10, 20, 40, 100];
  void selectTip(int index) => selectedRaiderTip.value = index;

  RxBool isPlacingOrder = false.obs;
  RxBool isCancelling = false.obs;

  Future<void> placeOrder() async {
    if (isPlacingOrder.value) return;

    isPlacingOrder.value = true;

    try {
      final success = await PlaceOrderService.placeOrder(
        orderId: orderId.value,
        paymentMethod: _paymentMethod(),
        paymentMethodId: _paymentMethodId(),
      );

      if (success) {
        firstActive.value = false;
        secondActive.value = true;

        Get.to(() => ConnectingRiderPage());
      } else {
        Get.snackbar('Order Failed', 'Please try again');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      isPlacingOrder.value = false;
    }
  }

  Future<void> cancelOrder({required String reason}) async {
    if (isCancelling.value) return;

    isCancelling.value = true;

    try {
      await Future.delayed(const Duration(seconds: 1));
      Get.back();
      Get.snackbar('Order Cancelled', reason);
    } finally {
      isCancelling.value = false;
    }
  }

  void updateOrderDataFromMap(Map<String, dynamic> data) {
    isPriorited.value = data['isPriorited'] == true ||
        data['is_priorited'] == true ||
        data['isPriorited']?.toString() == 'true' ||
        data['is_priorited']?.toString() == 'true';

    priorityFee.value = double.tryParse(
          data['priority_fee']?.toString() ?? '0',
        ) ??
        0.0;

    if (data['total_cost'] != null) {
      totalCost.value =
          double.tryParse(data['total_cost'].toString()) ?? totalCost.value;
    }

    if (data['pay_type'] != null) {
      paymentType.value = data['pay_type'].toString();
    }
  }

  Future<void> addOrUpdatePriority({
    required double amount,
    required String payType,
    String? paymentMethodId,
  }) async {
    final currentOrderId = orderId.value > 0
        ? orderId.value
        : int.tryParse(
              Get.find<StackedOrderController>()
                  .orderNumber
                  .value
                  .replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0;

    if (currentOrderId == 0) {
      EasyLoading.showError('Invalid Order ID');
      return;
    }

    final bool isUpdate = isPriorited.value || priorityFee.value > 0;
    EasyLoading.show(
      status: isUpdate ? 'Updating priority...' : 'Adding priority...',
    );

    try {
      final res = isUpdate
          ? await PriorityOrderService.updatePriorityOrder(
              orderId: currentOrderId,
              amount: amount,
              payType: payType,
              paymentMethodId: paymentMethodId,
            )
          : await PriorityOrderService.addPriorityOrder(
              orderId: currentOrderId,
              amount: amount,
              payType: payType,
              paymentMethodId: paymentMethodId,
            );

      if (res['success'] == true) {
        final String msg =
            res['message'] ??
            (isUpdate ? 'Priority updated!' : 'Priority added!');
        EasyLoading.showSuccess(msg);

        if (res['data'] != null && res['data'] is Map<String, dynamic>) {
          updateOrderDataFromMap(res['data'] as Map<String, dynamic>);
        } else {
          await fetchOrderData(currentOrderId, showLoader: false);
        }
      } else {
        final String msg = res['message'] ?? 'Failed to process priority';
        EasyLoading.showError(msg);
      }
    } catch (e) {
      EasyLoading.showError('Something went wrong');
      debugPrint('❌ Priority Action Error: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> cancelPriority() async {
    final currentOrderId = orderId.value > 0
        ? orderId.value
        : int.tryParse(
              Get.find<StackedOrderController>()
                  .orderNumber
                  .value
                  .replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0;

    if (currentOrderId == 0) {
      EasyLoading.showError('Invalid Order ID');
      return;
    }

    EasyLoading.show(status: 'Cancelling priority...');

    try {
      final res = await PriorityOrderService.cancelPriorityOrder(
        orderId: currentOrderId,
      );

      if (res['success'] == true) {
        final String msg = res['message'] ?? 'Cancelled priority order';
        EasyLoading.showSuccess(msg);

        if (res['data'] != null && res['data'] is Map<String, dynamic>) {
          updateOrderDataFromMap(res['data'] as Map<String, dynamic>);
        } else {
          await fetchOrderData(currentOrderId, showLoader: false);
        }
      } else {
        final String msg = res['message'] ?? 'Failed to cancel priority';
        EasyLoading.showError(msg);
      }
    } catch (e) {
      EasyLoading.showError('Something went wrong');
      debugPrint('❌ Priority Cancel Error: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> priorityOrder() async {
    if (isLoading.value) return;

    double selectedAmount = fareOptions[selectedFare.value];

    final StackedOrderController orderController =
        Get.find<StackedOrderController>();
    String rawId = orderController.orderNumber.value.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    int? id = int.tryParse(rawId);

    if (id == null || id == 0) {
      EasyLoading.showError("Invalid Order ID");
      return;
    }

    await addOrUpdatePriority(
      amount: selectedAmount,
      payType: _paymentMethod(),
    );
  }

  String _paymentMethod() {
    switch (selectedMethod.value) {
      case 1:
        return 'WALLET';
      case 2:
        return 'COD';
      default:
        return 'COD';
    }
  }

  String _paymentMethodId() {
    if (selectedMethod.value == 1) {
      return 'wallet_balance';
    }
    return '';
  }
}
