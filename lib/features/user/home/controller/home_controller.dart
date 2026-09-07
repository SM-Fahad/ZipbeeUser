import 'package:ZipBee/core/controllers/app_controller.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/home/controller/auth_controller.dart';
import 'package:ZipBee/features/user/home/controller/popup_controller.dart';
import 'package:ZipBee/features/user/home/controller/profile_controller.dart';
import 'package:ZipBee/features/user/wallet/loyalty_and_rewards/controller/loyalty_and_rewards_controller.dart';
import 'package:ZipBee/features/user/home/service/ads_service.dart';
import 'package:flutter/material.dart';
import 'package:ZipBee/features/user/home/model/delivery_type_model.dart';
import 'package:ZipBee/features/user/home/model/drawer_model.dart';
import 'package:ZipBee/features/user/home/model/order_response_model.dart';
import 'package:ZipBee/features/user/home/service/delivery_type_service.dart';
import 'package:ZipBee/features/user/home/service/notification_service.dart';
import 'package:ZipBee/features/user/google_map/widget/google_map_widget.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/service/order_service.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:ZipBee/features/user/stacked/stacked_controller/stacked_controller.dart';
import 'package:ZipBee/features/user/stacked/widget/pic_date_time.dart';
import 'package:ZipBee/features/user/stacked/stacked_controller/update_details_controller.dart';
import 'package:ZipBee/features/user/vehicle_type/controller/controller.dart';
import 'package:ZipBee/features/user/vehicle_type/controller/additional_controller.dart';
import 'package:ZipBee/features/user/stacked/schedule_stacked_ delivey/Schedule_sender_recepent/controller/sender_schedule_controller.dart';
import 'package:ZipBee/features/user/stacked/schedule_stacked_%20delivey/Schedule_recepent/controller/recepent_controller.dart';
import 'package:ZipBee/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  final profileCtrl = Get.put(UserProfileController());
  final popupCtrl = Get.put(PopupController());
  final authCtrl = Get.put(AuthController());

  // Ads and balance states
  final ads = <Map<String, dynamic>>[].obs;
  final isAdsLoading = true.obs;
  bool _isBalanceRefreshRunning = false;

  // UI States
  final deliveryType = ''.obs;
  final selectedVehicleId = RxnString();
  var drawerItem = <DrawerModel>[].obs;

  // Delivery types
  final deliveryTypes = <DeliveryTypeModel>[].obs;
  final isDeliveryLoading = false.obs;
  final unreadNotificationCount = 0.obs;

  @override
  void onInit() {
    WidgetsBinding.instance.addObserver(this);
    _loadAds();
    _initDrawer();
    _listenToProfileChanges();
    _warmUpScheduleMap();
    fetchDeliveryTypes();
    fetchUnreadNotificationCount();
    super.onInit();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshBalanceAndCoin();
    }
  }

  Future<void> refreshBalanceAndCoin() async {
    if (_isBalanceRefreshRunning) return;

    _isBalanceRefreshRunning = true;
    try {
      final loyaltyCtrl = Get.put(LoyaltyAndRewardsController());
      await Future.wait([
        profileCtrl.fetchUserProfile(),
        loyaltyCtrl.loadUserCoin(),
      ]);
    } catch (e) {
      debugPrint('Error refreshing balance: $e');
    } finally {
      _isBalanceRefreshRunning = false;
    }
  }

  bool _isRouteListenerRegistered = false;

  void registerRouteListener(BuildContext context) {
    if (_isRouteListenerRegistered) return;

    final route = ModalRoute.of(context);
    if (route != null) {
      _isRouteListenerRegistered = true;
      route.secondaryAnimation?.addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          debugPrint("HomeController: Popped back to this screen! Refreshing...");
          refreshBalanceAndCoin();
        }
      });
    }
  }

  Future<void> _loadAds({bool showLoader = true}) async {
    if (showLoader) {
      isAdsLoading.value = true;
    }

    try {
      final adsList = await AdsService.fetchAds();
      ads.assignAll(adsList);
    } catch (_) {
      ads.clear();
    } finally {
      isAdsLoading.value = false;
    }
  }

  Future<void> handleRefresh() async {
    await Future.wait([
      refreshBalanceAndCoin(),
      fetchDeliveryTypes(showLoader: false),
      fetchUnreadNotificationCount(),
      _loadAds(showLoader: false),
    ]);
  }

  void _warmUpScheduleMap() {
    GoogleMapWidget.warmUp(enablePickupSync: false);
  }

  void _listenToProfileChanges() {
    final appController = Get.find<AppController>();
    ever(
      appController.appRebuildTrigger,
      (_) => profileCtrl.fetchUserProfile(),
    );
  }

  // Create order method
  final isLoading = false.obs;
  final currentOrderId = RxnInt();

  void resetHomeSelection() {
    deliveryType.value = '';
    selectedVehicleId.value = null;
    currentOrderId.value = null;
  }

  void selectDeliveryType(DeliveryTypeModel selectedType) async {
    deliveryType.value = selectedType.name.toLowerCase();
    await _createOrderApi(selectedType.id);
  }

  void _clearPreviousStackedSession() {
    if (Get.isRegistered<StackedOrderController>()) {
      Get.find<StackedOrderController>().cancelAndReset();
      Get.delete<StackedOrderController>(force: true);
    }

    if (Get.isRegistered<StackedLocationController>()) {
      Get.delete<StackedLocationController>(force: true);
    }
    if (Get.isRegistered<StackedVehicleController>()) {
      Get.delete<StackedVehicleController>(force: true);
    }
    if (Get.isRegistered<StackedScheduleController>()) {
      Get.delete<StackedScheduleController>(force: true);
    }
    if (Get.isRegistered<UpdateDetailsController>()) {
      Get.delete<UpdateDetailsController>(force: true);
    }
    if (Get.isRegistered<AdditionalServiceController>()) {
      Get.delete<AdditionalServiceController>(force: true);
    }
    if (Get.isRegistered<SenderScheduleController>()) {
      Get.delete<SenderScheduleController>(force: true);
    }
    if (Get.isRegistered<RecipientController>(tag: 'primary')) {
      Get.delete<RecipientController>(tag: 'primary', force: true);
    }
    if (Get.isRegistered<RecipientController>(tag: 'additional_stop')) {
      Get.delete<RecipientController>(tag: 'additional_stop', force: true);
    }
  }

  Future<void> _createOrderApi(int deliveryTypeId) async {
    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Processing...');

      final response = await OrderService.createOrder({
        "route_type": "ONE_WAY",
        "isFixed": false,
        "delivery_type_id": deliveryTypeId,
        "collect_time": "ASAP",
      }, deliveryType: deliveryType.value);

      if (response['statusCode'] == 201 || response['statusCode'] == 200) {
        final orderResponse = OrderResponseModel.fromJson(response['body']);
        if (orderResponse.success == true) {
          currentOrderId.value = orderResponse.data?.id;
          final resolvedDeliveryType =
              orderResponse.data?.deliveryType?.toLowerCase() ??
                  deliveryType.value;
          _clearPreviousStackedSession();
          EasyLoading.dismiss();

          await Get.toNamed(
            AppRoutes.stackedScreen,
            arguments: {
              'orderId': currentOrderId.value,
              'deliveryType': resolvedDeliveryType,
              'deliveryTypeId': deliveryTypeId,
              'order': orderResponse.data?.rawJson,
            },
          );

          resetHomeSelection();
        } else {
          EasyLoading.showError(
            orderResponse.message ?? "Could not create order",
          );
        }
      } else {
        EasyLoading.showError("Server Error ${response['statusCode']}");
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('Error creating order: $e');
      EasyLoading.showError("Something went wrong. $e");
    } finally {
      EasyLoading.dismiss();
      isLoading.value = false;
    }
  }

  // Fetch delivery types
  Future<void> fetchDeliveryTypes({bool showLoader = true}) async {
    try {
      if (showLoader) {
        isDeliveryLoading.value = true;
      }
      final response = await DeliveryTypeService.getDeliveryTypes();

      if (response['statusCode'] == 200 && response['body'] != null) {
        final List rawData = response['body']['data']['data'];
        deliveryTypes.assignAll(
          rawData.map((json) => DeliveryTypeModel.fromJson(json)).toList(),
        );
      }
    } finally {
      if (showLoader) {
        isDeliveryLoading.value = false;
      }
    }
  }

  Future<void> fetchUnreadNotificationCount() async {
    final response = await NotificationService.getUnreadCount();
    if (response['statusCode'] == 200 && response['body'] != null) {
      final data = response['body']['data'];
      final count = data is Map<String, dynamic> ? data['count'] : 0;
      unreadNotificationCount.value = count is int ? count : 0;
    }
  }

  void _initDrawer() {
    drawerItem.addAll([
      DrawerModel(
        iconUrl: IconPath.notificationIcon2,
        iconname: "Notifications",
        ontap: () async {
          await Get.toNamed(AppRoutes.getUserNotification());
          await fetchUnreadNotificationCount();
        },
      ),
      DrawerModel(
        iconUrl: IconPath.savedIcon,
        iconname: "Saved Places",
        ontap: () async {
          await Get.toNamed(AppRoutes.savedPlaces);
        },
      ),
      DrawerModel(
        iconUrl: IconPath.walletIcon,
        iconname: "My Wallet",
        ontap: () async {
          await Get.toNamed(AppRoutes.myWalletUser);
          await refreshBalanceAndCoin();
        },
      ),
      DrawerModel(
        iconUrl: IconPath.referIcon,
        iconname: "Refer & Earn",
        ontap: () async {
          await Get.toNamed(AppRoutes.getreferAndEarnScreen());
        },
      ),
      DrawerModel(
        iconUrl: IconPath.ridersicon,
        iconname: "My Riders",
        ontap: () async {
          await Get.toNamed(AppRoutes.myRidersScreen);
        },
      ),
      DrawerModel(
        iconUrl: IconPath.supportIcon,
        iconname: "Support",
        ontap: () async {
          await Get.toNamed(AppRoutes.supportScreen);
        },
      ),
      DrawerModel(
        iconUrl: IconPath.logOutIcon,
        iconname: "Logout",
        ontap: () => authCtrl.showLogoutDialog(),
      ),
    ]);
  }
}
