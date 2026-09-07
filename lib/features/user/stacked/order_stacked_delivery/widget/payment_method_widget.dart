import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/home/controller/profile_controller.dart';
import 'package:ZipBee/features/user/wallet/manage_payment/controller/manage_payment_controller.dart';
import 'package:ZipBee/features/user/wallet/manage_payment/model/payment_card_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

// Payment Option Model
class StackedPaymentOption {
  final String title;
  final String subtitle;
  final String? imageAsset;

  StackedPaymentOption({required this.title, required this.subtitle, this.imageAsset});
}

// -------------------
// Payment Controller
// -------------------
class StackedPaymentController extends GetxController {
  var selectedIndex = (1).obs;
  var selectedTitle = "Wallet".obs;
  var walletBalance = 0.0.obs;
  String? selectedPaymentMethodId; // Store payment method ID from Stripe
  final Rxn<PaymentCardModel> selectedStripeCard = Rxn<PaymentCardModel>();
  final RxBool isLoadingStripeCards = false.obs;

  late final ManagePaymentController managePaymentController;

  @override
  void onInit() {
    super.onInit();
    managePaymentController = Get.isRegistered<ManagePaymentController>()
        ? Get.find<ManagePaymentController>()
        : Get.put(ManagePaymentController());
    fetchWalletBalance();
  }

  Future<void> fetchWalletBalance() async {
    try {
      final UserProfileController profileCtrl = Get.isRegistered<UserProfileController>()
          ? Get.find<UserProfileController>()
          : Get.put(UserProfileController());

      if (profileCtrl.walletBalance.value > 0) {
        walletBalance.value = profileCtrl.walletBalance.value;
      }

      await profileCtrl.fetchUserProfile();
      walletBalance.value = profileCtrl.walletBalance.value;
      debugPrint('💰 StackedPaymentController wallet balance updated: \$${walletBalance.value}');
    } catch (e) {
      debugPrint("Error fetching wallet balance in StackedPaymentController: $e");
    }
  }

  Future<void> loadStripeCards({bool forceRefresh = false}) async {
    try {
      isLoadingStripeCards.value = true;

      if (forceRefresh || managePaymentController.savedCards.isEmpty) {
        await managePaymentController.refreshScreen();
      }

      final PaymentCardModel? primaryCard =
          managePaymentController.savedCards
              .where((card) => card.isDefault)
              .cast<PaymentCardModel?>()
              .firstOrNull ??
          managePaymentController.savedCards.firstOrNull;

      if (selectedStripeCard.value == null && primaryCard != null) {
        selectedStripeCard.value = primaryCard;
        selectedPaymentMethodId = primaryCard.stripeMethodId;
      }
    } finally {
      isLoadingStripeCards.value = false;
    }
  }

  void selectStripeCard({
    required int index,
    required PaymentCardModel card,
  }) {
    selectedIndex.value = index;
    selectedStripeCard.value = card;
    selectedPaymentMethodId = card.stripeMethodId;
    selectedTitle.value = 'Stripe • ${card.brandLabel} ****${card.last4}';
  }

  void selectWallet({
    required int index,
    required StackedPaymentOption option,
  }) {
    selectedIndex.value = index;
    selectedTitle.value = option.title;
    selectedStripeCard.value = null;
    selectedPaymentMethodId = null;
    debugPrint('✅ Wallet selected');
    EasyLoading.showInfo('Wallet selected');
    Get.back();
  }

  void selectCash({
    required int index,
    required StackedPaymentOption option,
  }) {
    selectedIndex.value = index;
    selectedTitle.value = option.title;
    selectedStripeCard.value = null;
    selectedPaymentMethodId = null;
    debugPrint('✅ Cash selected');
    EasyLoading.showInfo('Cash selected');
    Get.back();
  }
}

// -------------------
// Payment Selection Widget
// -------------------
class StackedPaymentSelectionWidget extends StatelessWidget {
  final List<StackedPaymentOption> options;
  final StackedPaymentController controller;
  final double orderAmount;

  const StackedPaymentSelectionWidget({
    super.key,
    required this.options,
    required this.controller,
    required this.orderAmount,
  });

  /// Handle payment method selection
  Future<void> _handlePaymentSelection(
    int index,
    StackedPaymentOption option,
  ) async {
    if (option.title == "Stripe") {
      await _handleStripeSelection(index);
      return;
    }

    if (option.title == "Wallet") {
      controller.selectWallet(index: index, option: option);
      return;
    }

    if (option.title == "Cash") {
      controller.selectCash(index: index, option: option);
    }
  }

