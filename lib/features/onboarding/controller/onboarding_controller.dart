import 'package:ZipBee/core/utils/constants/image_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class OnboardingController extends GetxController {
  var currentIndex = 0.obs;
  late PageController pageController;
  Timer? _timer;

  final List<Map<String, String>> onboardingData = [
    {
      "image": ImagePath.onboarding1,
      "title": "Cash on Delivery or e-payment",
      "subtitle":
          "Our delivery ensure your items are delivered right to the door steps",
    },
    {
      "image": ImagePath.onboarding2,
      "title": "Real-time Tracking",
      "subtitle":
          "Track your packages / items from the comfort of your home till final design",
    },
    {
      "image": ImagePath.onboarding3,
      "title": "Deliver Right to Your Door Step",
      "subtitle": "Our delivery ensure your items are delivered right to the door steps",
    },
  ];

  @override
  void onInit() {
    pageController = PageController();
    _startAutoSlide(); 
    super.onInit();
  }

  // Function to start automatic sliding
  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (currentIndex.value < onboardingData.length - 1) {
        // If not the last page, go to the next page
        currentIndex.value++;
        pageController.animateToPage(
          currentIndex.value,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        // If it's the last page, stop timer and go to login screen
        _timer?.cancel();
        goToLogin();
      }
    });
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
    _timer?.cancel();
    _startAutoSlide();
  }

  void nextPage() {
    if (currentIndex.value < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
      );
    } else {
      goToLogin();
    }
  }

  void goToLogin() {
    Get.offNamed('/loginScreen');
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }
}
