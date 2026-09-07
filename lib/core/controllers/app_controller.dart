import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Global App Controller - manages app-wide state changes
class AppController extends GetxController {
  // Observable to trigger full app rebuild
  RxInt appRebuildTrigger = 0.obs;

  /// Triggers a full app rebuild
  void rebuildApp() {
    appRebuildTrigger.value++;
    debugPrint('🔄 App rebuild triggered: ${appRebuildTrigger.value}');
  }

  /// Get current rebuild count (for debugging)
  int get rebuildCount => appRebuildTrigger.value;
}
