import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api_models.dart';
import '../config/api_config.dart';
import 'logger_x.dart';

/// Reusable API client class for all API calls in the application
/// Provides simplified methods for GET, POST, PUT, DELETE operations
/// Returns ApiResponse<T> for type-safe responses
class ApiX {
  static String? _authToken;

  static void _log(String message) {
    appLog('[API] 🌐 [ApiX] $message');
  }

  static void _logApiCall({
    required String method,
    required String url,
    required Map<String, String> headers,
    String? requestBody,
    int? statusCode,
    String? responseBody,
    dynamic error,
  }) {
    // Log request
    if (statusCode == null && error == null) {
      appLog(
        '',
        endpoint: url,
        method: method,
        headers: headers,
        body: requestBody,
      );
    }
    // Log response
    else if (statusCode != null) {
      appLog(
        '',
        endpoint: url,
        method: method,
        headers: headers,
        status: statusCode,
        response: responseBody,
      );
    }
    // Log error
    else if (error != null) {
      appLog('', endpoint: url, error: error);
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
    _logApiCall(
      method: method,
      url: url,
      headers: headers,
      requestBody: bodyString,
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
      _logApiCall(
        method: method,
        url: url,
        headers: headers,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      return response;
    } catch (e) {
      _logApiCall(method: method, url: url, headers: headers, error: e);
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

    final Map<String, dynamic> jsonResponse = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse<T>.fromJson(
        jsonResponse,
        fromJson,
        response.statusCode,
      );
    } else {
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

    final Map<String, dynamic> jsonResponse = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse<T>.fromJson(
        jsonResponse,
        fromJson,
        response.statusCode,
      );
    } else {
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

    final Map<String, dynamic> jsonResponse = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse<T>.fromJson(
        jsonResponse,
        fromJson,
        response.statusCode,
      );
    } else {
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

    final Map<String, dynamic> jsonResponse = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse<T>.fromJson(
        jsonResponse,
        fromJson,
        response.statusCode,
      );
    } else {
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
    _log('🔐 Auth token set');
  }

  /// Clear authentication token
  static void clearAuthToken() {
    _authToken = null;
    _log('🔓 Auth token cleared');
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
      final file = await http.MultipartFile.fromPath(fieldName, filePath);
      request.files.add(file);

      _log('📤 Uploading file to $url');

      final streamedResponse = await request.send().timeout(
        ApiConfig.connectTimeout,
      );
      final response = await http.Response.fromStream(streamedResponse);

      _logApiCall(
        method: 'POST (multipart)',
        url: url,
        headers: request.headers,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>.fromJson(jsonResponse, null, response.statusCode);
      } else {
        return ApiResponse<T>(
          error:
              jsonResponse['error'] ??
              jsonResponse['message'] ??
              'Upload failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      _log('❌ Upload error: $e');
      return ApiResponse<T>(error: 'Upload failed: $e', statusCode: 0);
    }
  }
}
