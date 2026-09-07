// Unused File: lib/features/user/express_delivery_1/controller/express_controller_1.dart
import 'dart:convert';

import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/express_delivery_1/order_express_delivery/screen/order_alertdialog_screen.dart';
import 'package:ZipBee/features/user/express_delivery_1/service/order_api_service.dart';
import 'package:ZipBee/features/user/finding_raider/controller/rider_controller.dart';
import 'package:ZipBee/features/user/home/controller/home_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

/// ─────────────────────────
/// Vehicle Model
/// ─────────────────────────
class VehicleModel {
  final String iconPath;
  VehicleModel(this.iconPath);
}

class ExpressDeliveryMain extends GetxController {
  final RiderController riderController = Get.find<RiderController>();

  // ─────────────────────────
  // Map Vehicle to ID
  // ─────────────────────────
  int _mapVehicleToId(VehicleModel? vehicle) {
    if (vehicle == null) return 1;

    switch (vehicle.iconPath) {
      case "assets/icons/bike.png":
        return 1;
      case "assets/icons/car.png":
        return 2;
      case "assets/icons/shop_car.png":
        return 3;
      case "assets/icons/shipment.png":
        return 4;
      default:
        return 1;
    }
  }

  final HomeController homeCtrl = Get.find<HomeController>();

  // ─────────────────────────
  // Trip & Time State
  // ─────────────────────────
  final RxBool isRoundTrip = false.obs;
  final RxBool isNowSelected = true.obs;
  final Rxn<DateTime> scheduledDateTime = Rxn<DateTime>();

  // ─────────────────────────
  // UI Editing State
  // ─────────────────────────
  final RxBool isEditing = false.obs;
  final RxString title = 'Collected from (Sender: Athena Lin)'.obs;

  // ─────────────────────────
  // Sender & Receiver Info
  // ─────────────────────────
  final RxString senderName = ''.obs;
  final RxString senderAddress = ''.obs;
  final RxString receiverName = ''.obs;
  final RxString receiverAddress = ''.obs;

  // ─────────────────────────
  // Vehicle State
  // ─────────────────────────
  final RxList<VehicleModel> vehicleList = <VehicleModel>[].obs;
  final Rxn<VehicleModel> selectedVehicle = Rxn<VehicleModel>();

