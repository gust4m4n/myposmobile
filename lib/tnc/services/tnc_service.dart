import '../../shared/config/api_config.dart';
import '../../shared/utils/api_x.dart';

class TncService {
  /// Get Terms & Conditions
  /// Public endpoint - tidak perlu authentication
  /// Returns TnC content with title and markdown content
  Future<Map<String, dynamic>> getAllTnc() async {
    try {
      final response = await ApiX.get(ApiConfig.tnc, requiresAuth: false);

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else {
        return {
          'success': false,
          'message': response.error ?? 'Failed to load Terms & Conditions',
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
      final response = await ApiX.get(
        ApiConfig.tncById(id),
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else {
        return {
          'success': false,
          'message': response.error ?? 'Failed to load TnC',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
