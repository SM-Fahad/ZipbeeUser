import 'package:ZipBee/features/user/bottom_navbar/screen/bottom_navbar_screen.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/service/cancel_order_service.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/service/order_service.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/service/order_confirmation_service.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/widget/payment_method_widget.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/service/notify_rider.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/service/promo_service.dart';
import 'package:ZipBee/features/user/vehicle_type/controller/additional_controller.dart';
import 'package:ZipBee/features/user/vehicle_type/controller/controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:ZipBee/features/user/stacked/stacked_controller/stacked_controller.dart';
import 'package:ZipBee/features/user/stacked/widget/pic_date_time.dart';

class StackedOrderController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _handleArguments();
    ensureInitialPricingLoaded();
  }

  // Last Oder ID & Delivery type
  int? lastOrderId;
  final deliveryType = ''.obs;
  final deliveryTypeId = RxnInt();

  void setDeliveryTypeName(String? rawName) {
    if (rawName == null || rawName.trim().isEmpty) return;
    deliveryType.value = rawName.trim().toUpperCase();
  }

  void setDeliveryTypeId(int? id) {
    deliveryTypeId.value = id;
  }

  String get deliveryTypeDisplayName {
    final raw = deliveryType.value.trim();
    if (raw.isEmpty) return '';
    return raw
        .toLowerCase()
        .split('_')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  double _extractPreferredTotalCost(Map<String, dynamic> data) {
    final pricingSummary = data['pricingSummary'] as Map<String, dynamic>?;
    if (pricingSummary != null && pricingSummary['totalCost'] != null) {
      return _toDouble(pricingSummary['totalCost']);
    }

    final orderMap = data['order'] as Map<String, dynamic>?;
    if (orderMap != null && orderMap['total_cost'] != null) {
      return _toDouble(orderMap['total_cost']);
    }

    return _toDouble(data['total_cost']);
  }

  double _extractPreferredTotalFee(Map<String, dynamic> data) {
    final pricingSummary = data['pricingSummary'] as Map<String, dynamic>?;
    if (pricingSummary != null && pricingSummary['totalFee'] != null) {
      return _toDouble(pricingSummary['totalFee']);
    }

    final orderMap = data['order'] as Map<String, dynamic>?;
    if (orderMap != null && orderMap['total_fee'] != null) {
      return _toDouble(orderMap['total_fee']);
    }

    return _toDouble(data['total_fee']);
  }

  double _sumAdditionalServicePrices(dynamic rawServices) {
    if (rawServices is! List) return 0.0;

    return rawServices.fold<double>(0.0, (sum, item) {
      if (item is! Map<String, dynamic>) return sum;
      return sum + _toDouble(item['price']);
    });
  }

  void _syncPricingSummary(Map<String, dynamic> orderData) {
    final pricingSummary = orderData['pricingSummary'] as Map<String, dynamic>?;
    final deliveryTypeMap = orderData['delivery_type'] as Map<String, dynamic>?;
    final additionalServices = orderData['additional_services'];

    final totalFromSummary = pricingSummary != null
        ? _toDouble(pricingSummary['totalCost'])
        : null;
    final feeFromSummary = pricingSummary != null
        ? _toDouble(pricingSummary['totalFee'])
        : null;

    final resolvedTotalCost =
        totalFromSummary ?? _toDouble(orderData['total_cost']);
    final resolvedTotalFee =
        feeFromSummary ?? _toDouble(orderData['total_fee']);

    totalCost.value = resolvedTotalCost;
    totalAmount.value = resolvedTotalCost;
    totalFee.value = resolvedTotalFee;

    pricingBasePrice.value = pricingSummary != null
        ? _toDouble(pricingSummary['basePrice'])
        : 0.0;
    pricingDeliveryTypeCharge.value = pricingSummary != null
        ? _toDouble(pricingSummary['deliveryTypeCharge'])
        : 0.0;
    final additionalServiceFeeFromSummary = pricingSummary != null
        ? _toDouble(pricingSummary['additionServiceFee'])
        : 0.0;
    final additionalServiceFeeFromOrder = _toDouble(
      orderData['additional_cost'],
    );
    final additionalServiceFeeFromList = _sumAdditionalServicePrices(
      additionalServices,
    );

    pricingAdditionalServiceCost.value = additionalServiceFeeFromSummary > 0
        ? additionalServiceFeeFromSummary
        : additionalServiceFeeFromOrder > 0
        ? additionalServiceFeeFromOrder
        : additionalServiceFeeFromList;
    deliveryTypeMultiplier.value = _toDouble(
      deliveryTypeMap?['price_multiplier'],
    );

    final selectedVehicleId = _toInt(orderData['vehicle_type_id']);
    final rawVehicleTypes = deliveryTypeMap?['vehicle_types'];
    if (selectedVehicleId != null && rawVehicleTypes is List) {
      for (final item in rawVehicleTypes) {
        if (item is! Map<String, dynamic>) continue;
        final nestedVehicle = item['vehicle_type'] as Map<String, dynamic>?;
        if (_toInt(item['vehicle_type_id']) == selectedVehicleId ||
            _toInt(nestedVehicle?['id']) == selectedVehicleId) {
          pricingVehicleName.value =
              nestedVehicle?['vehicle_name']?.toString() ??
              nestedVehicle?['vehicle_type']?.toString() ??
              '';
          break;
        }
      }
    }

    if (pricingVehicleName.value.isEmpty) {
      try {
        final vehicleCtrl = Get.find<StackedVehicleController>();
        pricingVehicleName.value =
            vehicleCtrl.selectedVehicle.value?.name ?? pricingVehicleName.value;
      } catch (_) {}
    }
  }

  void syncOrderData(Map<String, dynamic> orderData) {
    final orderId = orderData['id'];
    if (orderId != null) {
      lastOrderId = orderId is int ? orderId : int.tryParse(orderId.toString());
      if (lastOrderId != null) {
        orderNumber.value = '#$lastOrderId';
      }
    }

    final deliveryTypeMap = orderData['delivery_type'] as Map<String, dynamic>?;
    final rawDeliveryTypeId =
        deliveryTypeMap?['id'] ?? orderData['delivery_type_id'];
    setDeliveryTypeId(
      rawDeliveryTypeId is int
          ? rawDeliveryTypeId
          : int.tryParse(rawDeliveryTypeId?.toString() ?? ''),
    );
    setDeliveryTypeName(
      deliveryTypeMap?['name']?.toString() ??
          orderData['delivery_type']?.toString(),
    );

    final isFixedValue = orderData['isFixed'];
    if (isFixedValue != null) {
      isFixed.value = isFixedValue == true || isFixedValue.toString() == 'true';
    }

    _syncPricingSummary(orderData);

    try {
      final vehicleCtrl = Get.find<StackedVehicleController>();
      vehicleCtrl.syncFromOrderData(orderData);
    } catch (_) {}

    try {
      final additionalCtrl = Get.find<AdditionalServiceController>();
      additionalCtrl.syncSelectedServicesFromOrder(orderData);
    } catch (_) {}
  }

  // Get arguments from create order in Home controller
  void _handleArguments() {
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;

      // Order ID set
      if (args.containsKey('orderId')) {
        lastOrderId = args['orderId'];
      }

      // Set delivery type
      if (args.containsKey('deliveryType')) {
        setDeliveryTypeName(args['deliveryType']?.toString());
      }

      if (args.containsKey('deliveryTypeId')) {
        final rawDeliveryTypeId = args['deliveryTypeId'];
        setDeliveryTypeId(
          rawDeliveryTypeId is int
              ? rawDeliveryTypeId
              : int.tryParse(rawDeliveryTypeId?.toString() ?? ''),
        );
      }

      if (args['order'] is Map<String, dynamic>) {
        syncOrderData(args['order'] as Map<String, dynamic>);
      }

      debugPrint(
        'StackedOrderController initialized with Order ID: $lastOrderId and Delivery Type: $deliveryType',
      );
    }
  }

  var orderNumber = ''.obs;
  var isDriverAssigned = false.obs;
  var countdown = 10.obs;

  // New properties for Order Confirmation Details
  var totalAmount = 0.0.obs; // Will be set before showing dialog (server value)
  var totalFee = 0.0.obs; // server-side fee (preferred display when available)
  var totalCost = 0.0.obs; // total_cost from API response (direct from server)
  var pricingBasePrice = 0.0.obs;
  var pricingDeliveryTypeCharge = 0.0.obs;
  var pricingAdditionalServiceCost = 0.0.obs;
  var deliveryTypeMultiplier = 1.0.obs;
  var pricingVehicleName = ''.obs;
  var isBreakdownExpanded = false.obs;
  var redeemCoins = false.obs;
  var favoriteRiders = false.obs;
  int userCoinBalance = 0; // User's current coin balance from API

  // Promo code and discount fields
  var promoCode = ''.obs; // Applied promo code
  var discountAmount = 0.0.obs; // Discount amount from promo
  var promoDiscount = 0.0.obs; // Promo discount percentage/value
  var originalCost = 0.0.obs; // Original cost before discount
  var coinsRedeemed = 0.obs; // Coins redeemed for discount

  // Loading states
  var isFetchingTotal = false.obs; // Track if currently fetching total
  bool _hasRequestedInitialPricing = false;

  // Route options
  var isFixed = false.obs; // Fixed route toggle

  // API Response Data
  var placeOrderResponse = Rx<Map<String, dynamic>?>(null);
  var isAutoConfirmation = false.obs;
  var collectTime = 'ASAP'.obs; // 'ASAP' or 'SCHEDULED'
  var senderInfo = Rx<Map<String, dynamic>?>(null);
  var receiverInfo = Rx<Map<String, dynamic>?>(null);

  var isCancelling = false.obs;
  var isUpdatingDiscount = false.obs;

  String get displayOrderNumber {
    final existing = orderNumber.value.trim();
    if (existing.isNotEmpty) return existing;

    final currentOrderId = lastOrderId;
    if (currentOrderId != null && currentOrderId > 0) {
      return '#$currentOrderId';
    }

    final body = placeOrderResponse.value;
    final data = body?['data'];
    if (data is Map<String, dynamic>) {
      final responseOrderId = data['id'];
      final parsedId = responseOrderId is int
          ? responseOrderId
          : int.tryParse(responseOrderId?.toString() ?? '');
      if (parsedId != null && parsedId > 0) {
        return '#$parsedId';
      }
    }

    return '';
  }

  void toggleBreakdown() {
    isBreakdownExpanded.value = !isBreakdownExpanded.value;
  }

  Future<bool> _refreshOrderPricingFromGet([int? orderId]) async {
    final resolvedOrderId = orderId ?? lastOrderId;
    if (resolvedOrderId == null || resolvedOrderId == 0) {
      return false;
    }

    final orderRes = await OrderConfirmationService.getOrder(resolvedOrderId);
    final orderSuccess = orderRes['success'] as bool? ?? false;
    final orderStatus = orderRes['statusCode'] as int? ?? 500;

    if (!orderSuccess || (orderStatus != 200 && orderStatus != 201)) {
      debugPrint(
        '❌ Failed to refresh order pricing from GET for orderId: $resolvedOrderId',
      );
      return false;
    }

    final orderData = orderRes['body'] as Map<String, dynamic>? ?? {};
    final orderActualData = orderData['data'] as Map<String, dynamic>? ?? {};
    if (orderActualData.isEmpty) {
      return false;
    }

    syncOrderData(orderActualData);
    return true;
  }

  Future<void> ensureInitialPricingLoaded() async {
    if (_hasRequestedInitialPricing) return;
    if (lastOrderId == null) return;
    if (totalCost.value > 0 || isFetchingTotal.value) return;

    _hasRequestedInitialPricing = true;
    await fetchOrderTotalCost();
  }

  Future<void> handleOrderCancellation(String? reason) async {
    if (lastOrderId == null) {
      cancelAndReset();
      Get.offAll(() => BottomNavbarScreen());
      return;
    }

    try {
      isCancelling.value = true;

      final result = await CancelOrderService.cancelOrder(lastOrderId!, reason);

      isCancelling.value = false;

      if (result['success'] == true) {
        EasyLoading.showSuccess('Order Cancelled');

        cancelAndReset();

        Get.offAll(() => BottomNavbarScreen());
      } else {
        String errorMsg =
            result['body']?['message'] ?? 'Failed to cancel order';
        EasyLoading.showError(errorMsg);
      }
    } catch (e) {
      isCancelling.value = false;
      debugPrint('Error in handleOrderCancellation: $e');
      EasyLoading.showError('An error occurred while cancelling');
    }
  }

  void _applyDiscountStateFromData(
    Map<String, dynamic> data, {
    String? fallbackPromoCode,
  }) {
    syncOrderData(data);

    promoCode.value =
        data['promoCode']?.toString() ?? fallbackPromoCode ?? promoCode.value;
    discountAmount.value =
        double.tryParse(data['discountAmount']?.toString() ?? '0') ?? 0;
    promoDiscount.value =
        double.tryParse(data['promoDiscount']?.toString() ?? '0') ?? 0;
    originalCost.value =
        double.tryParse(data['originalCost']?.toString() ?? '0') ?? 0;
    coinsRedeemed.value =
        int.tryParse(data['coinsRedeemed']?.toString() ?? '0') ?? 0;
    redeemCoins.value = coinsRedeemed.value > 0;
  }

  Future<void> toggleRedeemCoins(bool value, {required int coinsAmount}) async {
    if (lastOrderId == null) {
      EasyLoading.showError('Order not created yet');
      return;
    }

    if (isUpdatingDiscount.value) return;

    if (value && coinsAmount <= 0) {
      EasyLoading.showInfo('No coins available');
      return;
    }

    isUpdatingDiscount.value = true;
    final previousRedeemState = redeemCoins.value;

    EasyLoading.show(status: value ? 'Applying coins...' : 'Removing coins...');

    try {
      final res = value
          ? await PromoService.applyCoins(
              orderId: lastOrderId!,
              coinsAmount: coinsAmount,
            )
          : await PromoService.removeDiscount(
              orderId: lastOrderId!,
              type: 'coin',
            );

      final success = res['success'] as bool? ?? false;
      if (!success) {
        redeemCoins.value = previousRedeemState;
        EasyLoading.showError(
          res['body']?['message'] ??
              (value ? 'Failed to apply coins' : 'Failed to remove coins'),
        );
        return;
      }

      if (value) {
        final body = res['body'] as Map<String, dynamic>? ?? {};
        final data = body['data'] as Map<String, dynamic>? ?? {};
        _applyDiscountStateFromData(data);
        await _refreshOrderPricingFromGet();
      } else {
        redeemCoins.value = false;
        coinsRedeemed.value = 0;
        await _refreshOrderPricingFromGet();
      }

      EasyLoading.showSuccess(
        res['body']?['message'] ??
            (value ? 'Coins applied successfully' : 'Coins removed successfully'),
      );
    } catch (e) {
      redeemCoins.value = previousRedeemState;
      debugPrint('❌ toggleRedeemCoins error: $e');
      EasyLoading.showError('Something went wrong');
    } finally {
      isUpdatingDiscount.value = false;
      EasyLoading.dismiss();
    }
  }

  Future<void> toggleFavoriteRiders(bool value) async {
    favoriteRiders.value = value;

    if (lastOrderId == null) {
      favoriteRiders.value = !value;
      EasyLoading.showError('Order not found');
      return;
    }

    EasyLoading.show(status: 'Updating...');

    final res = await NotifyRider.notifyFavoriteRider(
      orderId: lastOrderId.toString(),
      notifyRider: value,
    );

    EasyLoading.dismiss();

    final success = res['success'] ?? false;

    if (success) {
      final body = res['body'] as Map<String, dynamic>? ?? {};
      final data = body['data'] as Map<String, dynamic>? ?? {};

      favoriteRiders.value = data['notify_rider'] ?? value;

      EasyLoading.showSuccess(body['message'] ?? 'Updated successfully');
    } else {
      favoriteRiders.value = !value;
      EasyLoading.showError('Failed to update favourite rider');
    }
  }

  /// Place order by building payload from controllers, call POST endpoint,
  /// then GET the created order, debugPrint responses, update `totalAmount`
  /// and return true on success. Returns false on validation or server error.
  // int? lastOrderId;

  Future<bool> placeOrder({
    required StackedLocationController locationController,
    required StackedVehicleController vehicleController,
  }) async {
    // Validate required fields
    final vehicle = vehicleController.selectedVehicle.value;
    final sender = locationController.senderData.value;
    final receiver = locationController.receiverData.value;

    if (vehicle == null) {
      EasyLoading.showError('Please select a vehicle');
      return false;
    }

    if (sender == null) {
      EasyLoading.showError('Please select a pickup address');
      return false;
    }

    if (receiver == null) {
      EasyLoading.showError('Please select at least one recipient address');
      return false;
    }

    // Build destinations array - currently supports sender + one receiver
    final destinations = <Map<String, dynamic>>[];

    destinations.add({
      'address': sender.address,
      'floor_unit': sender.floorUnit,
      'contact_name': sender.contactName,
      'contact_number': sender.contactNumber,
      'note_to_driver': sender.noteToDriver,
      'is_saved': sender.isSaved,
      'type': 'SENDER',
    });

    // Add primary receiver - if you support more stops later, append here
    destinations.add({
      'address': receiver.address,
      'floor_unit': receiver.floorUnit,
      'contact_name': receiver.contactName,
      'contact_number': receiver.contactNumber,
      'note_to_driver': receiver.noteToDriver,
      'is_saved': receiver.isSaved,
      'type': 'RECEIVER',
    });

    // Collect time
    String collectTime = 'ASAP';
    String? scheduledTime;
    StackedScheduleController? schedCtrl;
    try {
      schedCtrl = Get.find<StackedScheduleController>();
    } catch (_) {
      schedCtrl = null;
    }

    if (schedCtrl != null && !schedCtrl.isNow.value) {
      scheduledTime = schedCtrl.selectedDateTime.value
          .toUtc()
          .toIso8601String();
      collectTime = 'SCHEDULED';
    }

    final payload = {
      'route_type': locationController.isRoundTrip.value ? 'ROUND' : 'ONE_WAY',
      'isFixed': isFixed.value,
      'delivery_type': 'STACKED',
      'vehicle_type_id': vehicle.id,
      'collect_time': collectTime, // sends either 'ASAP' or 'SCHEDULED'
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
    };

    debugPrint('Placing order payload: $payload');

    final res = await OrderService.createOrder(
      payload,
      deliveryType: 'STACKED',
    );

    // Debug print full response
    debugPrint('CreateOrder full response: ${res}');

    final status = res['statusCode'] as int? ?? 500;
    if (status == 201) {
      EasyLoading.showSuccess('Order created');
      final body = res['body'] as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? {};

      double serverTotal = _extractPreferredTotalCost(data);

      debugPrint('Server total_cost: $serverTotal');

      double serverFee = _extractPreferredTotalFee(data);

      debugPrint('Server total_fee: $serverFee');

      // If order id is present, fetch order details and store lastOrderId
      int? orderId;
      try {
        final orderMap = data['order'] as Map<String, dynamic>?;
        orderId = orderMap != null && orderMap['id'] != null
            ? (orderMap['id'] as int)
            : null;
      } catch (_) {
        orderId = null;
      }

      if (orderId != null) {
        // save for later 'place' call
        lastOrderId = orderId;
        final didRefresh = await _refreshOrderPricingFromGet(orderId);
        if (didRefresh) {
          serverTotal = totalAmount.value;
          serverFee = totalFee.value;
          print('📥 Order Details Fetched from GET API');
          print(
            '   - pricingSummary.totalCost: \$${serverTotal.toStringAsFixed(2)}',
          );
        }
      }

      // Update controller totals to server values and return success
      totalAmount.value = serverTotal;
      totalFee.value = serverFee;
      totalCost.value = serverTotal; // Store total_cost from API response

      print('\n╔════════════════════════════════════════════╗');
      print('║  📦 ORDER CREATED - TOTALS SET IN CONTROLLER');
      print('╠════════════════════════════════════════════╣');
      print('║  Order ID: $orderId');
      print('║  Total Cost: \$${totalCost.value.toStringAsFixed(2)}');
      print('║  Total Amount: \$${totalAmount.value.toStringAsFixed(2)}');
      print('║  Total Fee: \$${totalFee.value.toStringAsFixed(2)}');
      print('╚════════════════════════════════════════════╝\n');

      return true;
    } else {
      final msg =
          (res['body'] as Map<String, dynamic>?)?['message'] ??
          'Failed to create order';
      debugPrint('PlaceOrder failed: $msg');
      EasyLoading.showError(msg.toString());
      return false;
    }
  }

  /// After creating an order (lastOrderId must be present), finalize/place it.
  Future<bool> confirmPlaceOrder({
    required String paymentMethod, // COD | WALLET | ONLINE_PAY
    String? paymentMethodId,
    String? codCollectFrom, // SENDER | RECEIVER
  }) async {
    if (lastOrderId == null) {
      EasyLoading.showError('No order available to place');
      debugPrint('confirmPlaceOrder: lastOrderId is null');
      return false;
    }

    debugPrint(
      'Placing final order - Order ID: $lastOrderId, Payment Method: $paymentMethod, PaymentMethodId: $paymentMethodId, CodCollectFrom: $codCollectFrom',
    );

    final res = await OrderService.placeOrder(
      orderId: lastOrderId!,
      paymentMethod: paymentMethod,
      codCollectFrom: codCollectFrom,
      paymentMethodId: paymentMethodId,
    );

    debugPrint('Place order full response: $res');

    final status = res['statusCode'] as int? ?? 500;
    final bodyData = res['body'] as Map<String, dynamic>? ?? {};
    final success = bodyData['success'] as bool? ?? false;

    // Check both status code and success flag
    if (success && (status == 201 || status == 200)) {
      try {
        // Save full response for later use
        placeOrderResponse.value = bodyData;

        final data = bodyData['data'] as Map<String, dynamic>? ?? {};
        syncOrderData(data);

        await _refreshOrderPricingFromGet();

        // Extract order ID and update orderNumber
        final orderId = data['id'] as int? ?? lastOrderId;
        orderNumber.value = '#$orderId';

        // Extract is_auto_confirmation flag
        isAutoConfirmation.value =
            (data['is_auto_confirmation'] as bool?) ?? false;
        debugPrint('Is Auto Confirmation: ${isAutoConfirmation.value}');

        // Extract collect_time
        collectTime.value = (data['collect_time'] as String?) ?? 'ASAP';
        debugPrint('Collect Time: ${collectTime.value}');

        // Extract sender and receiver info from destinations
        final destinations = data['destinations'] as List<dynamic>? ?? [];
        for (var dest in destinations) {
          final destMap = dest as Map<String, dynamic>? ?? {};
          final type = destMap['type'] as String? ?? '';

          if (type == 'SENDER') {
            senderInfo.value = destMap;
            debugPrint('Sender Info: $destMap');
          } else if (type == 'RECEIVER') {
            receiverInfo.value = destMap;
            debugPrint('Receiver Info: $destMap');
          }
        }

        final serverTotal = totalAmount.value;
        final serverFee = totalFee.value;
        debugPrint(
          'Placed order total_cost: $serverTotal total_fee: $serverFee',
        );
        EasyLoading.showSuccess(
          'Order placed: S\$${serverTotal.toStringAsFixed(2)}',
        );
      } catch (e) {
        debugPrint('Error parsing placed order total: $e');
      }

      return true;
    } else {
      final msg = bodyData['message'] ?? 'Failed to place order';
      debugPrint(
        'confirmPlaceOrder failed: $msg (status: $status, success: $success)',
      );
      EasyLoading.showError(msg.toString());
      return false;
    }
  }

  /// Cancel and reset the flow back to a clean StackedScreen state
  void cancelAndReset() {
    try {
      final loc = Get.find<StackedLocationController>();
      loc.senderData.value = null;
      loc.receiverData.value = null;
      loc.selectedVehicle.value = null;
    } catch (_) {}

    try {
      final vc = Get.find<StackedVehicleController>();
      vc.selectedVehicle.value = null;
      vc.selectedServices.clear();
      vc.calculationHistory.clear();
    } catch (_) {}

    try {
      final sched = Get.find<StackedScheduleController>();
      sched.setNow(true);
    } catch (_) {}

    // reset payment selector if present
    try {
      final pay = Get.find<StackedPaymentController>();
      pay.selectedIndex.value = 1;
      pay.selectedTitle.value = 'Wallet';
    } catch (_) {}

    // reset controller state
    lastOrderId = null;
    orderNumber.value = '';
    placeOrderResponse.value = null;
    isAutoConfirmation.value = false;
    collectTime.value = 'ASAP';
    senderInfo.value = null;
    receiverInfo.value = null;
    deliveryType.value = '';
    deliveryTypeId.value = null;
    favoriteRiders.value = false;
    redeemCoins.value = false;
    userCoinBalance = 0;
    _hasRequestedInitialPricing = false;
    totalAmount.value = 0.0;
    totalFee.value = 0.0;
    totalCost.value = 0.0;
    pricingBasePrice.value = 0.0;
    pricingDeliveryTypeCharge.value = 0.0;
    pricingAdditionalServiceCost.value = 0.0;
    deliveryTypeMultiplier.value = 1.0;
    pricingVehicleName.value = '';
    promoCode.value = '';
    discountAmount.value = 0.0;
    promoDiscount.value = 0.0;
    originalCost.value = 0.0;
    coinsRedeemed.value = 0;
  }

  Future<void> applyPromoCode(String code) async {
    if (lastOrderId == null) {
      EasyLoading.showError('Order not created yet');
      return;
    }

    if (code.trim().isEmpty) {
      EasyLoading.showError('Enter promo code');
      return;
    }

    EasyLoading.show(status: 'Applying promo...');

    final res = await PromoService.applyPromo(
      orderId: lastOrderId!,
      promoCode: code.trim(),
    );

    EasyLoading.dismiss();

    final success = res['success'] as bool? ?? false;

    if (success) {
      final body = res['body'] as Map<String, dynamic>? ?? {};
      final data = body['data'] as Map<String, dynamic>? ?? {};

      _applyDiscountStateFromData(data, fallbackPromoCode: code.trim());
      await _refreshOrderPricingFromGet();

      debugPrint('✅ Promo Applied: $promoCode');
      debugPrint(
        '💰 Original: \$${originalCost.value}, Discount: \$${discountAmount.value}, Total: \$${totalAmount.value}',
      );
      debugPrint('🪙 Coins Redeemed: ${coinsRedeemed.value}');

      EasyLoading.showSuccess(body['message'] ?? 'Promo applied successfully!');
    } else {
      EasyLoading.showError(res['body']?['message'] ?? 'Failed to apply promo');
    }
  }

  /// Remove applied promo code and reset to original values
  Future<void> removePromoCode() async {
    if (lastOrderId == null) {
      EasyLoading.showError('Order not created yet');
      return;
    }

    if (promoCode.value.trim().isEmpty) {
      return;
    }

    if (isUpdatingDiscount.value) return;
    isUpdatingDiscount.value = true;

    EasyLoading.show(status: 'Removing promo...');

    try {
      final res = await PromoService.removeDiscount(
        orderId: lastOrderId!,
        type: 'promo',
      );

      final success = res['success'] as bool? ?? false;
      if (!success) {
        EasyLoading.showError(
          res['body']?['message'] ?? 'Failed to remove promo',
        );
        return;
      }

      promoCode.value = '';
      discountAmount.value = 0.0;
      promoDiscount.value = 0.0;
      originalCost.value = 0.0;
      await _refreshOrderPricingFromGet();

      EasyLoading.showSuccess(
        res['body']?['message'] ?? 'Promo removed successfully',
      );
      debugPrint('🗑️ Promo code removed from server');
    } catch (e) {
      debugPrint('❌ removePromoCode error: $e');
      EasyLoading.showError('Something went wrong');
    } finally {
      isUpdatingDiscount.value = false;
      EasyLoading.dismiss();
    }
  }

  /// Fetch and update order total cost from API after address saved
  Future<void> fetchOrderTotalCost() async {
    if (lastOrderId == null) {
      debugPrint('⚠️ Order ID is null, cannot fetch total cost');
      return;
    }

    if (isFetchingTotal.value) {
      debugPrint('⏳ Already fetching total, skipping duplicate request');
      return;
    }

    isFetchingTotal.value = true;
    final previousTotalCost = totalCost.value; // Save in case fetch fails
    final previousTotalAmount = totalAmount.value;

    try {
      debugPrint('\n🔄 FETCHING ORDER TOTAL FOR ORDER ID: $lastOrderId');

      final orderRes = await OrderConfirmationService.getOrder(
        lastOrderId ?? 0,
      );

      debugPrint('📡 API Response Status: ${orderRes['statusCode']}');
      debugPrint('📡 API Response Success: ${orderRes['success']}');

      final orderSuccess = orderRes['success'] as bool? ?? false;
      final orderStatus = orderRes['statusCode'] as int? ?? 500;

      if (!orderSuccess || (orderStatus != 200 && orderStatus != 201)) {
        debugPrint('❌ Failed to fetch order details: Status $orderStatus');
        debugPrint('❌ Response: ${orderRes['body']}');
        // Restore previous values if fetch failed
        totalCost.value = previousTotalCost;
        totalAmount.value = previousTotalAmount;
        return;
      }

      final orderData = orderRes['body'] as Map<String, dynamic>? ?? {};
      final orderActualData = orderData['data'] as Map<String, dynamic>? ?? {};

      debugPrint('📦 Order Data Keys: ${orderActualData.keys.toList()}');
      syncOrderData(orderActualData);
      debugPrint('✅ VALUES UPDATED');
      debugPrint('   totalAmount: \$${totalAmount.value.toStringAsFixed(2)}');
      debugPrint('   totalCost: \$${totalCost.value.toStringAsFixed(2)}');

      debugPrint(
        '════════════════════════════════════════════════════════════\n',
      );
    } catch (e, stack) {
      debugPrint('❌ Error fetching order total: $e');
      debugPrint('Stack: $stack');
      // Restore previous values on error
      totalCost.value = previousTotalCost;
      totalAmount.value = previousTotalAmount;
    } finally {
      isFetchingTotal.value = false;
    }
  }
}
