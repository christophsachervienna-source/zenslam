import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:zenslam/app/auth/login/view/login_screen.dart';
import 'package:zenslam/app/onboarding_flow/view/masterpiece/awakening_screen.dart';
import 'package:zenslam/core/const/endpoints.dart';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = Urls.baseUrl;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);

  /// Flag to prevent multiple simultaneous logout redirects
  static bool _isHandlingUnauthorized = false;

  /// Flag to prevent multiple simultaneous token refresh attempts
  static bool _isRefreshing = false;
  static Future<String?>? _refreshFuture;

  /// Attempt to refresh the access token using the stored refresh token.
  /// Returns the new access token on success, null on failure.
  static Future<String?> _refreshAccessToken() async {
    // If already refreshing, wait for that result
    if (_isRefreshing && _refreshFuture != null) {
      return _refreshFuture;
    }

    _isRefreshing = true;
    _refreshFuture = _doRefresh();
    final result = await _refreshFuture;
    _isRefreshing = false;
    _refreshFuture = null;
    return result;
  }

  static Future<String?> _doRefresh() async {
    try {
      final refreshToken = await SharedPrefHelper.getRefreshToken();
      if (refreshToken == null) return null;

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/refresh-token'),
            headers: headers,
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null) {
          await SharedPrefHelper.saveAccessToken(newAccessToken);
          if (newRefreshToken != null) {
            await SharedPrefHelper.saveRefreshToken(newRefreshToken);
          }
          debugPrint('🔄 Token refreshed successfully');
          return newAccessToken;
        }
      }
    } catch (e) {
      debugPrint('🔄 Token refresh failed: $e');
    }
    return null;
  }

  // Common headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> headersWithAuth(String token) {
    final authToken = token.startsWith('Bearer ') ? token : 'Bearer $token';

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': authToken,
    };
  }

  // GET Request with retry logic
  static Future<ApiResponse> get({
    required String endpoint,
    Map<String, String>? queryParameters,
    String? token,
    bool debug = false,
    bool handleAuth = true,
  }) async {
    // Short-circuit when no backend is configured
    if (baseUrl.isEmpty) {
      return ApiResponse(
        success: false,
        error: 'No backend configured',
        statusCode: 0,
      );
    }

    try {
      // Build URL with query parameters
      Uri uri = Uri.parse('$baseUrl/$endpoint');

      if (queryParameters != null) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      if (debug) {
        debugPrint('🌐 GET Request:');
        debugPrint('URL: $uri');
        debugPrint(
          'Headers: ${token != null ? headersWithAuth(token) : headers}',
        );
      }

      final response = await _executeWithRetry(
        () => http
            .get(uri, headers: token != null ? headersWithAuth(token) : headers)
            .timeout(const Duration(seconds: 30)),
        debug: debug,
      );

      if (debug) {
        debugPrint('📥 GET Response:');
        debugPrint(
          'Status Code for $baseUrl/$endpoint: ${response.statusCode}',
        );
        log(
          '📥 📥 📥 📥 Response Body for $baseUrl/$endpoint: 📥 📥 📥 📥 ${response.body}',
        );
      }

      // If 401 and we have a token, try refreshing before giving up
      if (response.statusCode == 401 && handleAuth && token != null) {
        final newToken = await _refreshAccessToken();
        if (newToken != null) {
          final retryResponse = await _executeWithRetry(
            () => http
                .get(uri, headers: headersWithAuth(newToken))
                .timeout(const Duration(seconds: 30)),
            debug: debug,
          );
          return _handleResponse(retryResponse, handleAuth: false);
        }
      }

      return _handleResponse(response, handleAuth: handleAuth);
    } on http.ClientException catch (e) {
      if (debug) {
        debugPrint('❌ GET Client Exception: $e');
      }
      return ApiResponse(
        success: false,
        error: 'Network error: ${e.message}',
        statusCode: 0,
      );
    } on Exception catch (e) {
      if (debug) {
        debugPrint('❌ GET Exception: $e');
      }
      return ApiResponse(
        success: false,
        error: 'An error occurred: $e',
        statusCode: 0,
      );
    }
  }

  // POST Request with retry logic
  static Future<ApiResponse> post({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
    bool debug = false,
    bool handleAuth = true,
  }) async {
    // Short-circuit when no backend is configured
    if (baseUrl.isEmpty) {
      return ApiResponse(
        success: false,
        error: 'No backend configured',
        statusCode: 0,
      );
    }

    try {
      final Uri uri = Uri.parse('$baseUrl/$endpoint');

      if (debug) {
        debugPrint('🌐 POST Request:');
        debugPrint('URL: $uri');
        debugPrint('Body: ${jsonEncode(body)}');
      }

      final response = await _executeWithRetry(
        () => http
            .post(
              uri,
              headers: token != null ? headersWithAuth(token) : headers,
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 30)),
        debug: debug,
      );

      if (debug) {
        debugPrint('📥 POST Response:');
        debugPrint(
          'Status Code for $baseUrl/$endpoint: ${response.statusCode}',
        );
        debugPrint('Response Body for $baseUrl/$endpoint: ${response.body}');
      }

      // If 401 and we have a token, try refreshing before giving up
      if (response.statusCode == 401 && handleAuth && token != null) {
        final newToken = await _refreshAccessToken();
        if (newToken != null) {
          final retryResponse = await _executeWithRetry(
            () => http
                .post(
                  uri,
                  headers: headersWithAuth(newToken),
                  body: jsonEncode(body),
                )
                .timeout(const Duration(seconds: 30)),
            debug: debug,
          );
          return _handleResponse(retryResponse, handleAuth: false);
        }
      }

      return _handleResponse(response, handleAuth: handleAuth);
    } on http.ClientException catch (e) {
      if (debug) {
        debugPrint('❌ POST Client Exception: $e');
      }
      return ApiResponse(
        success: false,
        error: 'Network error: ${e.message}',
        statusCode: 0,
      );
    } on Exception catch (e) {
      if (debug) {
        debugPrint('❌ POST Exception: $e');
      }
      return ApiResponse(
        success: false,
        error: 'An error occurred: $e',
        statusCode: 0,
      );
    }
  }

  // PATCH Request with retry logic
  static Future<ApiResponse> patch({
    required String endpoint,
    required Map<String, dynamic> data,
    String? token,
    bool debug = false,
    bool handleAuth = true,
  }) async {
    // Short-circuit when no backend is configured
    if (baseUrl.isEmpty) {
      return ApiResponse(
        success: false,
        error: 'No backend configured',
        statusCode: 0,
      );
    }

    try {
      Uri uri = Uri.parse('$baseUrl/$endpoint');

      if (debug) {
        debugPrint('🌐 PATCH Request:');
        debugPrint('URL: $uri');
        debugPrint(
          'Headers: ${token != null ? headersWithAuth(token) : headers}',
        );
        debugPrint('Body: $data');
      }

      final response = await _executeWithRetry(
        () => http
            .patch(
              uri,
              headers: token != null ? headersWithAuth(token) : headers,
              body: json.encode(data),
            )
            .timeout(const Duration(seconds: 30)),
        debug: debug,
      );

      if (debug) {
        debugPrint('📥 PATCH Response:');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
      }

      // If 401 and we have a token, try refreshing before giving up
      if (response.statusCode == 401 && handleAuth && token != null) {
        final newToken = await _refreshAccessToken();
        if (newToken != null) {
          final retryResponse = await _executeWithRetry(
            () => http
                .patch(
                  uri,
                  headers: headersWithAuth(newToken),
                  body: json.encode(data),
                )
                .timeout(const Duration(seconds: 30)),
            debug: debug,
          );
          return _handleResponse(retryResponse, handleAuth: false);
        }
      }

      return _handleResponse(response, handleAuth: handleAuth);
    } on http.ClientException catch (e) {
      if (debug) {
        debugPrint('❌ PATCH Client Exception: $e');
      }
      return ApiResponse(
        success: false,
        error: 'Network error: ${e.message}',
        statusCode: 0,
      );
    } on Exception catch (e) {
      if (debug) {
        debugPrint('❌ PATCH Exception: $e');
      }
      return ApiResponse(
        success: false,
        error: 'An error occurred: $e',
        statusCode: 0,
      );
    }
  }

  // Multipart POST Request
  static Future<ApiResponse> multipart({
    required String endpoint,
    required Map<String, String> data,
    required Map<String, File> files,
    String? token,
    bool debug = false,
  }) async {
    if (debug) {
      debugPrint('🔍 [API CALL] Making MULTIPART request to: $endpoint');
      debugPrint('📋 [FULL URL] $baseUrl/$endpoint');
    }
    try {
      if (debug) {
        debugPrint('🌐 Multipart POST API Call: $endpoint');
        debugPrint('📤 Data: $data');
        debugPrint('📁 Files: ${files.keys.toList()}');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/$endpoint'),
      );

      // Add headers
      if (token != null) {
        request.headers['Authorization'] = token.startsWith('Bearer ') ? token : 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      // Add fields
      data.forEach((key, value) {
        request.fields[key] = value;
      });

      // Add files
      files.forEach((key, file) async {
        var multipartFile = await http.MultipartFile.fromPath(
          key,
          file.path,
          filename: '${key}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(multipartFile);
      });

      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      if (debug) {
        debugPrint('📥 Response Status: ${response.statusCode}');
        debugPrint('📥 Response Body: $responseString');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          data: json.decode(responseString),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          error: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      if (debug) {
        debugPrint('❌ Multipart Client Exception: $e');
      }
      return ApiResponse(
        success: false,
        error: 'Network error: ${e.message}',
        statusCode: 0,
      );
    } on Exception catch (e) {
      if (debug) {
        debugPrint('❌ Multipart Exception: $e');
      }
      return ApiResponse(
        success: false,
        error: 'An error occurred: $e',
        statusCode: 0,
      );
    }
  }

  // Multipart PATCH Request (for updating profile with file)
  static Future<ApiResponse> multipartPatch({
    required String endpoint,
    required Map<String, dynamic> data,
    Map<String, File>? files,
    String? token,
    bool debug = false,
  }) async {
    try {
      if (debug) {
        debugPrint('🌐 Multipart PATCH API Call: $endpoint');
        debugPrint('📤 Data: $data');
        debugPrint('📁 Files: ${files?.keys.toList() ?? []}');
      }

      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/$endpoint'),
      );

      // Add headers
      if (token != null) {
        request.headers['Authorization'] = token.startsWith('Bearer ') ? token : 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      // Add fields - convert values to strings
      // Note: For multipart requests, all values must be strings
      // The backend will parse JSON strings if needed
      data.forEach((key, value) {
        if (value is String) {
          request.fields[key] = value;
        } else if (value is List) {
          // For lists, send as JSON array string
          request.fields[key] = jsonEncode(value);
        } else if (value is Map) {
          // For maps, send as JSON object string
          request.fields[key] = jsonEncode(value);
        } else {
          // For primitives, convert to string
          request.fields[key] = value.toString();
        }
      });

      // Add files if provided
      if (files != null && files.isNotEmpty) {
        for (var entry in files.entries) {
          // Get file extension
          final filePath = entry.value.path;
          final extension = filePath.split('.').last.toLowerCase();

          // Determine MIME type based on extension
          String? contentType;
          String filename;

          if (extension == 'jpg' || extension == 'jpeg') {
            contentType = 'image/jpeg';
            filename =
                '${entry.key}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          } else if (extension == 'png') {
            contentType = 'image/png';
            filename =
                '${entry.key}_${DateTime.now().millisecondsSinceEpoch}.png';
          } else if (extension == 'gif') {
            contentType = 'image/gif';
            filename =
                '${entry.key}_${DateTime.now().millisecondsSinceEpoch}.gif';
          } else if (extension == 'webp') {
            contentType = 'image/webp';
            filename =
                '${entry.key}_${DateTime.now().millisecondsSinceEpoch}.webp';
          } else {
            // Default to JPEG
            contentType = 'image/jpeg';
            filename =
                '${entry.key}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          }

          if (debug) {
            debugPrint('📁 File: $filePath');
            debugPrint('📁 Extension: $extension');
            debugPrint('📁 Content-Type: $contentType');
            debugPrint('📁 Filename: $filename');
          }

          var multipartFile = await http.MultipartFile.fromPath(
            entry.key,
            entry.value.path,
            filename: filename,
            contentType: MediaType.parse(contentType),
          );
          request.files.add(multipartFile);
        }
      }

      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      if (debug) {
        debugPrint('📥 Response Status: ${response.statusCode}');
        debugPrint('📥 Response Body: $responseString');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          data: json.decode(responseString),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          error: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (debug) {
        debugPrint('💥 Multipart Error: $e');
      }
      return ApiResponse(success: false, error: e.toString(), statusCode: 0);
    }
  }

  /// Handle 401 Unauthorized - clear tokens and redirect appropriately
  static Future<void> _handleUnauthorized() async {
    if (_isHandlingUnauthorized) return;
    _isHandlingUnauthorized = true;

    try {
      // Check if user actually had a valid token (was logged in)
      final hadToken = await SharedPrefHelper.getAccessToken();

      debugPrint('🔒 Unauthorized - had token: ${hadToken != null}');
      await SharedPrefHelper.clearTokens();

      if (hadToken != null) {
        // User was logged in, session expired - go to login
        debugPrint('🔒 Session expired - redirecting to login');
        if (Get.context != null) {
          Get.snackbar(
            'Session Expired',
            'Please log in again to continue',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        }
        Get.offAll(() => LoginScreen());
      } else {
        // User was never logged in - go to onboarding
        debugPrint('🔒 Not logged in - redirecting to onboarding');
        Get.offAll(() => const AwakeningScreen());
      }
    } finally {
      // Reset flag after a short delay to prevent rapid repeated calls
      Future.delayed(const Duration(seconds: 2), () {
        _isHandlingUnauthorized = false;
      });
    }
  }

  /// Check if error is retryable (network issues, timeouts)
  static bool _isRetryableError(dynamic error) {
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;
    if (error is http.ClientException) return true;
    return false;
  }

  /// Execute request with retry logic for transient failures
  static Future<http.Response> _executeWithRetry(
    Future<http.Response> Function() request, {
    int retries = _maxRetries,
    bool debug = false,
  }) async {
    int attempts = 0;
    while (true) {
      try {
        attempts++;
        return await request();
      } catch (e) {
        if (!_isRetryableError(e) || attempts >= retries) {
          rethrow;
        }
        if (debug) {
          debugPrint('⚠️ Request failed (attempt $attempts/$retries), retrying in ${_retryDelay.inSeconds}s: $e');
        }
        await Future.delayed(_retryDelay * attempts); // Exponential backoff
      }
    }
  }

  // Handle HTTP response
  static ApiResponse _handleResponse(http.Response response, {bool handleAuth = true}) {
    // Handle 401 Unauthorized
    if (response.statusCode == 401 && handleAuth) {
      _handleUnauthorized();
      return ApiResponse(
        success: false,
        error: 'Session expired. Please log in again.',
        statusCode: 401,
      );
    }

    try {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          success: true,
          data: responseData,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          error:
              responseData['message'] ??
              'Request failed with status ${response.statusCode}',
          data: responseData,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Failed to parse response: $e',
        statusCode: response.statusCode,
      );
    }
  }
}

// Response model
class ApiResponse {
  final bool success;
  final dynamic data;
  final String? error;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    required this.statusCode,
  });

  @override
  String toString() {
    return 'ApiResponse(success: $success, data: $data, error: $error, statusCode: $statusCode)';
  }
}
