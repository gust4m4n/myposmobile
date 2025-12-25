import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

/// Global logging function that:
/// - Only logs in debug mode
/// - Handles long strings without truncation (chunks into 800 char segments)
/// - Uses dev.log for proper logging
void appLog(
  dynamic message, {
  String? endpoint,
  String? method,
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
    logBuffer.writeln('--------');

    // Request logging (when method is provided)
    if (method != null && status == null) {
      logBuffer.writeln('[API] $method $endpoint');
      if (headers != null && headers.isNotEmpty) {
        headers.forEach((key, value) {
          logBuffer.writeln('$key: $value');
        });
      }
      logBuffer.writeln('--------');
      if (body != null) {
        logBuffer.writeln(_prettyJson(body));
      }
      logBuffer.writeln('--------');
    }
    // Response logging (when status is provided)
    else if (status != null) {
      logBuffer.writeln('[API] $status $endpoint');
      if (headers != null && headers.isNotEmpty) {
        headers.forEach((key, value) {
          logBuffer.writeln('$key: $value');
        });
      }
      logBuffer.writeln('--------');
      if (response != null) {
        logBuffer.writeln(_prettyJson(response));
      }
      logBuffer.writeln('--------');
    }
    // Error logging
    else if (error != null) {
      logBuffer.writeln('[API] ❌ Error: $endpoint');
      logBuffer.writeln(error.toString());
      logBuffer.writeln('--------');
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
  if (kDebugMode) {
    var lines = '';
    final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((RegExpMatch match) {
      var line = match.group(0);
      if (line != null) {
        if (lines.isEmpty) {
          lines = line;
        } else {
          lines = '$lines\n$line';
        }
      }
    });
    dev.log(lines);
  }
}

class Logger {
  static log(String text) {
    appLog(text);
  }
}
