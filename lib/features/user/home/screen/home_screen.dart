import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/home/controller/home_controller.dart';
import 'package:ZipBee/features/user/home/controller/popup_controller.dart';
import 'package:ZipBee/features/user/home/widgets/drawer.dart';
import 'package:ZipBee/features/user/home/widgets/small_horizontal_slider_widget.dart';
import 'package:ZipBee/features/user/home/controller/profile_controller.dart';
import 'package:ZipBee/features/user/wallet/loyalty_and_rewards/controller/loyalty_and_rewards_controller.dart';
import 'package:ZipBee/features/user/wallet/loyalty_and_rewards/screen/loyalty_and_rewards_screen.dart';
import 'package:ZipBee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    const padding = 16.0;
    final media = MediaQuery.of(context);
    final width = media.size.width;

    final HomeController ctrl = Get.put(HomeController());
    ctrl.registerRouteListener(context);
    final PopupController popupCtrl = Get.put(PopupController());
    final UserProfileController profileCtrl = Get.put(UserProfileController());
    final LoyaltyAndRewardsController loyaltyCtrl = Get.put(
      LoyaltyAndRewardsController(),
      permanent: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.resetHomeSelection();
      ctrl.refreshBalanceAndCoin();
      popupCtrl.checkAndShowPopup(context);
    });

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryButtonColor,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppColors.primaryFontColor),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Obx(
          () => Text(
            profileCtrl.userName.value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryFontColor,
            ),
          ),
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.notifications_none,
                    color: AppColors.primaryFontColor,
                  ),
                  if (ctrl.unreadNotificationCount.value > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        constraints: const BoxConstraints(minWidth: 18),
                        child: Text(
                          ctrl.unreadNotificationCount.value > 9
                              ? '9+'
                              : '${ctrl.unreadNotificationCount.value}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () async {
                await Get.toNamed(AppRoutes.getUserNotification());
                await ctrl.refreshBalanceAndCoin();
                await ctrl.fetchUnreadNotificationCount();
              },
            ),
          ),
        ],
      ),
      drawer: drawer(ctrl, onReturnedToHome: ctrl.refreshBalanceAndCoin),
      body: RefreshIndicator(
        onRefresh: ctrl.handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: padding,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await Get.toNamed(AppRoutes.myWalletUser);
                          await ctrl.refreshBalanceAndCoin();
                        },
                        child: borderedInfoCard(
                          title: 'Wallet Balance',
                          valueBuilder: () =>
                              '\$${profileCtrl.walletBalance.value.toStringAsFixed(2)}',
                          iconPath: IconPath.wallet,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await Get.to(const LoyaltyAndRewardsScreen());
                          await ctrl.refreshBalanceAndCoin();
                        },
                        child: borderedInfoCard(
                          title: 'Available Coin',
                          valueBuilder: () => loyaltyCtrl.coin.value.toString(),
                          iconPath: IconPath.points,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              Row(
                children: [
                  Text(
                    'Service Options',
                    style: getTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Image.asset(IconPath.trunk1, height: 30, width: 30),
                ],
              ),
              const SizedBox(height: 14),
              Obx(() {
                if (ctrl.isDeliveryLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (ctrl.deliveryTypes.isEmpty) {
                  return const Text("No service options available");
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: ctrl.deliveryTypes.map((type) {
                      final isSelected =
                          ctrl.deliveryType.value == type.name.toLowerCase();

                      return Container(
                        width: MediaQuery.of(context).size.width * 0.40,
                        margin: const EdgeInsets.only(right: 10),
                        child: buildServiceOptionCard(
                          title: type.name.capitalizeFirst ?? type.name,
                          subtitle: type.formattedSubtitle,
                          selected: isSelected,
                          iconPath: type.iconPath,
                          onTap: () => ctrl.selectDeliveryType(type),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
              const SizedBox(height: 35),
              Obx(() {
                if (ctrl.isAdsLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                } else if (ctrl.ads.isNotEmpty) {
                  return Column(
                    children: [
                      SmallHorizontalSlider(width: width, ads: ctrl.ads),
                      const SizedBox(height: 10),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget borderedInfoCard({
    required String title,
    required String Function() valueBuilder,
    IconData? icon,
    String? iconPath,
    Color? iconBgColor,
    double iconSize = 20,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroungColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.subtitleFontColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor ?? Colors.white,
              shape: BoxShape.circle,
            ),
            child: iconPath != null
                ? Image.asset(iconPath, height: iconSize, width: iconSize)
                : Icon(icon, size: iconSize, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryFontColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            valueBuilder(),
            style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget buildServiceOptionCard({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
    String? iconPath,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.orange.shade100 : const Color(0xFFFFEEBB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.orange : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: getTextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (iconPath != null && iconPath.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Image.asset(
                    iconPath,
                    height: 20,
                    width: 20,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: getTextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
