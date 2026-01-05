import '../../shared/config/api_config.dart';
import '../../shared/utils/api_x.dart';

class SuperadminTncService {
  /// Create new Terms & Conditions
  ///
  /// Request body:
  /// - title: Judul document (required, max 255 characters)
  /// - content: Isi document (required, supports Markdown)
  /// - version: Versi document (required, max 20 characters)
  Future<Map<String, dynamic>> createTnc({
    required String title,
    required String content,
    required String version,
  }) async {
    try {
      final response = await ApiX.post(
        ApiConfig.tnc,
        body: {'title': title, 'content': content, 'version': version},
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Terms & Conditions created successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.error ?? 'Failed to create TnC',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Update Terms & Conditions
  /// All fields are optional
  ///
  /// Request body:
  /// - title: Judul document (optional, max 255 characters)
  /// - content: Isi document (optional, supports Markdown)
  /// - version: Versi document (optional, max 20 characters)
  /// - isActive: Status aktif (optional)
  Future<Map<String, dynamic>> updateTnc({
    required int id,
    String? title,
    String? content,
    String? version,
    bool? isActive,
  }) async {
    try {
      Map<String, dynamic> body = {};
      if (title != null) body['title'] = title;
      if (content != null) body['content'] = content;
      if (version != null) body['version'] = version;
      if (isActive != null) body['is_active'] = isActive;

      final response = await ApiX.put(
        ApiConfig.tncById(id),
        body: body,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Terms & Conditions updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.error ?? 'Failed to update TnC',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Delete Terms & Conditions
  Future<Map<String, dynamic>> deleteTnc(int id) async {
    try {
      final response = await ApiX.delete(
        ApiConfig.tncById(id),
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Terms & Conditions deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.error ?? 'Failed to delete TnC',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
