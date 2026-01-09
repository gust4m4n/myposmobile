import '../models/sync_download_model.dart';
import '../models/sync_upload_model.dart';
import '../utils/api_x.dart';
import '../utils/logger_x.dart';

class SyncApiService {
  // Upload data to server
  Future<SyncUploadResponse> uploadData(SyncUploadRequest request) async {
    try {
      final response = await ApiX.post(
        '/api/v1/sync/upload',
        body: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.error == null) {
        // Response structure from backend: {code, message, data: {...}}
        final jsonData = {
          'code': response.code,
          'message': response.message,
          'data': response.data,
        };
        return SyncUploadResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to upload data: ${response.statusCode} - ${response.error}',
        );
      }
    } catch (e) {
      LoggerX.log('❌ Error uploading data: $e');
      rethrow;
    }
  }

  // Download data from server
  Future<SyncDownloadResponse> downloadData(SyncDownloadRequest request) async {
    try {
      final response = await ApiX.post(
        '/api/v1/sync/download',
        body: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.error == null) {
        LoggerX.log(
          '🔍 DEBUG - Response data type: ${response.data.runtimeType}',
        );
        LoggerX.log('🔍 DEBUG - Parsing response.data directly');

        // response.data already contains {code, message, data} structure
        // No need to wrap it again - that was causing double nesting!
        return SyncDownloadResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to download data: ${response.statusCode} - ${response.error}',
        );
      }
    } catch (e) {
      LoggerX.log('❌ Error downloading data: $e');
      rethrow;
    }
  }

  // Get sync status
  Future<SyncStatusResponse> getSyncStatus(String clientId) async {
    try {
      final response = await ApiX.get(
        '/api/v1/sync/status?client_id=$clientId',
        requiresAuth: true,
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.error == null) {
        final jsonData = {
          'code': response.code,
          'message': response.message,
          'data': response.data,
        };
        return SyncStatusResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to get sync status: ${response.statusCode} - ${response.error}',
        );
      }
    } catch (e) {
      LoggerX.log('❌ Error getting sync status: $e');
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
      final response = await ApiX.get(
        '/api/v1/sync/logs?client_id=$clientId&page=$page&page_size=$pageSize',
        requiresAuth: true,
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.error == null) {
        return {
          'code': response.code,
          'message': response.message,
          'data': response.data,
        };
      } else {
        throw Exception(
          'Failed to get sync logs: ${response.statusCode} - ${response.error}',
        );
      }
    } catch (e) {
      LoggerX.log('❌ Error getting sync logs: $e');
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
      final response = await ApiX.post(
        '/api/v1/sync/conflicts/resolve',
        body: {
          'conflict_id': conflictId,
          'resolution': resolution,
          if (mergedData != null) 'merged_data': mergedData,
        },
        requiresAuth: true,
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.error == null) {
        return {
          'code': response.code,
          'message': response.message,
          'data': response.data,
        };
      } else {
        throw Exception(
          'Failed to resolve conflict: ${response.statusCode} - ${response.error}',
        );
      }
    } catch (e) {
      LoggerX.log('❌ Error resolving conflict: $e');
      rethrow;
    }
  }

  // Get server time
  Future<DateTime> getServerTime() async {
    try {
      final response = await ApiX.get('/api/v1/sync/time', requiresAuth: true);

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.error == null &&
          response.data != null) {
        final serverTime = response.data['server_time'] as String?;
        if (serverTime != null) {
          return DateTime.parse(serverTime);
        } else {
          LoggerX.log('⚠️ server_time is null, using local time');
          return DateTime.now();
        }
      } else {
        throw Exception('Failed to get server time: ${response.error}');
      }
    } catch (e) {
      LoggerX.log('❌ Error getting server time: $e');
      // Fallback to local time if server time fails
      return DateTime.now();
    }
  }
}
