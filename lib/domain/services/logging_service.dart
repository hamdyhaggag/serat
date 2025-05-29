import 'package:flutter/foundation.dart';

class LoggingService {
  static void log(String message,
      {String? tag, LogLevel level = LogLevel.info}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final tagStr = tag != null ? '[$tag]' : '';
      final levelStr = level.toString().split('.').last.toUpperCase();

      print('$timestamp $levelStr $tagStr $message');
    }
  }

  static void debug(String message, {String? tag}) {
    log(message, tag: tag, level: LogLevel.debug);
  }

  static void info(String message, {String? tag}) {
    log(message, tag: tag, level: LogLevel.info);
  }

  static void warning(String message, {String? tag}) {
    log(message, tag: tag, level: LogLevel.warning);
  }

  static void error(String message,
      {String? tag, dynamic error, StackTrace? stackTrace}) {
    log('$message${error != null ? '\nError: $error' : ''}${stackTrace != null ? '\nStackTrace: $stackTrace' : ''}',
        tag: tag, level: LogLevel.error);
  }
}

enum LogLevel {
  debug,
  info,
  warning,
  error,
}
