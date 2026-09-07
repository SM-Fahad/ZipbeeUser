import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:ZipBee/routes/app_routes.dart';

class TokenRefreshService {
  static bool _isRefreshing = false;
  static Completer<bool>? _refreshCompleter;

  /// Refreshes the access token using the stored refresh_token.
  /// Deduplicates concurrent refresh requests using a Completer.
  static Future<bool> refreshToken() async {
    if (_isRefreshing) {
      debugPrint('⏳ [TokenRefreshService] Token refresh already in progress. Awaiting result...');
      return await (_refreshCompleter?.future ?? Future.value(false));
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final storedRefreshToken = await SharedPreferencesHelper.getRefreshToken();
      if (storedRefreshToken == null || storedRefreshToken.trim().isEmpty) {
        debugPrint('❌ [TokenRefreshService] No refresh token found in storage.');
        _handleSessionExpired();
        _completeRefresh(false);
        return false;
      }

      final refreshUrl = ApiEndPoint.refreshToken;
      debugPrint('🔄 [TokenRefreshService] Requesting new access token from $refreshUrl...');

      final response = await http.post(
        Uri.parse(refreshUrl),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh_token': storedRefreshToken.trim(),
        }),
      );

      debugPrint('🔄 [TokenRefreshService] Refresh response code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final newAccessToken = decoded['access_token']?.toString();
        final newRefreshToken = decoded['refresh_token']?.toString() ?? storedRefreshToken;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await SharedPreferencesHelper.saveToken(newAccessToken);
          if (newRefreshToken.isNotEmpty) {
            await SharedPreferencesHelper.saveRefreshToken(newRefreshToken);
          }
          debugPrint('✅ [TokenRefreshService] Access & refresh tokens updated successfully.');
          _completeRefresh(true);
          return true;
        }
      }

      debugPrint('❌ [TokenRefreshService] Token refresh failed: ${response.body}');
      _handleSessionExpired();
      _completeRefresh(false);
      return false;
    } catch (e) {
      debugPrint('❌ [TokenRefreshService] Exception during token refresh: $e');
      _handleSessionExpired();
      _completeRefresh(false);
      return false;
    }
  }

  static void _completeRefresh(bool success) {
    _isRefreshing = false;
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      _refreshCompleter!.complete(success);
    }
    _refreshCompleter = null;
  }

  static void _handleSessionExpired() async {
    debugPrint('🚨 [TokenRefreshService] Session expired. Clearing credentials.');
    await SharedPreferencesHelper.logout();
    if (Get.currentRoute != AppRoutes.loginScreen) {
      Get.offAllNamed(AppRoutes.loginScreen);
    }
  }
}
