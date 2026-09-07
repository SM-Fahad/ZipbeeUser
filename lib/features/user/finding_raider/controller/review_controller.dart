import 'dart:convert';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:ZipBee/features/user/finding_raider/model/review_model.dart';
import 'package:ZipBee/core/service/app_http_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class ReviewController extends GetxController {
  final String orderId;
  final int? riderId;

  ReviewController({required this.orderId, required this.riderId});

  /// ---------------- STATE ----------------
  var inputRating = 0.0.obs;
  var submittedRating = 0.0.obs;
  final commentController = TextEditingController();
  final RxnString selectedDeliveryQuality = RxnString();
  final RxnString selectedDeliveryStatus = RxnString();

  RxList<Review> reviews = <Review>[].obs;
  var isLoading = false.obs;

  /// summary (for header)
  var averageRating = 0.0.obs;
  var totalReviews = 0.obs;

  var deliveryQualityStats = <String, int>{}.obs;

  /// Rider info for tip screen
  var actualRiderId = 0.obs;
  var riderName = "".obs;
  var riderImage = "".obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch order details to get actual rider ID
    _fetchOrderDetails();
    if (riderId != null) {
      fetchRatings();
    }
  }

  /// Fetch order details to get rider ID and fetch rider profile
  Future<void> _fetchOrderDetails() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final int parsedOrderId = int.tryParse(orderId) ?? 0;
      if (parsedOrderId == 0) return;

      final uri = Uri.parse(
        '${ApiEndPoint.getOrder.replaceFirst('{orderId}', orderId)}',
      );

      final res = await AppHttpClient.get(
        uri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      debugPrint("Fetch Order Details Status: ${res.statusCode}");

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final orderData = body['data'];

        final fetchedRiderId = orderData['assign_rider_id'];
        if (fetchedRiderId != null) {
          actualRiderId.value = int.tryParse(fetchedRiderId.toString()) ?? 0;
          debugPrint("✅ Rider ID from order: ${actualRiderId.value}");

          // Fetch rider profile data
          await _fetchRiderProfile(actualRiderId.value);
        }
      }
    } catch (e) {
      debugPrint("_fetchOrderDetails error: $e");
    }
  }

  /// Fetch rider profile to get name and image
  Future<void> _fetchRiderProfile(int id) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final uri = Uri.parse('${ApiEndPoint.profile}');

      final res = await AppHttpClient.get(
        uri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      debugPrint("Fetch Rider Profile Status: ${res.statusCode}");

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final userData = body['data'];

        // Get rider name from raider profile
        if (userData['raiderProfile'] != null &&
            userData['raiderProfile']['registrations'] != null &&
            userData['raiderProfile']['registrations'].isNotEmpty) {
          riderName.value = userData['raiderProfile']['registrations'][0]
                  ['raider_name'] ??
              "Rider";
        } else {
          riderName.value = userData['username'] ?? "Rider";
        }
        debugPrint('✅ Rider Name: ${riderName.value}');

        riderImage.value = userData['image'] ?? "";

        debugPrint("✅ Rider Name: ${riderName.value}");
        debugPrint("✅ Rider Image: ${riderImage.value}");
      }
    } catch (e) {
      debugPrint("_fetchRiderProfile error: $e");
    }
  }

  /// ---------------- FETCH REVIEWS ----------------
  Future<void> fetchRatings() async {
    if (riderId == null) return;

    try {
      isLoading.value = true;
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

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

      debugPrint("Fetch Rider Ratings URL: ${uri.toString()}");
      debugPrint("Fetch Rider Ratings Status: ${res.statusCode}");
      debugPrint("Fetch Rider Ratings Body: ${res.body}");

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final Map<String, dynamic> dataMap = body['data'] ?? {};
        final List list = dataMap['data'] ?? [];

        reviews.value = list.map((e) {
          final item = e is Map<String, dynamic>
              ? e
              : Map<String, dynamic>.from(e as Map);
          final user = item['user'] is Map<String, dynamic>
              ? item['user'] as Map<String, dynamic>
              : null;
          final order = item['order'] is Map<String, dynamic>
              ? item['order'] as Map<String, dynamic>
              : null;
          final orderUser = order?['user'] is Map<String, dynamic>
              ? order!['user'] as Map<String, dynamic>
              : null;

          final resolvedName = item['userName']?.toString() ??
              item['username']?.toString() ??
              user?['username']?.toString() ??
              user?['name']?.toString() ??
              orderUser?['username']?.toString() ??
              orderUser?['name']?.toString() ??
              (() {
                final userId = item['user_id']?.toString();
                if (userId != null && userId.isNotEmpty) {
                  return 'User #$userId';
                }
                return 'User';
              })();

          final resolvedImage = item['userImage']?.toString() ??
              item['user_image']?.toString() ??
              item['image']?.toString() ??
              user?['profileImage']?.toString() ??
              user?['profile_image']?.toString() ??
              user?['image']?.toString() ??
              orderUser?['profileImage']?.toString() ??
              orderUser?['profile_image']?.toString() ??
              orderUser?['image']?.toString() ??
              '';

          return Review(
            name: resolvedName,
            imageUrl: resolvedImage,
            rating: (item['rating_star'] ?? 0).toDouble(),
            comment: item['notes']?.toString() ?? "",
          );
        }).toList();

        totalReviews.value =
            int.tryParse(dataMap['totalCount']?.toString() ?? '') ??
                reviews.length;
        averageRating.value =
            double.tryParse(dataMap['averageRating']?.toString() ?? '') ??
                (reviews.isNotEmpty
                    ? reviews.fold<double>(0, (p, e) => p + e.rating) /
                        reviews.length
                    : 0);

        final statsMap = dataMap['deliveryQualityStats'];
        if (statsMap is Map<String, dynamic>) {
          deliveryQualityStats.value = statsMap.map((key, value) {
            return MapEntry(key.toUpperCase(), int.tryParse(value.toString()) ?? 0);
          });
        } else {
          deliveryQualityStats.clear();
        }
      } else {
        debugPrint("Failed to fetch ratings for riderId=$riderId");
      }
    } catch (e) {
      debugPrint("fetchRatings error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- RATING PERCENTAGES ----------------
  Map<String, double> getRatingPercentages() {
    int excellent = deliveryQualityStats['EXCELLENT'] ?? 0;
    int good = deliveryQualityStats['GOOD'] ?? 0;
    int average = deliveryQualityStats['AVERAGE'] ?? 0;
    int poor = deliveryQualityStats['POOR'] ?? 0;
    int total = excellent + good + average + poor;

    if (total == 0) {
      if (reviews.isEmpty) {
        return {"Excellent": 0.0, "Good": 0.0, "Average": 0.0, "Poor": 0.0};
      }
      int exc = reviews.where((r) => r.rating >= 5.0).length;
      int gd = reviews.where((r) => r.rating >= 4.0 && r.rating <= 4.9).length;
      int avg =
          reviews.where((r) => r.rating >= 3.0 && r.rating <= 3.9).length;
      int pr = reviews.where((r) => r.rating < 3.0).length;
      int tot = reviews.length;

      return {
        "Excellent": exc / tot,
        "Good": gd / tot,
        "Average": avg / tot,
        "Poor": pr / tot,
      };
    }

    return {
      "Excellent": excellent / total,
      "Good": good / total,
      "Average": average / total,
      "Poor": poor / total,
    };
  }

  /// ---------------- SUBMIT REVIEW ----------------
  void selectDeliveryQuality(String value) {
    selectedDeliveryQuality.value = value;
  }

  void selectDeliveryStatus(String value) {
    selectedDeliveryStatus.value = value;
  }

  void resetReviewForm() {
    inputRating.value = 0.0;
    commentController.clear();
    selectedDeliveryQuality.value = null;
    selectedDeliveryStatus.value = null;
  }

  Future<bool> submitReview() async {
    if (riderId == null) {
      EasyLoading.showError("Rider info unavailable");
      return false;
    }

    if (selectedDeliveryQuality.value == null ||
        selectedDeliveryQuality.value!.isEmpty) {
      EasyLoading.showError("Please select delivery quality");
      return false;
    }

    if (selectedDeliveryStatus.value == null ||
        selectedDeliveryStatus.value!.isEmpty) {
      EasyLoading.showError("Please select delivery status");
      return false;
    }

    if (inputRating.value <= 0) {
      EasyLoading.showError("Please select a star rating");
      return false;
    }

    try {
      EasyLoading.show(status: "Submitting...");
      final token = await SharedPreferencesHelper.getAccessToken();
      final userId = await SharedPreferencesHelper.getUserId();

      final int parsedOrderId = int.tryParse(orderId) ?? 0;
      if (token == null || token.isEmpty) {
        EasyLoading.showError("Access token not found");
        return false;
      }

      if (parsedOrderId == 0) {
        EasyLoading.showError("Invalid order id");
        return false;
      }

      final body = {
        "type": "raider",
        "orderId": parsedOrderId,
        "raiderId": riderId,
        "user_id": int.tryParse(userId.toString()) ?? 0,
        "rating_star": inputRating.value.toInt(),
        "notes": commentController.text.trim(),
        "delivery_quality": selectedDeliveryQuality.value,
        "delivery_status": selectedDeliveryStatus.value,
      };

      debugPrint("Submitting Review Body: ${jsonEncode(body)}");

      final res = await AppHttpClient.post(
        Uri.parse('${ApiEndPoint.rating}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint("Submit Review Status: ${res.statusCode}");
      debugPrint("Submit Review Response: ${res.body}");

      if (res.statusCode >= 200 && res.statusCode < 300) {
        submittedRating.value = inputRating.value;
        EasyLoading.showSuccess("Review Submitted");
        resetReviewForm();
        await fetchRatings();
        return true;
      } else {
        EasyLoading.showError("Submit failed: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("SubmitReview error: $e");
      EasyLoading.showError("Error submitting review");
    }
    return false;
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
