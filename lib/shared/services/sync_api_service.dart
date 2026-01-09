import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/sync_download_model.dart';
import '../models/sync_upload_model.dart';

class SyncApiService {
  final String baseUrl = ApiConfig.baseUrl;

  // Get auth token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Get headers with auth
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Upload data to server
  Future<SyncUploadResponse> uploadData(SyncUploadRequest request) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/sync/upload'),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      print('Upload Response Status: ${response.statusCode}');
      print('Upload Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return SyncUploadResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to upload data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error uploading data: $e');
      rethrow;
    }
  }

  // Download data from server
  Future<SyncDownloadResponse> downloadData(SyncDownloadRequest request) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/sync/download'),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      print('Download Response Status: ${response.statusCode}');
      print('Download Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return SyncDownloadResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to download data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error downloading data: $e');
      rethrow;
    }
  }

  // Get sync status
  Future<SyncStatusResponse> getSyncStatus(String clientId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/sync/status?client_id=$clientId'),
        headers: headers,
      );

      print('Sync Status Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return SyncStatusResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to get sync status: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error getting sync status: $e');
      rethrow;
    }
  }

  // Get sync logs
  Future<Map<String, dynamic>> getSyncLogs({
    required String clientId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/v1/sync/logs?client_id=$clientId&page=$page&page_size=$pageSize',
        ),
        headers: headers,
      );

      print('Sync Logs Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to get sync logs: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error getting sync logs: $e');
      rethrow;
    }
  }

  // Resolve conflict
  Future<Map<String, dynamic>> resolveConflict({
    required String conflictId,
    required String resolution, // 'keep_local', 'keep_server', 'merge'
    Map<String, dynamic>? mergedData,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/sync/conflicts/resolve'),
        headers: headers,
        body: jsonEncode({
          'conflict_id': conflictId,
          'resolution': resolution,
          if (mergedData != null) 'merged_data': mergedData,
        }),
      );

      print('Resolve Conflict Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to resolve conflict: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error resolving conflict: $e');
      rethrow;
    }
  }

  // Get server time
  Future<DateTime> getServerTime() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/sync/time'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final serverTime = jsonData['data']['server_time'] as String;
        return DateTime.parse(serverTime);
      } else {
        throw Exception(
          'Failed to get server time: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error getting server time: $e');
      // Fallback to local time if server time fails
      return DateTime.now();
    }
  }
}
