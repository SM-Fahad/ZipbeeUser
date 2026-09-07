import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../api_end_point/api_end_point.dart';
import '../../shared_prefference_service/shared_pref.dart';

Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    debugPrint('Permission granted');
  }
}

Future<String?> getFcmToken() async {
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    debugPrint("FCM Token: $token");
    return token;
  } catch (e) {
    debugPrint("Failed to get FCM token: $e");
    return null;
  }
}

Future<void> sendCurrentFcmTokenToBackend() async {
  final fcmToken = await getFcmToken();
  if (fcmToken == null || fcmToken.isEmpty) {
    debugPrint("FCM Token not available");
    return;
  }

  await sendFcmTokenToBackend(fcmToken);
}

Future<void> sendFcmTokenToBackend(String token) async {
  final userToken = await SharedPreferencesHelper.getAccessToken();
  if (userToken == null || userToken.isEmpty) {
    debugPrint("Access token not available for FCM token update");
    return;
  }

  try {
    debugPrint("FCM Token final token: $token");
    final response = await http.patch(
      Uri.parse('${ApiEndPoint.notificationFCM}'),
      headers: {
        "accept": "*/*",
        "Authorization": "Bearer $userToken",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"fcmToken": token}),
    );

    debugPrint("FCM Token Response: ${response.statusCode} ${response.body}");
  } catch (e) {
    debugPrint("FCM Token update failed: $e");
  }
}

void listenTokenRefresh() {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    sendFcmTokenToBackend(newToken);
  });
}

