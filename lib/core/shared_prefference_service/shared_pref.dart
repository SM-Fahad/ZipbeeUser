import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  // ================= KEYS =================
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userIdKey = 'userId';
  static const String _selectedRoleKey = 'selectedRole';
  static const String _categoriesKey = 'categories';
  static const String _isLoginKey = 'isLogin';
  static const String _welcomeDialogKey = 'isDriverVerificationDialogShown';
  static const String _showOnboardKey = 'showOnboard';
  static const String _fcmTokenKey = 'fcmToken'; // ✅ NEW

  // ================= TOKEN =================

  /// Save access token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
    await prefs.setBool(_isLoginKey, true);
  }

  /// Save refresh token (optional)
  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  /// Get access token (primary)
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('Access token retrieved: ${prefs.getString(_accessTokenKey)}');
    return prefs.getString(_accessTokenKey);
  }

  /// ✅ Alias (for safety – used in HomeController)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('Refresh token retrieved: ${prefs.getString(_refreshTokenKey)}');
    return prefs.getString(_refreshTokenKey);
  }

  // ================= FCM TOKEN =================

  /// Save FCM token
  static Future<void> saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmTokenKey, token);
  }

  /// Get FCM token
  static Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fcmTokenKey);
  }

  // ================= LOGIN STATE =================

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoginKey) ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.setBool(_isLoginKey, false);
  }

  // ================= USER =================

  static Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, id);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Returns stored userId; if missing, tries to decode it from access token
  /// and persists it for future reads.
  static Future<String?> getOrExtractUserId() async {
    final stored = await getUserId();
    if (stored != null && stored.isNotEmpty) return stored;

    final token = await getAccessToken();
    final extracted = extractUserIdFromToken(token);
    if (extracted != null && extracted.isNotEmpty) {
      await saveUserId(extracted);
    }
    return extracted;
  }

  /// Tries common JWT/user payload claim names and nested shapes.
  static String? extractUserIdFromToken(String? token) {
    if (token == null || token.isEmpty) return null;

    final parts = token.split('.');
    if (parts.length < 2) return null;

    try {
      final payload = _decodeJwtPart(parts[1]);

      final directCandidates = [
        payload['userId'],
        payload['user_id'],
        payload['id'],
        payload['sub'],
      ];
      for (final candidate in directCandidates) {
        final value = _valueToString(candidate);
        if (value != null) return value;
      }

      final user = payload['user'];
      if (user is Map) {
        final nestedCandidates = [
          user['id'],
          user['userId'],
          user['user_id'],
          user['sub'],
        ];
        for (final candidate in nestedCandidates) {
          final value = _valueToString(candidate);
          if (value != null) return value;
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static Map<String, dynamic> _decodeJwtPart(String part) {
    final normalized = base64Url.normalize(part);
    final payloadMap = jsonDecode(utf8.decode(base64Url.decode(normalized)));
    return Map<String, dynamic>.from(payloadMap as Map);
  }

  static String? _valueToString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  // ================= ROLE =================

  static Future<void> saveSelectedRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedRoleKey, role);
  }

  static Future<String?> getSelectedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedRoleKey);
  }

  // ================= CATEGORIES =================

  /// Save categories (id + name)
  static Future<void> saveCategories(
    List<Map<String, String>> categories,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_categoriesKey, jsonEncode(categories));
  }

  /// Get categories
  static Future<List<Map<String, String>>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_categoriesKey);
    if (json == null) return [];
    return List<Map<String, String>>.from(jsonDecode(json));
  }

  // ================= ONBOARD / DIALOG =================

  static Future<void> setWelcomeDialogShown(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeDialogKey, value);
  }

  static Future<bool> isWelcomeDialogShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_welcomeDialogKey) ?? false;
  }

  static Future<void> setShowOnboard(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showOnboardKey, value);
  }

  static Future<bool> getShowOnboard() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showOnboardKey) ?? false;
  }

  // ================= CLEAR ALL =================

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
