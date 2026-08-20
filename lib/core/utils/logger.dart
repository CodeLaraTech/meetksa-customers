import 'package:flutter/foundation.dart';

class AppLogger {
  static bool _debugEnabled = kDebugMode;

  static void configure({required bool enableDebugLogs}) {
    _debugEnabled = enableDebugLogs;
  }

  static void info(String message) {
    if (_debugEnabled) {
      debugPrint('[MeetKSA INFO] $message');
    }
  }

  static void warning(String message) {
    if (_debugEnabled) {
      debugPrint('[MeetKSA WARN] $message');
    }
  }

  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    if (_debugEnabled) {
      debugPrint('[MeetKSA ERROR] $message');
      if (error != null) debugPrint('Error details: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }

  static void webView(String event) {
    if (_debugEnabled) {
      debugPrint('[MeetKSA WebView] $event');
    }
  }
}