  // ─────────────────────────
  // Additional State
  // ─────────────────────────
  final RxString orderNumber = '#1233'.obs;
  final RxBool isDriverAssigned = false.obs;
  final RxInt countdown = 10.obs;
  final RxBool redeemCoins = false.obs;
  final RxBool favoriteRiders = false.obs;
  final Rx<double> totalAmount = 0.0.obs;
  final Rx<double> discountAmount = 0.0.obs;
  final RxBool isLoading = false.obs;

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 90,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
  );

  @override
  void onInit() {
    super.onInit();
    loadVehicleData();
  }

  // ─────────────────────────
  // Vehicle Logic
  // ─────────────────────────
  void loadVehicleData() {
    vehicleList.assignAll([
      VehicleModel(IconPath.bike2),
      VehicleModel(IconPath.car2),
      VehicleModel(IconPath.shopcar),
      VehicleModel(IconPath.shipment),
    ]);
  }

  void selectVehicle(VehicleModel vehicle) {
    selectedVehicle.value = vehicle;
  }

  // ─────────────────────────
  // Trip Type
  // ─────────────────────────
  void toggleTripType(bool isRound) {
    isRoundTrip.value = isRound;
  }

  // ─────────────────────────
  // Schedule / Now Logic
  // ─────────────────────────
  void selectNow() {
    isNowSelected.value = true;
    scheduledDateTime.value = null;
  }

  void selectSchedule([DateTime? time]) {
    isNowSelected.value = false;
    if (time != null) {
      scheduledDateTime.value = time;
    }
  }

  String get formattedScheduledDateTime {
    if (scheduledDateTime.value == null) {
      return 'Pick Date and Time';
    }
    return DateFormat('EEE, dd MMM, hh:mm a').format(scheduledDateTime.value!);
  }

  // ─────────────────────────
  // Sender / Receiver Setter
  // ─────────────────────────
  void setSender({required String name, required String address}) {
    senderName.value = name;
    senderAddress.value = address;
  }

  void setReceiver({required String name, required String address}) {
    receiverName.value = name;
    receiverAddress.value = address;
  }

  // ─────────────────────────
  // Optional Title Update
  // ─────────────────────────
  void updateTitle(String newTitle) {
    title.value = newTitle;
  }

  // ─────────────────────────
  // Toggle Methods
  // ─────────────────────────
  /// Allow toggle off->on, but prevent on->off
  void toggleRedeemCoins(bool value) {
    if (redeemCoins.value && !value) {
      // Prevent turning off
      redeemCoins.value = true;
      return;
    }
    redeemCoins.value = value;
  }

  /// Allow toggle off->on, but prevent on->off
  void toggleFavoriteRiders(bool value) {
    if (favoriteRiders.value && !value) {
      // Prevent turning off
      favoriteRiders.value = true;
      return;
    }
    favoriteRiders.value = value;
  }

  // ─────────────────────────
  // API: Apply Discount (Promo Code)
  // ─────────────────────────
  Future<void> applyPromoCode({
    required int orderId,
    required String promoCode,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        _logger.e("Access token missing");
        Get.snackbar("Error", "Please login again");
        return;
      }

      final body = {"promoCode": promoCode};

      final response = await OrderService.applyDiscountApi(
        orderId: orderId,
        body: body,
        token: token,
      );

      final decoded = jsonDecode(response.body);
      _logger.i("📌 PROMO CODE RESPONSE → ${response.statusCode}");
      _logger.d("📝 DATA → ${jsonEncode(decoded)}");

      if (decoded['success'] != true) {
        Get.snackbar(
          "Error",
          decoded['message'] ?? "Failed to apply promo code",
        );
        return;
      }

      // Update UI with response data
      if (decoded['data'] != null) {
        final data = decoded['data'];
        totalAmount.value =
            double.tryParse(data['total_cost']?.toString() ?? '0') ?? 0.0;
      }

      Get.snackbar("Success", "Promo code applied successfully");
    } catch (e, s) {
      _logger.f("Promo Code Exception", error: e, stackTrace: s);
      Get.snackbar("Error", "Something went wrong");
    }
  }

  // ─────────────────────────
  // API: Redeem Coins
  // ─────────────────────────
  Future<void> redeemCoinsApi({
    required int orderId,
    required int coinsAmount,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        _logger.e("Access token missing");
        redeemCoins.value = false;
        Get.snackbar("Error", "Please login again");
        return;
      }

      final body = {"useCoins": true, "coinsAmount": coinsAmount};

      final response = await OrderService.applyDiscountApi(
        orderId: orderId,
        body: body,
        token: token,
      );

      final decoded = jsonDecode(response.body);
      _logger.i("🪙 REDEEM COINS RESPONSE → ${response.statusCode}");
      _logger.d("📝 DATA → ${jsonEncode(decoded)}");

      if (decoded['success'] != true) {
        redeemCoins.value = false;
        Get.snackbar("Error", decoded['message'] ?? "Failed to redeem coins");
        return;
      }

      // Update UI with response data
      if (decoded['data'] != null) {
        final data = decoded['data'];
        totalAmount.value =
            double.tryParse(data['total_cost']?.toString() ?? '0') ?? 0.0;
      }

      redeemCoins.value = true;
      Get.snackbar("Success", "Coins redeemed successfully");
    } catch (e, s) {
      _logger.f("Redeem Coins Exception", error: e, stackTrace: s);
      redeemCoins.value = false;
      Get.snackbar("Error", "Something went wrong");
    }
  }

  // ─────────────────────────
  // API: Follow Favorite Rider
  // ─────────────────────────
  Future<void> followFavoriteRider({required int orderId}) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        _logger.e("Access token missing");
        favoriteRiders.value = false;
        Get.snackbar("Error", "Please login again");
        return;
      }

      final response = await OrderService.followRiderApi(
        orderId: orderId,
        token: token,
      );

      final decoded = jsonDecode(response.body);
      _logger.i("👥 FAVORITE RIDER RESPONSE → ${response.statusCode}");
      _logger.d("📝 DATA → ${jsonEncode(decoded)}");

      if (decoded['success'] != true) {
        favoriteRiders.value = false;
        Get.snackbar(
          "Error",
          decoded['message'] ?? "Failed to set favorite rider",
        );
        return;
      }

      favoriteRiders.value = true;
      Get.snackbar("Success", "Favorite rider set successfully");
    } catch (e, s) {
      _logger.f("Favorite Rider Exception", error: e, stackTrace: s);
      favoriteRiders.value = false;
      Get.snackbar("Error", "Something went wrong");
    }
  }

  // ─────────────────────────
  // API: Notify Rider
  // ─────────────────────────
  Future<void> notifyRider({
    required int orderId,
    required bool notifyRider,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        _logger.e("Access token missing");
        Get.snackbar("Error", "Please login again");
        return;
      }

      final body = {"notify_rider": notifyRider};

      final response = await OrderService.notifyRiderApi(
        orderId: orderId,
        body: body,
        token: token,
      );

      final decoded = jsonDecode(response.body);
      _logger.i("🔔 NOTIFY RIDER RESPONSE → ${response.statusCode}");
      _logger.d("📝 DATA → ${jsonEncode(decoded)}");

      if (decoded['success'] != true) {
        Get.snackbar("Error", decoded['message'] ?? "Failed to notify rider");
        return;
      }

      Get.snackbar("Success", "Rider notification sent");
    } catch (e, s) {
      _logger.f("Notify Rider Exception", error: e, stackTrace: s);
      Get.snackbar("Error", "Something went wrong");
    }
  }

  // ─────────────────────────
  // Create Order
  // ─────────────────────────
  Future<void> createOrder() async {
    if (totalAmount.value <= 0) {
      _logger.w("Order blocked: totalAmount is 0");
      return;
    }

    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        _logger.e("Access token missing or expired");
        Get.snackbar("Session Expired", "Please login again");
        return;
      }

      final body = {
        "route_type": isRoundTrip.value ? "ROUND" : "ONE_WAY",
        "delivery_type": homeCtrl.deliveryType.value.toUpperCase(),
        "collect_time": isNowSelected.value ? "ASAP" : "SCHEDULED",
        "vehicle_type_id": _mapVehicleToId(selectedVehicle.value),
        "destinations": [
          {"type": "SENDER", "address": senderAddress.value},
          {"type": "RECEIVER", "address": receiverAddress.value},
        ],
        if (!isNowSelected.value && scheduledDateTime.value != null)
          "scheduled_time": scheduledDateTime.value!.toIso8601String(),
      };

      _logger.i("📡 CREATE ORDER BODY");
      _logger.d(body);

      final response = await OrderService.createOrderApi(
        body: body,
        token: token,
      );

      _logger.i("🔹 STATUS → ${response.statusCode}");
      _logger.d("📝 RESPONSE → ${response.body}");

      final decoded = jsonDecode(response.body);

      ///  Backend says failed
      if (decoded['success'] != true) {
        final msg = decoded['message']?.toString() ?? "Order failed";
        _logger.e("Create order failed → $msg");
        Get.snackbar("Error", msg);
        return;
      }

      /// SUCCESS → extract order safely
      final Map<String, dynamic>? order =
          decoded['data']?['order'] ?? decoded['data'];

      if (order == null || order['id'] == null) {
        _logger.e("Order ID missing in response");
        Get.snackbar("Error", "Order created but ID missing");
        return;
      }

      final int newOrderId = order['id'];

      /// ✅ THIS IS NOW SAFE
      riderController.orderId.value = newOrderId;

      print("✅ ORDER ID SET → ${riderController.orderId.value}");

      /// optional confirmation dialog
      OrderConfirmationSheet.show(newOrderId);
    } catch (e, s) {
      _logger.f("Create Order Exception", error: e, stackTrace: s);
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }
}
