import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'logger.dart';

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
    _log('🔐 Auth token set');
  }

  void clearAuthToken() {
    _authToken = null;
    _log('🔓 Auth token cleared');
  }

  String? get authToken => _authToken;

  void _log(String message) {
    appLog('[API] 🌐 [HttpClient] $message');
  }

  void _logApiCall({
    required String method,
    required String url,
    required Map<String, String> headers,
    String? requestBody,
    int? statusCode,
    String? responseBody,
    dynamic error,
  }) {
    appLog(
      '',
      endpoint: '$method ${ApiConfig.baseUrl}$url',
      headers: headers,
      body: requestBody,
      status: statusCode,
      response: responseBody,
      error: error,
    );
  }

  Map<String, String> _getHeaders({bool includeAuth = false}) {
    final headers = {'Content-Type': 'application/json'};

    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  Future<http.Response> get(String url, {bool requiresAuth = false}) async {
    final headers = _getHeaders(includeAuth: requiresAuth);

    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}$url'), headers: headers)
          .timeout(ApiConfig.connectTimeout);

      _logApiCall(
        method: 'GET',
        url: url,
        headers: headers,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      return response;
    } catch (e) {
      _logApiCall(method: 'GET', url: url, headers: headers, error: e);
      rethrow;
    }
  }

  Future<http.Response> post(
    String url, {
    required Map<String, dynamic> body,
    bool requiresAuth = false,
  }) async {
    final headers = _getHeaders(includeAuth: requiresAuth);
    final bodyString = json.encode(body);

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$url'),
            headers: headers,
            body: bodyString,
          )
          .timeout(ApiConfig.connectTimeout);

      _logApiCall(
        method: 'POST',
        url: url,
        headers: headers,
        requestBody: bodyString,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      return response;
    } catch (e) {
      _logApiCall(
        method: 'POST',
        url: url,
        headers: headers,
        requestBody: bodyString,
        error: e,
      );
      rethrow;
    }
  }

  Future<http.Response> put(
    String url, {
    required Map<String, dynamic> body,
    bool requiresAuth = false,
  }) async {
    final headers = _getHeaders(includeAuth: requiresAuth);
    final bodyString = json.encode(body);

    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}$url'),
            headers: headers,
            body: bodyString,
          )
          .timeout(ApiConfig.connectTimeout);

      _logApiCall(
        method: 'PUT',
        url: url,
        headers: headers,
        requestBody: bodyString,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      return response;
    } catch (e) {
      _logApiCall(
        method: 'PUT',
        url: url,
        headers: headers,
        requestBody: bodyString,
        error: e,
      );
      rethrow;
    }
  }

  Future<http.Response> delete(String url, {bool requiresAuth = false}) async {
    final headers = _getHeaders(includeAuth: requiresAuth);

    try {
      final response = await http
          .delete(Uri.parse('${ApiConfig.baseUrl}$url'), headers: headers)
          .timeout(ApiConfig.connectTimeout);

      _logApiCall(
        method: 'DELETE',
        url: url,
        headers: headers,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      return response;
    } catch (e) {
      _logApiCall(method: 'DELETE', url: url, headers: headers, error: e);
      rethrow;
    }
  }
}
