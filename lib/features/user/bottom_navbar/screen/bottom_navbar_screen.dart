import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/bottom_navbar/controller/bottom_navabr_cotroller.dart';
import 'package:ZipBee/features/user/home/controller/home_controller.dart';
import 'package:ZipBee/features/user/home/screen/home_screen.dart';
import 'package:ZipBee/features/user/order/screen/order_screen.dart';
import 'package:ZipBee/features/user/profile/screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class BottomNavbarScreen extends StatelessWidget {
  BottomNavbarScreen({super.key});

  final BottomNavbarController controller = Get.put(
    BottomNavbarController(),
    permanent: true,
  );

  final HomeController homeController = Get.put(
    HomeController(),
    permanent: true,
  );

  final List<Widget> _screens = [
    HomeScreen(),
    OrderScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int targetIndex = 0;
      final args = Get.arguments;
      if (args is int) {
        targetIndex = args;
      } else if (args is Map && args['index'] is int) {
        targetIndex = args['index'] as int;
      }
      controller.changeTab(targetIndex);
      homeController.resetHomeSelection();
    });
    return Obx(
      () => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppColors.backgroungColor,
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: AppColors.backgroungColor,
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.onboardingIndicatorActive,
            unselectedItemColor: AppColors.subtitleFontColor,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
