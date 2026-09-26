import 'dart:convert';
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:ZipBee/core/service/app_http_client.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import '../model/order_model.dart';

class OrderController extends GetxController {
  final RxInt selectOrderListIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isDetailLoading = false.obs;
  final RxBool isFavoriteUpdating = false.obs;

  final orderTabs = ["Pending", "Active", "Completed", "Cancelled", "Expired"];
  final RxList<OrderModel> orderList = <OrderModel>[].obs;
  final Rxn<OrderModel> singleOrder = Rxn<OrderModel>();

  get totalAmount => null;
  get favoriteRiders => null;
  get orderNumber => null;

  final RxBool redeemCoins = false.obs;
  void toggleRedeemCoins(bool? value) => redeemCoins.value = value ?? false;

  final RxBool toggleFavoriteRiders = false.obs;

  int page = 1;
  final int limit = 20;
  String senderName = "";

  String get selectedStatus {
    switch (selectOrderListIndex.value) {
      case 0:
        return "PENDING";
      case 1:
        return "ONGOING";
      case 2:
        return "COMPLETED";
      case 3:
        return "CANCELLED";
      case 4:
        return "EXPIRED";
      default:
        return "PENDING";
    }
  }

  final RxBool allLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchOrders(isRefresh: true);
  }

  Future<void> fetchProfile() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final response = await AppHttpClient.get(
        Uri.parse(ApiEndPoint.profile),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        senderName = data['username'] ?? "";

        if (data['raiderProfile'] != null &&
            data['raiderProfile']['registrations'] != null &&
            (data['raiderProfile']['registrations'] as List).isNotEmpty) {
          final reg = data['raiderProfile']['registrations'][0];
          senderName = reg['raider_name'] ?? senderName;
        }
      }
    } catch (e) {
      debugPrint("Profile error: $e");
    }
  }

  Future<void> fetchOrders({bool isRefresh = false}) async {
    if (isLoading.value) return;
    if (isRefresh) {
      page = 1;
      orderList.clear();
      allLoaded.value = false;
    }
    isLoading.value = true;
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final uri = Uri.parse(
        "${ApiEndPoint.order}?status=$selectedStatus&page=$page&limit=$limit",
      );
      final response = await AppHttpClient.get(
        uri,
        headers: {"Authorization": "Bearer $token", "accept": "*/*"},
      );
      debugPrint("order controller url: $uri");
      debugPrint("order controller response: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List list = decoded['data']['data'];
        if (list.isEmpty) allLoaded.value = true;

        for (var e in list) {
          final List stops = e['orderStops'] ?? [];
          final pickup = stops.firstWhere(
            (s) => s['type'] == 'PICKUP',
            orElse: () => {},
          );
          final drops = stops.where((s) => s['type'] == 'DROP').toList();

          e['pickup_address'] = pickup['address'] ?? "";
          e['pickup_lat'] = pickup['latitude'];
          e['pickup_long'] = pickup['longitude'];
          e['sender_name'] = senderName;

          if (drops.isNotEmpty) {
            e['drop_off_address'] = drops.first['address'] ?? "";
            e['drop_off_lat'] = drops.first['latitude'];
            e['drop_off_long'] = drops.first['longitude'];
          }
          e['delivery_location'] =
              drops.length > 1 ? drops.last['address'] : "";
          orderList.add(OrderModel.fromJson(e));
        }
        page++;
      }
    } catch (e) {
      debugPrint("Orders error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchOrderDetail(
    String orderIdParam, {
    bool showLoader = true,
  }) async {
    if (showLoader) isDetailLoading.value = true;
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = ApiEndPoint.getOrder.replaceAll("{orderId}", orderIdParam);

      final response = await AppHttpClient.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];

        /// ✅ ADD THIS (Order ID)
        final int orderId = data['id'] is int
            ? data['id']
            : int.tryParse(data['id'].toString()) ?? 0;

        debugPrint("Order ID: $orderId");

        final List stops = data['orderStops'] ?? [];

        final pickup = stops.firstWhere(
          (s) => s['type'] == 'PICKUP',
          orElse: () => {},
        );
        final drops = stops.where((s) => s['type'] == 'DROP').toList();

        data['pickup_address'] = pickup['address'] ?? "";
        data['pickup_lat'] = pickup['latitude'];
        data['pickup_long'] = pickup['longitude'];
        data['sender_name'] = data['user']?['username'] ?? senderName;

        if (drops.isNotEmpty) {
          data['drop_off_address'] = drops.first['address'] ?? "";
          data['drop_off_lat'] = drops.first['latitude'];
          data['drop_off_long'] = drops.first['longitude'];
          data['recipient_name'] =
              drops.first['destination']?['contact_name'] ?? "";
        }

        singleOrder.value = OrderModel.fromJson(data);

        /// ✅ If you want to use extracted orderId
        // await someFunction(orderId);

        if (data['assign_rider']?['userId'] != null) {
          await fetchRiderInfoByIdForSingle(data['assign_rider']['userId']);
        } else if (singleOrder.value?.riderId != null) {
          await fetchRiderInfoByIdForSingle(singleOrder.value!.riderId!);
        }
      }
    } catch (e) {
      debugPrint("fetchOrderDetail error: $e");
    } finally {
      if (showLoader) isDetailLoading.value = false;
    }
  }

  Future<void> toggleSavedRiderFavorite(OrderModel order) async {
    final riderPhone = order.assignRiderPhone.trim();
    if (riderPhone.isEmpty) {
      Get.snackbar("Unable to update", "Rider phone number not found");
      return;
    }

    if (isFavoriteUpdating.value) return;

    isFavoriteUpdating.value = true;
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        Get.snackbar("Unable to update", "Please login again");
        return;
      }

      final bool shouldFavorite = !order.isSavedRiderFavorite;
      final Map<String, dynamic> body = {
        "find_by": riderPhone,
        "is_fav": shouldFavorite,
      };

      final http.Response response;
      if (order.savedRiderId == null) {
        response = await AppHttpClient.post(
          Uri.parse(ApiEndPoint.addRaider),
          headers: {
            "accept": "*/*",
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode(body),
        );
      } else {
        response = await AppHttpClient.patch(
          Uri.parse("${ApiEndPoint.addRaider}/${order.savedRiderId}"),
          headers: {
            "accept": "*/*",
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode(body),
        );
      }

      final decoded = jsonDecode(response.body);
      final success =
          (response.statusCode == 200 || response.statusCode == 201) &&
              decoded is Map<String, dynamic> &&
              decoded['success'] == true;

      if (!success) {
        final message = decoded is Map<String, dynamic>
            ? decoded['message']?.toString()
            : null;
        Get.snackbar("Unable to update", message ?? "Please try again");
        return;
      }

      final data = decoded['data'];
      final dataMap = data is Map<String, dynamic> ? data : null;
      final int? savedRiderId = dataMap?['id'] is int
          ? dataMap!['id']
          : int.tryParse(dataMap?['id']?.toString() ?? '');

      singleOrder.value = (singleOrder.value ?? order).copyWith(
        savedRiderId: savedRiderId ?? order.savedRiderId,
        isSavedRiderFavorite: shouldFavorite,
      );

      if (order.savedRiderId == null && savedRiderId == null) {
        await fetchOrderDetail(order.orderId, showLoader: false);
      }
    } catch (e) {
      debugPrint("toggleSavedRiderFavorite error: $e");
      Get.snackbar("Unable to update", "Network error or server issue");
    } finally {
      isFavoriteUpdating.value = false;
    }
  }

  String displayValue(String? value, {String fallback = 'Not added'}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') {
      return fallback;
    }
    return trimmed;
  }

  String collectionValue(OrderModel? order) {
    if (order == null) return 'Not added';

    if (order.collectTime == 'ASAP') {
      return 'ASAP';
    }

    if (order.collectTime == 'SCHEDULED') {
      return 'Scheduled';
    }

    return displayValue(order.collectTime);
  }

  List<Map<String, dynamic>> getOrderedRouteStops(OrderModel? order) {
    if (order == null) return [];

    final List<Map<String, dynamic>> stops = [];
    if (order.rawOrderStops != null && order.rawOrderStops!.isNotEmpty) {
      for (var i = 0; i < order.rawOrderStops!.length; i++) {
        final item = order.rawOrderStops![i];
        if (item is! Map) continue;

        final stop = Map<String, dynamic>.from(item);
        final latitude = double.tryParse(stop['latitude']?.toString() ?? '');
        final longitude = double.tryParse(stop['longitude']?.toString() ?? '');
        if (latitude == null || longitude == null) continue;

        final dynamic rawSequence = stop['sequence'] ?? stop['sort_order'];
        final int sequence = rawSequence is int
            ? rawSequence
            : int.tryParse(rawSequence?.toString() ?? '') ?? i;

        stops.add({
          'type': (stop['type'] ?? '').toString(),
          'name': displayValue(stop['destination']?['contact_name']?.toString()),
          'address': displayValue(stop['address']?.toString()),
          'latitude': latitude,
          'longitude': longitude,
          'sequence': sequence,
        });
      }
    }

    if (stops.isEmpty) {
      if (order.pickupLat != null && order.pickupLong != null) {
        stops.add({
          'type': 'PICKUP',
          'name': displayValue(order.senderName),
          'address': displayValue(order.pickupAddress),
          'latitude': order.pickupLat!,
          'longitude': order.pickupLong!,
          'sequence': 0,
        });
      }
      if (order.dropOffLat != null && order.dropOffLong != null) {
        stops.add({
          'type': 'DROP',
          'name': displayValue(order.recipientName),
          'address': displayValue(order.dropOffAddress),
          'latitude': order.dropOffLat!,
          'longitude': order.dropOffLong!,
          'sequence': 1,
        });
      }
    }

    final pickups = stops.where((stop) => stop['type'] == 'PICKUP').toList()
      ..sort((a, b) => (a['sequence'] as int).compareTo(b['sequence'] as int));
    final drops = stops.where((stop) => stop['type'] != 'PICKUP').toList()
      ..sort((a, b) => (a['sequence'] as int).compareTo(b['sequence'] as int));
    return [...pickups, ...drops];
  }

  // ✅ Corrected method to handle multiple pickup stops
  List<Map<String, String>> getPickupStops(OrderModel? order) {
    if (order == null || order.rawOrderStops == null) return [];

    final List stops = order.rawOrderStops!;
    final filtered = stops.where((s) => s['type'] == 'PICKUP').toList();

    if (filtered.isEmpty) {
      return [
        {
          "name": displayValue(order.senderName),
          "address": displayValue(order.pickupAddress),
        },
      ];
    }

    return filtered
        .map<Map<String, String>>(
          (s) => {
            "name": displayValue(
              s['destination']?['contact_name']?.toString() ?? order.senderName,
            ),
            "address": displayValue(
              s['address']?.toString() ?? order.pickupAddress,
            ),
          },
        )
        .toList();
  }

  // ✅ Corrected method to handle multiple drop stops
  List<Map<String, String>> getDropStops(OrderModel? order) {
    if (order == null || order.rawOrderStops == null) return [];

    final List stops = order.rawOrderStops!;
    final filtered = stops.where((s) => s['type'] == 'DROP').toList();

    if (filtered.isEmpty) {
      return [
        {
          "name": displayValue(order.recipientName),
          "address": displayValue(order.dropOffAddress),
        },
      ];
    }

    return filtered
        .map<Map<String, String>>(
          (s) => {
            "name": displayValue(
              s['destination']?['contact_name']?.toString() ??
                  order.recipientName,
            ),
            "address": displayValue(
              s['address']?.toString() ?? order.dropOffAddress,
            ),
          },
        )
        .toList();
  }

  /// ✅ Get count of drop stops
  int getDropStopsCount(OrderModel? order) {
    if (order == null || order.rawOrderStops == null) return 0;
    final List stops = order.rawOrderStops!;
    return stops.where((s) => s['type'] == 'DROP').length;
  }

  Future<void> fetchRiderInfoByIdForSingle(int riderUserId) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = ApiEndPoint.updateProfile.replaceAll(
        "{id}",
        riderUserId.toString(),
      );
      final response = await AppHttpClient.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        String riderName = "";
        String riderImage = "";
        String riderPhone = (data['phone'] ?? '').toString();

        if (data['raiderProfile']?['registrations'] != null &&
            (data['raiderProfile']['registrations'] as List).isNotEmpty) {
          final reg = data['raiderProfile']['registrations'][0];
          riderName = reg['raider_name'] ?? "";
          riderPhone = (reg['contact_number'] ?? riderPhone).toString();
          final driverPhotos = (reg['driver_photos'] as List<dynamic>? ?? [])
              .map((photo) => photo.toString())
              .where((photo) => photo.isNotEmpty)
              .toList();
          if (driverPhotos.isNotEmpty) {
            riderImage = driverPhotos.last;
          }
        }

        if (riderImage.isEmpty) {
          riderImage = (data['image'] ?? '').toString();
        }

        if (singleOrder.value != null) {
          final existingPhone = singleOrder.value!.assignRiderPhone.trim();
          singleOrder.value = singleOrder.value!.copyWith(
            assignRiderName: singleOrder.value!.assignRiderName.isNotEmpty
                ? singleOrder.value!.assignRiderName
                : riderName,
            assignRiderPhone:
                existingPhone.isNotEmpty ? existingPhone : riderPhone,
            assignRiderImage: riderImage.isNotEmpty
                ? riderImage
                : singleOrder.value!.assignRiderImage,
            assignRiderRating:
                double.tryParse(data['avg_raiderRating']?.toString() ?? '0') ??
                    0.0,
            assignRiderReviews: data['total_raiderRatings'] ?? 0,
          );
        }
      }
    } catch (e) {
      debugPrint("fetchRiderInfoByIdForSingle error: $e");
    }
  }

  Future<void> fetchRiderInfoById(int riderUserId) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = ApiEndPoint.updateProfile.replaceAll(
        "{id}",
        riderUserId.toString(),
      );
      final response = await AppHttpClient.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        String riderName = "";
        String riderImage = "";
        String riderPhone = (data['phone'] ?? '').toString();

        if (data['raiderProfile']?['registrations'] != null &&
            (data['raiderProfile']['registrations'] as List).isNotEmpty) {
          final reg = data['raiderProfile']['registrations'][0];
          riderName = reg['raider_name'] ?? "";
          riderPhone = (reg['contact_number'] ?? riderPhone).toString();
          final driverPhotos = (reg['driver_photos'] as List<dynamic>? ?? [])
              .map((photo) => photo.toString())
              .where((photo) => photo.isNotEmpty)
              .toList();
          if (driverPhotos.isNotEmpty) {
            riderImage = driverPhotos.last;
          }
        }

        if (riderImage.isEmpty) {
          riderImage = (data['image'] ?? '').toString();
        }

        for (int i = 0; i < orderList.length; i++) {
          if (orderList[i].riderId == riderUserId) {
            final existingPhone = orderList[i].assignRiderPhone.trim();
            orderList[i] = orderList[i].copyWith(
              assignRiderName: orderList[i].assignRiderName.isNotEmpty
                  ? orderList[i].assignRiderName
                  : riderName,
              assignRiderPhone:
                  existingPhone.isNotEmpty ? existingPhone : riderPhone,
              assignRiderImage: riderImage.isNotEmpty
                  ? riderImage
                  : orderList[i].assignRiderImage,
              assignRiderRating: double.tryParse(
                    data['avg_raiderRating']?.toString() ?? '0',
                  ) ??
                  0.0,
              assignRiderReviews: data['total_raiderRatings'] ?? 0,
            );
          }
        }
        orderList.refresh();
      }
    } catch (e) {
      debugPrint("fetchRiderInfoById error: $e");
    }
  }

  // OrderController এর ভেতরে এই মেথডটি আপডেট বা যোগ করুন
  Future<void> fetchRiderRatings(int riderId) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final uri = Uri.parse(ApiEndPoint.rating).replace(
        queryParameters: {
          'type': 'raider',
          'raiderId': riderId.toString(),
        },
      );

      final res = await AppHttpClient.get(
        uri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final Map<String, dynamic> dataMap = body['data'] ?? {};
        final List list = dataMap['data'] ?? [];

        double totalStar = 0;
        for (var item in list) {
          totalStar += (item['rating_star'] ?? 0).toDouble();
        }

        // অরিজিনাল এভারেজ এবং রিভিউ কাউন্ট আপডেট করা
        if (singleOrder.value != null) {
          singleOrder.value = singleOrder.value!.copyWith(
            assignRiderRating:
                list.isNotEmpty ? (totalStar / list.length) : 0.0,
            assignRiderReviews: list.length,
          );
        }
      }
    } catch (e) {
      debugPrint("Error fetching rider ratings: $e");
    }
  }

  Future<void> refreshOrders() async => fetchOrders(isRefresh: true);
  Future<void> loadMoreOrders() async {
    if (!allLoaded.value && !isLoading.value) await fetchOrders();
  }

  void onTabChanged(int index) {
    if (selectOrderListIndex.value != index) {
      selectOrderListIndex.value = index;
      allLoaded.value = false;
      fetchOrders(isRefresh: true);
    }
  }

  Future<void> sendEReceipt(String orderId) async {
    EasyLoading.show(status: 'Sending receipt...');
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError("Token not found");
        return;
      }

      final url = "${ApiEndPoint.baseUrl}/order/$orderId/reciept";
      debugPrint("POST Request URL: $url");
      final response = await AppHttpClient.post(
        Uri.parse(url),
        headers: {
          "accept": "*/*",
          "Authorization": "Bearer $token",
        },
      );

      debugPrint("POST Request Response status: ${response.statusCode}");
      debugPrint("POST Request Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          final receiptUrl = decoded['receiptUrl']?['url']?.toString();
          if (receiptUrl != null && receiptUrl.isNotEmpty) {
            EasyLoading.dismiss();
            await SharePlus.instance.share(
              ShareParams(text: receiptUrl),
            );
          } else {
            EasyLoading.showError("Receipt URL not found in response");
          }
        } else {
          EasyLoading.showError(decoded['message'] ?? "Failed to send receipt");
        }
      } else {
        EasyLoading.showError(
            "Failed to fetch receipt: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("sendEReceipt error: $e");
      EasyLoading.showError("An error occurred: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }
}
