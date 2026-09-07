import 'dart:convert';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:ZipBee/features/user/finding_raider/controller/review_controller.dart';
import 'package:ZipBee/features/user/wallet/manage_payment/model/payment_card_model.dart';
import 'package:ZipBee/features/user/wallet/manage_payment/controller/manage_payment_controller.dart';
import 'package:ZipBee/core/service/app_http_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../bottom_navbar/screen/bottom_navbar_screen.dart';

class RiderTipController extends GetxController {
  /// ---------------- RIDER INFO (from review screen) ----------------
  var riderId = 0.obs;
  var orderId = "".obs;
  var riderName = "".obs;
  var riderImage = "".obs;
  var riderRating = 0.0.obs;

  /// ---------------- TIP OPTIONS ----------------
  final List<double> raiderTipOptions = [2, 5, 10];
  var selectedRaiderTip = 0.obs;
  final TextEditingController amountController = TextEditingController();
  final RxnDouble customAmount = RxnDouble();

  double get selectedAmount =>
      customAmount.value ?? raiderTipOptions[selectedRaiderTip.value];

  /// ---------------- PAYMENT ----------------
  var selectedPaymentIndex = 0.obs;
  var selectedPaymentTitle = "Wallet".obs;

  /// For ONLINE_PAY (Stripe)
  String? paymentMethodId;
  final RxString stripePaymentMethodId = "".obs;
  final RxBool isLoadingStripeMethod = false.obs;
  final Rxn<PaymentCardModel> selectedStripeCard = Rxn<PaymentCardModel>();
  late final ManagePaymentController managePaymentController;

  /// Payment options list for your existing PaymentOptionWidget
  /// don't remove commented options. You might need them in the future.
  final paymentOptions = [
    // {"title": "Cash", "method": "COD"},
    {"title": "Wallet", "method": "WALLET"},
    // {"title": "Stripe", "method": "ONLINE_PAY"},
  ];

  /// ---------------- INIT (receive from ReviewController) ----------------
  @override
  void onInit() {
    super.onInit();
    managePaymentController = Get.isRegistered<ManagePaymentController>()
        ? Get.find<ManagePaymentController>()
        : Get.put(ManagePaymentController());

    /// get previous controller data automatically
    final review = Get.find<ReviewController>();

    try {
      orderId.value = review.orderId;
      riderId.value = review.actualRiderId.value;
      riderName.value = review.riderName.value;
      riderImage.value = review.riderImage.value;
      riderRating.value = review.submittedRating.value > 0
          ? review.submittedRating.value
          : review.inputRating.value;
    } catch (_) {}

    amountController.text = selectedAmount.toStringAsFixed(0);
    _loadStripePaymentMethod();
  }

  /// ---------------- TIP SELECTION ----------------
  void selectTip(int index) {
    selectedRaiderTip.value = index;
    customAmount.value = null;
    amountController.text = raiderTipOptions[index].toStringAsFixed(0);
  }

  /// ---------------- PAYMENT SELECTION ----------------
  void selectPayment(int index, {String? stripeMethodId}) {
    selectedPaymentIndex.value = index;
    selectedPaymentTitle.value = paymentOptions[index]["title"].toString();

    if (paymentOptions[index]["method"] == "ONLINE_PAY") {
      paymentMethodId = stripeMethodId ?? stripePaymentMethodId.value;
    } else {
      paymentMethodId = null;
    }
  }

