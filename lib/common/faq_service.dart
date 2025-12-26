import 'dart:convert';

import 'package:http/http.dart' as http;

import '../shared/config/api_config.dart';

class FaqService {
  /// Get all FAQ
  /// Public endpoint - tidak perlu authentication
  ///
  /// Query Parameters:
  /// - category: Filter by category (optional)
  /// - activeOnly: Show only active FAQs (optional, default: false)
  Future<Map<String, dynamic>> getAllFaq({
    String? category,
    bool activeOnly = false,
  }) async {
    try {
      var uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.faq}');

      // Add query parameters if provided
      Map<String, String> queryParams = {};
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (activeOnly) {
        queryParams['active_only'] = 'true';
      }

      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'message': 'Failed to load FAQ: ${response.statusCode}',
          'data': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Get FAQ by ID
  /// Public endpoint - tidak perlu authentication
  Future<Map<String, dynamic>> getFaqById(int id) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.faqById(id)}'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'message': 'Failed to load FAQ: ${response.statusCode}',
          'data': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
