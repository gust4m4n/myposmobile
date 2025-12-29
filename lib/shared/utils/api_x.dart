import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../login/login_page.dart';
import '../api_models.dart';
import '../config/api_config.dart';
import 'logger_x.dart';
import 'storage_service.dart';

/// Reusable API client class for all API calls in the application
/// Provides simplified methods for GET, POST, PUT, DELETE operations
/// Returns ApiResponse<T> for type-safe responses
class ApiX {
  static String? _authToken;
  static GlobalKey<NavigatorState>? _navigatorKey;
  static Function(String)? _onLoginSuccessCallback;

  /// Set navigator key for handling 401 redirects
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  /// Set callback for handling login success after 401 redirect
  static void setLoginSuccessCallback(Function(String) callback) {
    _onLoginSuccessCallback = callback;
  }

  /// Handle 401 Unauthorized - logout and redirect to login
  static Future<void> _handle401() async {
    appLog('🚨 401 Unauthorized - logging out');

    // Clear auth token
    clearAuthToken();

    // Clear stored token
    final storage = await StorageService.getInstance();
    await storage.clearToken();

    // Navigate to login page
    if (_navigatorKey?.currentContext != null) {
      final context = _navigatorKey!.currentContext!;
      // Use pushAndRemoveUntil to clear the navigation stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginPage(
            languageCode: 'id', // Default language
          ),
        ),
        (route) => false,
      );
    }
  }

  /// Try to parse response body as JSON, return null if not valid JSON
  static Map<String, dynamic>? _tryParseJson(String body) {
    try {
      final parsed = json.decode(body);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Map<String, String> _getHeaders({bool includeAuth = false}) {
    final headers = {'Content-Type': 'application/json'};

    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  static Future<http.Response?> _makeRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    final headers = _getHeaders(includeAuth: requiresAuth);
    final url = '${ApiConfig.baseUrl}$endpoint';
    final bodyString = body != null ? json.encode(body) : null;

    // Log request
    appLog(
      '',
      endpoint: url,
      method: method,
      headers: headers,
      body: bodyString,
    );

    try {
      final uri = Uri.parse(url);
      http.Response response;

      switch (method) {
        case 'GET':
          response = await http
              .get(uri, headers: headers)
              .timeout(ApiConfig.connectTimeout);
          break;
        case 'POST':
          response = await http
              .post(uri, headers: headers, body: bodyString)
              .timeout(ApiConfig.connectTimeout);
          break;
        case 'PUT':
          response = await http
              .put(uri, headers: headers, body: bodyString)
              .timeout(ApiConfig.connectTimeout);
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: headers)
              .timeout(ApiConfig.connectTimeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // Log response
      appLog(
        '',
        endpoint: url,
        status: response.statusCode,
        response: response.body,
      );

      return response;
    } catch (e) {
      appLog('', endpoint: url, error: e);
      return null;
    }
  }

  /// GET request
  /// [endpoint] - API endpoint (e.g., '/api/products')
  /// [requiresAuth] - whether to include auth token in headers
  /// [fromJson] - optional function to parse response data into type T
  static Future<ApiResponse<T>> get<T>(
    String endpoint, {
    bool requiresAuth = false,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _makeRequest(
      method: 'GET',
      endpoint: endpoint,
      requiresAuth: requiresAuth,
    );

    if (response == null) {
      return ApiResponse<T>(error: 'Request failed', statusCode: 0);
    }

    final jsonResponse = _tryParseJson(response.body);

    if (jsonResponse == null) {
      // Response is not valid JSON
      return ApiResponse<T>(
        error: 'Invalid JSON response: ${response.body}',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse<T>.fromJson(
        jsonResponse,
        fromJson,
        response.statusCode,
      );
    } else {
      // Handle 401 Unauthorized
      if (response.statusCode == 401) {
        await _handle401();
      }

      return ApiResponse<T>(
        error:
            jsonResponse['error'] ??
            jsonResponse['message'] ??
            'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// POST request
  /// [endpoint] - API endpoint (e.g., '/api/orders')
  /// [body] - request body data
  /// [requiresAuth] - whether to include auth token in headers
  /// [fromJson] - optional function to parse response data into type T
  static Future<ApiResponse<T>> post<T>(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = false,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _makeRequest(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      requiresAuth: requiresAuth,
    );

    if (response == null) {
      return ApiResponse<T>(error: 'Request failed', statusCode: 0);
    }

    final jsonResponse = _tryParseJson(response.body);

    if (jsonResponse == null) {
      // Response is not valid JSON
      return ApiResponse<T>(
        error: 'Invalid JSON response: ${response.body}',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse<T>.fromJson(
        jsonResponse,
        fromJson,
        response.statusCode,
      );
    } else {
      // Handle 401 Unauthorized
      if (response.statusCode == 401) {
        await _handle401();
      }

      return ApiResponse<T>(
        error:
            jsonResponse['error'] ??
            jsonResponse['message'] ??
            'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// PUT request
  /// [endpoint] - API endpoint (e.g., '/api/products/1')
  /// [body] - request body data
  /// [requiresAuth] - whether to include auth token in headers
  /// [fromJson] - optional function to parse response data into type T
  static Future<ApiResponse<T>> put<T>(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = false,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _makeRequest(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      requiresAuth: requiresAuth,
    );

    if (response == null) {
      return ApiResponse<T>(error: 'Request failed', statusCode: 0);
    }

    final jsonResponse = _tryParseJson(response.body);

    if (jsonResponse == null) {
      // Response is not valid JSON
      return ApiResponse<T>(
        error: 'Invalid JSON response: ${response.body}',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse<T>.fromJson(
        jsonResponse,
        fromJson,
        response.statusCode,
      );
    } else {
      // Handle 401 Unauthorized
      if (response.statusCode == 401) {
        await _handle401();
      }

      return ApiResponse<T>(
        error:
            jsonResponse['error'] ??
            jsonResponse['message'] ??
            'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// DELETE request
  /// [endpoint] - API endpoint (e.g., '/api/products/1')
  /// [requiresAuth] - whether to include auth token in headers
  /// [fromJson] - optional function to parse response data into type T
  static Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    bool requiresAuth = false,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _makeRequest(
      method: 'DELETE',
      endpoint: endpoint,
      requiresAuth: requiresAuth,
    );

    if (response == null) {
      return ApiResponse<T>(error: 'Request failed', statusCode: 0);
    }

    final jsonResponse = _tryParseJson(response.body);

    if (jsonResponse == null) {
      // Response is not valid JSON
      return ApiResponse<T>(
        error: 'Invalid JSON response: ${response.body}',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse<T>.fromJson(
        jsonResponse,
        fromJson,
        response.statusCode,
      );
    } else {
      // Handle 401 Unauthorized
      if (response.statusCode == 401) {
        await _handle401();
      }

      return ApiResponse<T>(
        error:
            jsonResponse['error'] ??
            jsonResponse['message'] ??
            'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Set authentication token
  static void setAuthToken(String token) {
    _authToken = token;
    appLog('🔐 Auth token set');
  }

  /// Clear authentication token
  static void clearAuthToken() {
    _authToken = null;
    appLog('🔓 Auth token cleared');
  }

  /// Get current auth token
  static String? get authToken => _authToken;

  /// Upload file (multipart/form-data)
  /// [endpoint] - API endpoint (e.g., '/profile/photo')
  /// [filePath] - absolute path to the file to upload
  /// [fieldName] - form field name (default: 'image')
  /// [requiresAuth] - whether to include auth token in headers
  static Future<ApiResponse<T>> uploadFile<T>(
    String endpoint, {
    required String filePath,
    String fieldName = 'image',
    bool requiresAuth = true,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}$endpoint';
      final uri = Uri.parse(url);

      final request = http.MultipartRequest('POST', uri);

      // Add auth header if required
      if (requiresAuth && _authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      // Add file
      appLog('📤 Preparing to upload file from: $filePath');
      appLog('📤 Field name: $fieldName');

      // Create multipart file with explicit content type
      final file = await http.MultipartFile.fromPath(
        fieldName,
        filePath,
        // Try to set content type based on file extension
      );

      request.files.add(file);

      appLog(
        '📤 File added to request: ${file.filename}, size: ${file.length} bytes, contentType: ${file.contentType}',
      );
      appLog('📤 Uploading to: $endpoint');
      appLog('📤 Request files count: ${request.files.length}');
      appLog('📤 Request headers: ${request.headers}');

      final streamedResponse = await request.send().timeout(
        ApiConfig.connectTimeout,
      );
      final response = await http.Response.fromStream(streamedResponse);

      appLog(
        '',
        endpoint: url,
        status: response.statusCode,
        response: response.body,
      );

      final jsonResponse = _tryParseJson(response.body);

      if (jsonResponse == null) {
        // Response is not valid JSON
        return ApiResponse<T>(
          error: 'Invalid JSON response: ${response.body}',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>.fromJson(jsonResponse, null, response.statusCode);
      } else {
        // Handle 401 Unauthorized
        if (response.statusCode == 401) {
          await _handle401();
        }

        return ApiResponse<T>(
          error:
              jsonResponse['error'] ??
              jsonResponse['message'] ??
              'Upload failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      appLog('❌ Upload error', error: e);
      return ApiResponse<T>(error: 'Upload failed: $e', statusCode: 0);
    }
  }
}
