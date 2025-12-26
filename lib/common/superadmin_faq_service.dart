import 'dart:convert';

import 'package:http/http.dart' as http;

import '../shared/config/api_config.dart';
import '../shared/utils/storage_service.dart';

class SuperadminFaqService {
  /// Create new FAQ (Superadmin only)
  ///
  /// Request body:
  /// - question: Pertanyaan (required, min 5, max 500 characters)
  /// - answer: Jawaban (required)
  /// - category: Kategori (optional, max 100 characters)
  /// - order: Urutan tampilan (optional, default 0)
  Future<Map<String, dynamic>> createFaq({
    required String question,
    required String answer,
    String? category,
    int? order,
  }) async {
    try {
      final storage = await StorageService.getInstance();
      final token = storage.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.superadminFaq}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              'question': question,
              'answer': answer,
              if (category != null) 'category': category,
              if (order != null) 'order': order,
            }),
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': json.decode(response.body),
          'message': 'FAQ created successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create FAQ: ${response.statusCode}',
          'data': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Update FAQ (Superadmin only)
  /// All fields are optional
  ///
  /// Request body:
  /// - question: Pertanyaan (optional, min 5, max 500 characters)
  /// - answer: Jawaban (optional)
  /// - category: Kategori (optional, max 100 characters)
  /// - order: Urutan tampilan (optional)
  /// - isActive: Status aktif (optional)
  Future<Map<String, dynamic>> updateFaq({
    required int id,
    String? question,
    String? answer,
    String? category,
    int? order,
    bool? isActive,
  }) async {
    try {
      final storage = await StorageService.getInstance();
      final token = storage.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      Map<String, dynamic> body = {};
      if (question != null) body['question'] = question;
      if (answer != null) body['answer'] = answer;
      if (category != null) body['category'] = category;
      if (order != null) body['order'] = order;
      if (isActive != null) body['is_active'] = isActive;

      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.superadminFaqById(id)}'),
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
          'message': 'FAQ updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update FAQ: ${response.statusCode}',
          'data': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Delete FAQ (Superadmin only)
  Future<Map<String, dynamic>> deleteFaq(int id) async {
    try {
      final storage = await StorageService.getInstance();
      final token = storage.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.superadminFaqById(id)}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'FAQ deleted successfully'};
      } else {
        return {
          'success': false,
          'message': 'Failed to delete FAQ: ${response.statusCode}',
          'data': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
