import 'dart:convert';

import 'package:http/http.dart' as http;

import '../shared/config/api_config.dart';

class TncService {
  /// Get all Terms & Conditions
  /// Public endpoint - tidak perlu authentication
  Future<Map<String, dynamic>> getAllTnc() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.tnc}'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'message':
              'Failed to load Terms & Conditions: ${response.statusCode}',
          'data': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Get active Terms & Conditions
  /// Public endpoint - tidak perlu authentication
  /// Returns the currently active TnC document
  Future<Map<String, dynamic>> getActiveTnc() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.tncActive}'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'No active Terms & Conditions found',
          'data': response.body,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load active TnC: ${response.statusCode}',
          'data': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Get Terms & Conditions by ID
  /// Public endpoint - tidak perlu authentication
  Future<Map<String, dynamic>> getTncById(int id) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.tncById(id)}'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'message': 'Failed to load TnC: ${response.statusCode}',
          'data': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