  Future<void> _handleStripeSelection(int index) async {
    debugPrint('➡️ Stripe selected - opening saved cards dialog');
    await controller.loadStripeCards(forceRefresh: true);

    if (controller.managePaymentController.savedCards.isEmpty) {
      await Get.dialog(
        Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.credit_card_off_rounded,
                          color: Colors.black87,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No saved cards',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Add a saved Stripe card to continue with this payment method.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Your card will be securely saved and then available for future Stripe payments.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              controller.managePaymentController.isAddingCard.value
                              ? null
                              : () async {
                                  Get.back();
                                  final success = await controller
                                      .managePaymentController
                                      .onAddPayment();
                                  if (success) {
                                    await controller.loadStripeCards(
                                      forceRefresh: true,
                                    );
                                    await _showSavedCardsDialog(index);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child:
                              controller.managePaymentController.isAddingCard.value
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Add Card',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      return;
    }

    await _showSavedCardsDialog(index);
  }

  Future<void> _showSavedCardsDialog(int index) async {
    final tempSelectedCard = Rxn<PaymentCardModel>(
      controller.selectedStripeCard.value ??
          controller.managePaymentController.savedCards
              .where((card) => card.isDefault)
              .cast<PaymentCardModel?>()
              .firstOrNull ??
          controller.managePaymentController.savedCards.firstOrNull,
    );

    await Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.credit_card_rounded,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select payment card',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Choose a saved Stripe card for this order.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (controller.managePaymentController.savedCards.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No saved card found',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add a payment method first to continue with Stripe.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: SingleChildScrollView(
                      child: Column(
                        children: controller.managePaymentController.savedCards
                            .map(
                              (card) {
                                final isSelected =
                                    tempSelectedCard.value?.id == card.id;

                                return InkWell(
                                  onTap: () => tempSelectedCard.value = card,
                                  borderRadius: BorderRadius.circular(18),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.amber.shade50
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.amber.shade700
                                            : Colors.grey.shade300,
                                        width: isSelected ? 1.6 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 46,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.amber.shade100
                                                : Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.credit_card_rounded,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${card.brandLabel} •••• ${card.last4}',
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                  // if (card.isDefault)
                                                  //   Container(
                                                  //     padding:
                                                  //         const EdgeInsets.symmetric(
                                                  //           horizontal: 8,
                                                  //           vertical: 4,
                                                  //         ),
                                                  //     decoration: BoxDecoration(
                                                  //       color: Colors.black87,
                                                  //       borderRadius:
                                                  //           BorderRadius.circular(
                                                  //             999,
                                                  //           ),
                                                  //     ),
                                                  //     child: const Text(
                                                  //       'Default',
                                                  //       style: TextStyle(
                                                  //         fontSize: 11,
                                                  //         color: Colors.white,
                                                  //         fontWeight:
                                                  //             FontWeight.w600,
                                                  //       ),
                                                  //     ),
                                                  //   ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Expiry ${card.expiryLabel}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle
                                              : Icons.radio_button_off,
                                          color: isSelected
                                              ? Colors.green
                                              : Colors.grey.shade400,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                            .toList(),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed:
                            controller.managePaymentController.isAddingCard.value
                            ? null
                            : () async {
                                Get.back();
                                final success = await controller
                                    .managePaymentController
                                    .onAddPayment();
                                if (success) {
                                  await controller.loadStripeCards(
                                    forceRefresh: true,
                                  );
                                  await _showSavedCardsDialog(index);
                                }
                              },
                        child:
                            controller.managePaymentController.isAddingCard.value
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                              'Add payment method', 
                              style: TextStyle(
                                color: Colors.black
                              ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Get.back(),
                        child: const Text('Cancel', style: TextStyle(color: Colors.black),),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: tempSelectedCard.value == null
                            ? null
                            : () {
                                final selectedCard = tempSelectedCard.value;
                                if (selectedCard == null) return;

                                controller.selectStripeCard(
                                  index: index,
                                  card: selectedCard,
                                );
                                debugPrint(
                                  '✅ Stripe card selected: ${selectedCard.stripeMethodId}',
                                );
                                EasyLoading.showInfo(
                                  '${selectedCard.brandLabel} ****${selectedCard.last4} selected',
                                );
                                Get.back();
                                Get.back();
                              },
                        child: const Text('Select'),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.asMap().entries.map((entry) {
        int index = entry.key;
        StackedPaymentOption option = entry.value;

        return Column(
          children: [
            Obx(
              () => ListTile(
                leading: option.imageAsset != null
                    ? Image.asset(option.imageAsset!, width: 32, height: 32)
                    : Image.asset(IconPath.arrowBackIcon),
                title: Text(
                  option.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  option.title == "Stripe" &&
                          controller.selectedStripeCard.value != null
                      ? '${controller.selectedStripeCard.value!.brandLabel} ending in ${controller.selectedStripeCard.value!.last4}'
                      : option.subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: GestureDetector(
                  onTap: () => _handlePaymentSelection(index, option),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: controller.selectedIndex.value == index
                            ? Colors.yellow
                            : Colors.black,
                        width: 2,
                      ),
                    ),
                    child: controller.selectedIndex.value == index
                        ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.yellow,
                        ),
                      ),
                    )
                        : null,
                  ),
                ),
                onTap: () => _handlePaymentSelection(index, option),
              ),
            ),
            if (index != options.length - 1) Divider(height: 1),
          ],
        );
      }).toList(),
    );
  }
}

// -------------------
// Selector Button Widget
// -------------------
class StackedPaymentMethodSelector extends StatelessWidget {
  final List<StackedPaymentOption> options;
  final double orderAmount;
  final StackedPaymentController controller = Get.put(StackedPaymentController());

  StackedPaymentMethodSelector({
    super.key,
    required this.options,
    required this.orderAmount,
  });

  void openSelectorSheet() {
    Get.bottomSheet(
      Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StackedPaymentSelectionWidget(
            options: options,
            controller: controller,
            orderAmount: orderAmount,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: openSelectorSheet,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade500),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Obx(
                () => Text(
                  controller.selectedTitle.value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }
}
