import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../shared/config/api_config.dart';
import '../../shared/utils/storage_service.dart';

class SuperadminTncService {
  /// Create new Terms & Conditions (Superadmin only)
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
      final storage = await StorageService.getInstance();
      final token = storage.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.superadminTnc}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              'title': title,
              'content': content,
              'version': version,
            }),
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
          'message': 'Terms & Conditions created successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create TnC: ${response.statusCode}',
          'data': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Update Terms & Conditions (Superadmin only)
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
      final storage = await StorageService.getInstance();
      final token = storage.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      Map<String, dynamic> body = {};
      if (title != null) body['title'] = title;
      if (content != null) body['content'] = content;
      if (version != null) body['version'] = version;
      if (isActive != null) body['is_active'] = isActive;

      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.superadminTncById(id)}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(body),
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
          'message': 'Terms & Conditions updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update TnC: ${response.statusCode}',
          'data': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Delete Terms & Conditions (Superadmin only)
  Future<Map<String, dynamic>> deleteTnc(int id) async {
    try {
      final storage = await StorageService.getInstance();
      final token = storage.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.superadminTncById(id)}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Terms & Conditions deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete TnC: ${response.statusCode}',
          'data': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
