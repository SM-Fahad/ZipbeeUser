import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ZipBee/core/service/token_refresh_service.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';

class AppHttpClient {
  static final http.Client _inner = http.Client();

  static Uri _toUri(dynamic url) {
    if (url is Uri) return url;
    return Uri.parse(url.toString());
  }

  // ─── Global Request / Response Logger ────────────────────────────────────
  static void _log({
    required String method,
    required Uri uri,
    Object? requestBody,
    required http.Response response,
    bool isRetry = false,
  }) {
    final tag = isRetry ? ' [RETRY]' : '';
    const sep = '────────────────────────────────────────────────────────────';

    // Pretty-print JSON when possible, else return raw
    String pretty(String? raw) {
      if (raw == null || raw.isEmpty) return '(empty)';
      try {
        return const JsonEncoder.withIndent('  ').convert(jsonDecode(raw));
      } catch (_) {
        return raw;
      }
    }

    final reqBody = requestBody == null
        ? '(none)'
        : requestBody is String
            ? pretty(requestBody)
            : requestBody.toString();

    debugPrint('\n$sep');
    debugPrint('🌐 $method$tag  $uri');
    debugPrint('📤 REQUEST BODY:\n$reqBody');
    debugPrint('📥 RESPONSE [${response.statusCode}]:\n${pretty(response.body)}');
    debugPrint(sep);
  }

  /// Checks if an HTTP response represents an unauthorized/expired token (401)
  static bool isUnauthorized(http.Response response) {
    if (response.statusCode == 401) return true;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        if (decoded['statusCode'] == 401 ||
            decoded['error']?.toString().toLowerCase() == 'unauthorized' ||
            decoded['message']?.toString().toLowerCase().contains('invalid or expired token') == true ||
            decoded['message']?.toString().toLowerCase().contains('expired') == true ||
            decoded['message']?.toString().toLowerCase().contains('unauthorized') == true) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  /// Injects current Bearer token into headers if an Authorization header is present
  static Future<Map<String, String>> _prepareHeaders(Map<String, String>? headers) async {
    final updated = Map<String, String>.from(headers ?? {});
    final token = await SharedPreferencesHelper.getAccessToken();
    if (token != null && token.isNotEmpty) {
      if (updated.containsKey('Authorization') || updated.containsKey('authorization')) {
        updated['Authorization'] = 'Bearer $token';
      }
    }
    return updated;
  }

  /// Sends a GET request with automatic token refresh on 401
  static Future<http.Response> get(
    dynamic url, {
    Map<String, String>? headers,
    bool isRetry = false,
  }) async {
    final uri = _toUri(url);
    final effectiveHeaders = await _prepareHeaders(headers);
    var response = await _inner.get(uri, headers: effectiveHeaders);
    _log(method: 'GET', uri: uri, response: response);

    if (isUnauthorized(response) && !isRetry) {
      debugPrint('⚠️ [AppHttpClient] 401 Unauthorized for GET $uri. Refreshing token...');
      final refreshed = await TokenRefreshService.refreshToken();
      if (refreshed) {
        final retriedHeaders = await _prepareHeaders(headers);
        response = await _inner.get(uri, headers: retriedHeaders);
        _log(method: 'GET', uri: uri, response: response, isRetry: true);
      }
    }
    return response;
  }

  /// Sends a POST request with automatic token refresh on 401
  static Future<http.Response> post(
    dynamic url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool isRetry = false,
  }) async {
    final uri = _toUri(url);
    final effectiveHeaders = await _prepareHeaders(headers);
    var response = await _inner.post(
      uri,
      headers: effectiveHeaders,
      body: body,
      encoding: encoding,
    );
    _log(method: 'POST', uri: uri, requestBody: body, response: response);

    if (isUnauthorized(response) && !isRetry) {
      debugPrint('⚠️ [AppHttpClient] 401 Unauthorized for POST $uri. Refreshing token...');
      final refreshed = await TokenRefreshService.refreshToken();
      if (refreshed) {
        final retriedHeaders = await _prepareHeaders(headers);
        response = await _inner.post(
          uri,
          headers: retriedHeaders,
          body: body,
          encoding: encoding,
        );
        _log(method: 'POST', uri: uri, requestBody: body, response: response, isRetry: true);
      }
    }
    return response;
  }

  /// Sends a PUT request with automatic token refresh on 401
  static Future<http.Response> put(
    dynamic url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool isRetry = false,
  }) async {
    final uri = _toUri(url);
    final effectiveHeaders = await _prepareHeaders(headers);
    var response = await _inner.put(
      uri,
      headers: effectiveHeaders,
      body: body,
      encoding: encoding,
    );
    _log(method: 'PUT', uri: uri, requestBody: body, response: response);

    if (isUnauthorized(response) && !isRetry) {
      debugPrint('⚠️ [AppHttpClient] 401 Unauthorized for PUT $uri. Refreshing token...');
      final refreshed = await TokenRefreshService.refreshToken();
      if (refreshed) {
        final retriedHeaders = await _prepareHeaders(headers);
        response = await _inner.put(
          uri,
          headers: retriedHeaders,
          body: body,
          encoding: encoding,
        );
        _log(method: 'PUT', uri: uri, requestBody: body, response: response, isRetry: true);
      }
    }
    return response;
  }

  /// Sends a PATCH request with automatic token refresh on 401
  static Future<http.Response> patch(
    dynamic url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool isRetry = false,
  }) async {
    final uri = _toUri(url);
    final effectiveHeaders = await _prepareHeaders(headers);
    var response = await _inner.patch(
      uri,
      headers: effectiveHeaders,
      body: body,
      encoding: encoding,
    );
    _log(method: 'PATCH', uri: uri, requestBody: body, response: response);

    if (isUnauthorized(response) && !isRetry) {
      debugPrint('⚠️ [AppHttpClient] 401 Unauthorized for PATCH $uri. Refreshing token...');
      final refreshed = await TokenRefreshService.refreshToken();
      if (refreshed) {
        final retriedHeaders = await _prepareHeaders(headers);
        response = await _inner.patch(
          uri,
          headers: retriedHeaders,
          body: body,
          encoding: encoding,
        );
        _log(method: 'PATCH', uri: uri, requestBody: body, response: response, isRetry: true);
      }
    }
    return response;
  }

  /// Sends a DELETE request with automatic token refresh on 401
  static Future<http.Response> delete(
    dynamic url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool isRetry = false,
  }) async {
    final uri = _toUri(url);
    final effectiveHeaders = await _prepareHeaders(headers);
    var response = await _inner.delete(
      uri,
      headers: effectiveHeaders,
      body: body,
      encoding: encoding,
    );
    _log(method: 'DELETE', uri: uri, requestBody: body, response: response);

    if (isUnauthorized(response) && !isRetry) {
      debugPrint('⚠️ [AppHttpClient] 401 Unauthorized for DELETE $uri. Refreshing token...');
      final refreshed = await TokenRefreshService.refreshToken();
      if (refreshed) {
        final retriedHeaders = await _prepareHeaders(headers);
        response = await _inner.delete(
          uri,
          headers: retriedHeaders,
          body: body,
          encoding: encoding,
        );
        _log(method: 'DELETE', uri: uri, requestBody: body, response: response, isRetry: true);
      }
    }
    return response;
  }
}
