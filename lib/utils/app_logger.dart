import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// Professional logging utility for Project Atlas
/// Uses the logger package for beautiful, configurable console output
/// Supports different log levels and pretty printing in debug mode
class AppLogger {
  static Logger? _instance;

  /// Get the logger instance with proper configuration
  static Logger get instance {
    _instance ??= Logger(
      level: kDebugMode ? Level.debug : Level.info,
      printer:
          kDebugMode
              ? PrettyPrinter(
                methodCount: 2,
                errorMethodCount:
                    8, // Number of method calls if stacktrace is provided
                lineLength: 120, // Width of the output
                colors: true, // Colorful log messages
                printEmojis: true, // Print an emoji for each log message
                dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
              )
              : SimplePrinter(colors: false, printTime: true),
      filter: ProductionFilter(),
    );
    return _instance!;
  }

  /// Log debug information - only shown in debug mode
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    instance.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log general information
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    instance.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warnings
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    instance.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log errors
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    instance.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log fatal errors
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    instance.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log authentication events
  static void auth(String message, [dynamic error, StackTrace? stackTrace]) {
    instance.i('🔐 AUTH: $message', error: error, stackTrace: stackTrace);
  }

  /// Log Firebase events
  static void firebase(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    instance.i('🔥 FIREBASE: $message', error: error, stackTrace: stackTrace);
  }

  /// Log UI events
  static void ui(String message, [dynamic error, StackTrace? stackTrace]) {
    instance.d('🎨 UI: $message', error: error, stackTrace: stackTrace);
  }

  /// Log navigation events
  static void navigation(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    instance.d('🧭 NAV: $message', error: error, stackTrace: stackTrace);
  }

  /// Log API/network events
  static void network(String message, [dynamic error, StackTrace? stackTrace]) {
    instance.i('🌐 NETWORK: $message', error: error, stackTrace: stackTrace);
  }

  /// Log data events (models, state changes)
  static void data(String message, [dynamic error, StackTrace? stackTrace]) {
    instance.d('📊 DATA: $message', error: error, stackTrace: stackTrace);
  }
}
