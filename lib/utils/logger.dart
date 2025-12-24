import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Global logging function that:
/// - Only logs in debug mode
/// - Handles long strings without truncation (chunks into 800 char segments)
/// - Uses stdout.writeln to avoid "flutter:" prefix
void appLog(
  dynamic message, {
  String? endpoint,
  Map<String, String>? headers,
  String? body,
  int? status,
  String? response,
  dynamic error,
}) {
  // Only log in debug mode
  if (!kDebugMode) return;

  // If structured API logging
  if (endpoint != null) {
    final logBuffer = StringBuffer();
    logBuffer.writeln('[API] Endpoint: $endpoint');
    if (headers != null) {
      logBuffer.writeln('[API] Headers: $headers');
    }
    if (body != null) {
      logBuffer.writeln('[API] Body:');
      logBuffer.writeln(_prettyJson(body));
    }
    if (error != null) {
      logBuffer.writeln('[API] ❌ Error: $error');
    } else if (status != null) {
      logBuffer.writeln('[API] Status: $status');
      if (response != null) {
        logBuffer.writeln('[API] Response:');
        logBuffer.writeln(_prettyJson(response));
      }
    }
    _logChunked(logBuffer.toString());
    return;
  }

  // Regular logging
  _logChunked(message.toString());
}

String _prettyJson(String jsonString) {
  try {
    final dynamic jsonObject = jsonDecode(jsonString);
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(jsonObject);
  } catch (e) {
    // If not valid JSON, return as is
    return jsonString;
  }
}

void _logChunked(String text) {
  const int chunkSize = 800; // Safe size to avoid truncation

  if (text.length <= chunkSize) {
    stdout.writeln(text);
    return;
  }

  // Split into chunks for long messages
  for (int i = 0; i < text.length; i += chunkSize) {
    final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
    final chunk = text.substring(i, end);
    stdout.writeln(chunk);
  }
}
