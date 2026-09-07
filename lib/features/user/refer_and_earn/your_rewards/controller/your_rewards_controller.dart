import 'package:ZipBee/features/user/refer_and_earn/widget/redeem_credits_suscess_widget.dart';
import 'package:ZipBee/features/user/refer_and_earn/your_rewards/service/your_rewards_service.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/foundation.dart';

class YourRewardsController extends GetxController {
  var totalCredits = 0.obs;
  var rewardMoney = 0.obs;
  var currencyValue = 0.0.obs;
  var referralHistory = <Map<String, String>>[].obs;

  final String? referCode;

  YourRewardsController({
    int initialCredits = 0,
    this.referCode,
    int initialRewardMoney = 0,
  }) {
    totalCredits.value = initialCredits;
    rewardMoney.value = initialRewardMoney;
    debugPrint('initialRewardMoney: ${rewardMoney.value}');
  }

  // USD value of credits using backend base price formula: basePrice * credits / 100
  double get rewardInDollar => (totalCredits.value * currencyValue.value) / 100;

  @override
  void onInit() {
    super.onInit();
    _loadBasePrice();
    // fetch referral history if we have a referral code
    if (referCode != null && referCode!.isNotEmpty) {
      fetchReferralHistory();
    } else if (Get.arguments != null && Get.arguments['referralCode'] != null) {
      fetchReferralHistory();
    }
  }

  Future<void> _loadBasePrice() async {
    final result = await YourRewardsService.fetchBasePrice();
    debugPrint('fetchBasePrice result: $result');
    if (result['statusCode'] == 200) {
      final body = result['body'];
      final value = body is Map && body.containsKey('data')
          ? body['data']
          : null;
      if (value != null) {
        final parsed = value is num
            ? value.toDouble()
            : double.tryParse(value.toString());
        if (parsed != null) {
          currencyValue.value = parsed;
        } else {
          debugPrint('fetchBasePrice: unable to parse base price $value');
        }
        debugPrint('currencyValue: ${currencyValue.value}');
      } else {
        debugPrint('fetchBasePrice: no data field in body: $body');
      }
    } else {
      debugPrint(
        'fetchBasePrice failed: ${result['statusCode']} ${result['body']}',
      );
    }
  }

  Future<void> fetchReferralHistory() async {
    final code =
        referCode ??
        (Get.arguments != null
            ? Get.arguments['referralCode'] as String?
            : null);
    if (code == null || code.isEmpty) return;

    final result = await YourRewardsService.fetchReferralHistory(
      referCode: code,
    );
    debugPrint('fetchReferralHistory full result: $result');

    if (result['statusCode'] != 200) {
      debugPrint(
        'fetchReferralHistory failed: ${result['statusCode']} ${result['body']}',
      );
      return;
    }

    final body = result['body'];
    // The endpoint response structure can vary; try to find list inside body or data
    List<dynamic>? list;
    if (body is Map && body.containsKey('data')) {
      final d = body['data'];
      if (d is List) list = d;
      if (d is Map && d.containsKey('rows')) list = d['rows'];
    }
    if (list == null && body is List) list = body;

    if (list != null) {
      referralHistory.clear();
      for (var item in list) {
        // item expected to have username and created_at; user object may be nested
        String username = '';
        if (item is Map) {
          if (item['user'] is Map) {
            username = item['user']['username'] ?? item['user']['name'] ?? '';
          }
          username = username.isNotEmpty
              ? username
              : (item['username'] ?? item['name'] ?? '');
        }

        final createdAt = (item is Map)
            ? (item['created_at'] ??
                  item['createdAt'] ??
                  item['user']?['created_at'] ??
                  '')
            : '';

        // format date: keep day, month (short), year
        String dateStr = '';
        try {
          if (createdAt != null && createdAt.toString().isNotEmpty) {
            final dt = DateTime.parse(createdAt.toString());
            dateStr =
                '${dt.day.toString().padLeft(2, '0')} ${_monthShort(dt.month)} ${dt.year}';
          }
        } catch (e) {
          debugPrint('Date parse error: $e');
          dateStr = createdAt.toString();
        }

        // debugprint username and date
        debugPrint('Referral item - username: $username');
        debugPrint('Referral item - date: $dateStr');

        referralHistory.add({'username': username, 'date': dateStr});
      }
    }
  }

  String _monthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Future<void> redeemCredits() async {
    final coin = totalCredits.value;
    if (coin <= 0) {
      EasyLoading.showError('No credits to redeem');
      return;
    }

    final result = await YourRewardsService.redeemPoint(coin: coin);
    debugPrint('redeemCredits result: $result');

    final body = result['body'];

    String message = 'Something went wrong';
    bool isSuccess = false;

    if (body is Map) {
      if (body.containsKey('message')) {
        message = body['message'].toString();
      }
      if (body.containsKey('error') &&
          body['error'] is Map &&
          body['error']['message'] != null) {
        message = body['error']['message'].toString();
      }
      if (body.containsKey('success')) {
        isSuccess = body['success'] == true;
      }
    }

    debugPrint('redeemCredits full response: $result');

    if (isSuccess) {
      EasyLoading.showSuccess(message);
    } else {
      EasyLoading.showError(message);
    }

    if (isSuccess) {
      Get.to(() => RedeemSuccessScreen());
    }
  }
}
