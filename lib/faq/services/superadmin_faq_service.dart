import '../../shared/utils/api_x.dart';

class SuperadminFaqService {
  /// Create new FAQ
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
      Map<String, dynamic> body = {'question': question, 'answer': answer};
      if (category != null) body['category'] = category;
      if (order != null) body['order'] = order;

      final response = await ApiX.post(
        '/faq',
        body: body,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'FAQ created successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.error ?? 'Failed to create FAQ',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Update FAQ
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
      Map<String, dynamic> body = {};
      if (question != null) body['question'] = question;
      if (answer != null) body['answer'] = answer;
      if (category != null) body['category'] = category;
      if (order != null) body['order'] = order;
      if (isActive != null) body['is_active'] = isActive;

      final response = await ApiX.put(
        '/faq/$id',
        body: body,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'FAQ updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.error ?? 'Failed to update FAQ',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Delete FAQ
  Future<Map<String, dynamic>> deleteFaq(int id) async {
    try {
      final response = await ApiX.delete('/faq/$id', requiresAuth: true);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'FAQ deleted successfully'};
      } else {
        return {
          'success': false,
          'message': response.error ?? 'Failed to delete FAQ',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
