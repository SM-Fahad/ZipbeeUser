import 'package:ZipBee/app.dart';
import 'package:ZipBee/core/constants/stripe_keys.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get_storage/get_storage.dart';

import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'core/service/firebase/notification_permission.dart';
import 'core/service/firebase/notification_receve.dart';
import 'core/utils/custom_map_marker_helper.dart';
import 'firebase_options.dart';

void _configEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..maskColor = Colors.black.withValues(alpha: .5)
    ..userInteractions = false
    ..dismissOnTap = false;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    try {
      mapsImplementation.useAndroidViewSurface = true;
      debugPrint('🗺️ [GoogleMaps] Android Hybrid Composition (useAndroidViewSurface = true) enabled.');
    } catch (e) {
      debugPrint('⚠️ [GoogleMaps] Error setting Google Maps view surface: $e');
    }
  }

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    debugPrint('🗺️ [GoogleMaps] .env loaded. API Key: ${apiKey != null && apiKey.isNotEmpty ? "VALID (${apiKey.substring(0, 6)}...)" : "MISSING!"}');
  } catch (e) {
    debugPrint("⚠️ Could not load .env file: $e");
  }

  CustomMapMarkerHelper.getPickupMarker();
  CustomMapMarkerHelper.getRiderMarker();
  CustomMapMarkerHelper.getDropMarker();

  Stripe.publishableKey = StripeKeys.stripePublicKey;
  await Stripe.instance.applySettings();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint("Firebase already initialized: $e");
  }

  // Initialize local notifications
  await FirebaseNotificationReceive.initializeLocalNotifications();

  // Request notification permission
  await requestNotificationPermission();

  // Setup background message handler
  FirebaseNotificationReceive.setupBackgroundMessageHandler();

  // Listen for foreground messages
  FirebaseNotificationReceive.listenForegroundMessages();

  // Listen for token refresh and send current FCM token if logged in
  listenTokenRefresh();
  await sendCurrentFcmTokenToBackend();

  _configEasyLoading();

  // GetStorage
  await GetStorage.init();

  runApp(const Nicholaslim());
}
