import '../../shared/config/api_config.dart';
import '../../shared/utils/api_x.dart';

class TncService {
  /// Get all Terms & Conditions
  /// Public endpoint - tidak perlu authentication
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

  /// Get active Terms & Conditions
  /// Public endpoint - tidak perlu authentication
  /// Returns the currently active TnC document
  Future<Map<String, dynamic>> getActiveTnc() async {
    try {
      final response = await ApiX.get(ApiConfig.tncActive, requiresAuth: false);

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'No active Terms & Conditions found',
        };
      } else {
        return {
          'success': false,
          'message': response.error ?? 'Failed to load active TnC',
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
