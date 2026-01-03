import '../../shared/config/api_config.dart';
import '../../shared/utils/api_x.dart';

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
      String endpoint = ApiConfig.faq;

      // Add query parameters if provided
      List<String> queryParams = [];
      if (category != null && category.isNotEmpty) {
        queryParams.add('category=$category');
      }
      if (activeOnly) {
        queryParams.add('active_only=true');
      }

      if (queryParams.isNotEmpty) {
        endpoint = '$endpoint?${queryParams.join('&')}';
      }

      final response = await ApiX.get(endpoint, requiresAuth: false);

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else {
        return {
          'success': false,
          'message': response.error ?? 'Failed to load FAQ',
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
      final response = await ApiX.get(
        ApiConfig.faqById(id),
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else {
        return {
          'success': false,
          'message': response.error ?? 'Failed to load FAQ',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
