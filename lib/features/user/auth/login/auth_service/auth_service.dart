import 'dart:convert';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/service/app_http_client.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // ------------------- SIGNUP -------------------
  static Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String phone,
    required String password,
    String? referralCode,
    String roleName = "USER",
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndPoint.signUp),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "phone": phone,
          "password": password,
          "referral_code": referralCode ?? "",
          "role_name": roleName,
        }),
      );
      debugPrint(
        '📡 Signup Response: ${response.statusCode} | ${response.body}',
      );
      return {
        "statusCode": response.statusCode,
        "body": jsonDecode(response.body),
      };
    } catch (e) {
      debugPrint('❌ Signup Error: $e');
      return {
        "statusCode": 500,
        "body": {"message": e.toString()},
      };
    }
  }

  // ------------------- VERIFY OTP -------------------
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndPoint.verifyOtp),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );
      debugPrint(
        '📡 Verify OTP Response: ${response.statusCode} | ${response.body}',
      );
      return {
        "statusCode": response.statusCode,
        "body": jsonDecode(response.body),
      };
    } catch (e) {
      debugPrint('❌ Verify OTP Error: $e');
      return {
        "statusCode": 500,
        "body": {"message": e.toString()},
      };
    }
  }

  // ------------------- LOGIN -------------------
  static Future<Map<String, dynamic>> login(
    Map<String, dynamic> loginData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndPoint.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(loginData),
      );

      debugPrint("📡 Login Request Data: ${jsonEncode(loginData)}");
      debugPrint(
        '📡 Login Response: ${response.statusCode} | ${response.body}',
      );

      return {
        "statusCode": response.statusCode,
        "body": jsonDecode(response.body),
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "body": {"message": e.toString()},
      };
    }
  }

  // ------------------- GET USER PROFILE -------------------
  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await AppHttpClient.get(
        Uri.parse(ApiEndPoint.getUserProfile),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      debugPrint(
        '📡 GetUserProfile Response: ${response.statusCode} | ${response.body}',
      );
      return {
        "statusCode": response.statusCode,
        "body": jsonDecode(response.body),
      };
    } catch (e) {
      debugPrint('❌ GetUserProfile Error: $e');
      return {
        "statusCode": 500,
        "body": {"message": e.toString()},
      };
    }
  }
}
