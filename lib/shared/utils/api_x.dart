import 'dart:convert';

import '../api_models.dart';
import 'http_client.dart';

/// Reusable API client class for all API calls in the application
/// Provides simplified methods for GET, POST, PUT, DELETE operations
/// Returns ApiResponse<T> for type-safe responses
class ApiX {
  static final HttpClient _client = HttpClient();

  /// GET request
  /// [endpoint] - API endpoint (e.g., '/api/products')
  /// [requiresAuth] - whether to include auth token in headers
  /// [fromJson] - optional function to parse response data into type T
  static Future<ApiResponse<T>> get<T>(
    String endpoint, {
    bool requiresAuth = false,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _client.get(endpoint, requiresAuth: requiresAuth);
    final Map<String, dynamic> jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return ApiResponse<T>.fromJson(jsonResponse, fromJson);
    } else {
      return ApiResponse<T>(
        error:
            jsonResponse['error'] ??
            jsonResponse['message'] ??
            'Request failed with status ${response.statusCode}',
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
    final response = await _client.post(
      endpoint,
      body: body,
      requiresAuth: requiresAuth,
    );

    final Map<String, dynamic> jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return ApiResponse<T>.fromJson(jsonResponse, fromJson);
    } else {
      return ApiResponse<T>(
        error:
            jsonResponse['error'] ??
            jsonResponse['message'] ??
            'Request failed with status ${response.statusCode}',
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
    final response = await _client.put(
      endpoint,
      body: body,
      requiresAuth: requiresAuth,
    );

    final Map<String, dynamic> jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return ApiResponse<T>.fromJson(jsonResponse, fromJson);
    } else {
      return ApiResponse<T>(
        error:
            jsonResponse['error'] ??
            jsonResponse['message'] ??
            'Request failed with status ${response.statusCode}',
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
    final response = await _client.delete(endpoint, requiresAuth: requiresAuth);

    final Map<String, dynamic> jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return ApiResponse<T>.fromJson(jsonResponse, fromJson);
    } else {
      return ApiResponse<T>(
        error:
            jsonResponse['error'] ??
            jsonResponse['message'] ??
            'Request failed with status ${response.statusCode}',
      );
    }
  }

  /// Set authentication token
  static void setAuthToken(String token) {
    _client.setAuthToken(token);
  }

  /// Clear authentication token
  static void clearAuthToken() {
    _client.clearAuthToken();
  }

  /// Get current auth token
  static String? get authToken => _client.authToken;
}