  Future<void> handleStripeSelection() async {
    selectPayment(1, stripeMethodId: stripePaymentMethodId.value);
    await _loadStripePaymentMethod(forceRefresh: true);

    if (managePaymentController.savedCards.isEmpty) {
      await Get.dialog(
        AlertDialog(
          title: const Text('No saved cards'),
          content: const Text(
            'You do not have any saved Stripe card. Add a card to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                final success = await managePaymentController.onAddPayment();
                if (success) {
                  await _loadStripePaymentMethod(forceRefresh: true);
                  if (managePaymentController.savedCards.isNotEmpty) {
                    await _showSavedCardsDialog();
                  }
                }
              },
              child: const Text('Add Card'),
            ),
          ],
        ),
      );
      return;
    }

    await _showSavedCardsDialog();
  }

  void updateCustomAmount(String value) {
    final amount = double.tryParse(value.trim());
    if (amount == null || amount <= 0) {
      customAmount.value = null;
      return;
    }
    customAmount.value = amount;
  }

  Future<void> _loadStripePaymentMethod({bool forceRefresh = false}) async {
    try {
      isLoadingStripeMethod.value = true;

      if (forceRefresh || managePaymentController.savedCards.isEmpty) {
        await managePaymentController.refreshScreen();
      }

      final PaymentCardModel? primaryCard = managePaymentController.savedCards
              .where((card) => card.isDefault)
              .cast<PaymentCardModel?>()
              .firstOrNull ??
          managePaymentController.savedCards.firstOrNull;

      if (primaryCard != null && primaryCard.stripeMethodId.isNotEmpty) {
        selectedStripeCard.value = primaryCard;
        stripePaymentMethodId.value = primaryCard.stripeMethodId;
      } else {
        selectedStripeCard.value = null;
        stripePaymentMethodId.value = "";
      }
    } catch (_) {
      selectedStripeCard.value = null;
      stripePaymentMethodId.value = "";
    } finally {
      isLoadingStripeMethod.value = false;
    }
  }

  Future<void> _showSavedCardsDialog() async {
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select a saved card',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                ...managePaymentController.savedCards.map(
                  (card) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.credit_card),
                    title: Text('${card.brandLabel} ending in ${card.last4}'),
                    subtitle: Text('Expiry ${card.expiryLabel}'),
                    trailing: selectedStripeCard.value?.id == card.id
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      selectedStripeCard.value = card;
                      stripePaymentMethodId.value = card.stripeMethodId;
                      selectPayment(1, stripeMethodId: card.stripeMethodId);
                      Get.back();
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        Get.back();
                        final success =
                            await managePaymentController.onAddPayment();
                        if (success) {
                          await _loadStripePaymentMethod(forceRefresh: true);
                          if (managePaymentController.savedCards.isNotEmpty) {
                            await _showSavedCardsDialog();
                          }
                        }
                      },
                      child: const Text('Add Card'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get paymentMethod =>
      paymentOptions[selectedPaymentIndex.value]["method"].toString();

  /// ---------------- SUBMIT TIP API ----------------
  Future<bool> submitTip() async {
    if (orderId.value.isEmpty || int.tryParse(orderId.value) == null) {
      EasyLoading.showError("Invalid order id");
      return false;
    }

    if (riderId.value == 0) {
      EasyLoading.showError("Rider not found");
      return false;
    }

    if (selectedAmount <= 0) {
      EasyLoading.showError("Please enter a valid amount");
      return false;
    }

    if (paymentMethod == "ONLINE_PAY") {
      paymentMethodId = stripePaymentMethodId.value.isNotEmpty
          ? stripePaymentMethodId.value
          : null;
      if (paymentMethodId == null || paymentMethodId!.isEmpty) {
        EasyLoading.showError("No Stripe payment method found");
        return false;
      }
    }

    try {
      EasyLoading.show(status: "Processing tip...");

      final token = await SharedPreferencesHelper.getAccessToken();

      final body = {
        "paymentMethod": paymentMethod, // COD / WALLET / ONLINE_PAY
        "paymentMethodId":
            paymentMethod == "ONLINE_PAY" ? paymentMethodId : null,
        "amount": selectedAmount,
      };

      final uri = Uri.parse(
        ApiEndPoint.tip.replaceFirst('{order_id}', orderId.value),
      );

      debugPrint("➡️ TIP API URL: ${uri.toString()}");
      debugPrint("➡️ TIP API REQUEST BODY: ${jsonEncode(body)}");

      final res = await AppHttpClient.post(
        uri,
        headers: {
          "accept": "*/*",
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      debugPrint("✅ TIP API STATUS CODE: ${res.statusCode}");
      debugPrint("✅ TIP API RESPONSE BODY: ${res.body}");

      final responseBody = jsonDecode(res.body);
      final isApiSuccess = responseBody is Map<String, dynamic> &&
          responseBody['success'] == true &&
          res.statusCode >= 200 &&
          res.statusCode < 300;

      if (isApiSuccess) {
        EasyLoading.showSuccess("Tip sent successfully");
        Get.to(BottomNavbarScreen());
        return true;
      } else {
        EasyLoading.showError(_extractTipErrorMessage(responseBody));
      }
    } catch (e) {
      debugPrint("SubmitTip error: $e");
      EasyLoading.showError("Something went wrong");
    }
    return false;
  }

  String _extractTipErrorMessage(dynamic responseBody) {
    if (responseBody is! Map<String, dynamic>) {
      return "Failed to send tip";
    }

    final error = responseBody['error'];
    if (error is Map<String, dynamic>) {
      final message = error['message'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }

      final response = error['response'];
      if (response is Map<String, dynamic>) {
        final responseMessage = response['message'];
        if (responseMessage != null &&
            responseMessage.toString().trim().isNotEmpty) {
          return responseMessage.toString();
        }
      }
    }

    final message = responseBody['message'];
    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }

    return "Failed to send tip";
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}
