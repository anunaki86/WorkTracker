// ignore_for_file: avoid_print
import 'package:flutter/foundation.dart';

class AppLogger {
  static void info(String message) {
    // Implement info logging
    print('INFO: ' + message);
  }

  static void warning(String message) {
    // Implement warning logging
    print('WARNING: ' + message);
  }

  // Główna metoda logująca używana wewnętrznie
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      print('${tag != null ? "[\$tag] " : ""}\$message');
    }
  }

  static void debug(String message, {String? tag}) {
    log(message, tag: tag ?? 'DEBUG');
  }

  static void error(String message, {String? tag, Object? errorDetails, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('${tag != null ? "[$tag] " : ""}ERROR: $message');
      if (errorDetails != null) {
        print('Error details: $errorDetails');
      }
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }
  }
}
