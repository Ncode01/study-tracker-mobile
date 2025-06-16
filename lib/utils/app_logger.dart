import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// Professional logging utility for Project Atlas
/// 
/// This class provides a centralized, themed logging system that replaces
/// all print() statements and provides structured, filterable logging
/// with proper log levels and formatting.
class AppLogger {
  static late Logger _logger;
    /// Initialize the logger with Project Atlas themed configuration
  static void initialize() {
    _logger = Logger(
      filter: _AtlasLogFilter(),
      printer: _AtlasLogPrinter(),
      output: _AtlasLogOutput(),
    );
    
    // Log that the logger itself has been initialized
    info('🚀 Project Atlas Logger initialized');
  }
  
  /// Get the configured logger instance
  static Logger get instance => _logger;
  
  // Convenience methods for different log levels
  
  /// Log debug information - typically for development only
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }
  
  /// Log general information - normal app flow
  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }
  
  /// Log warnings - something unexpected but not critical
  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }
  
  /// Log errors - something went wrong
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
  
  /// Log fatal errors - critical failures
  static void fatal(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
  
  // Themed logging methods for specific Project Atlas contexts
  
  /// Log Firebase-related operations
  static void firebase(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.i('🔥 [Firebase] $message', error: error, stackTrace: stackTrace);
  }
  
  /// Log authentication-related operations
  static void auth(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.i('🗝️ [Auth] $message', error: error, stackTrace: stackTrace);
  }
  
  /// Log navigation-related operations
  static void navigation(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.i('🧭 [Navigation] $message', error: error, stackTrace: stackTrace);
  }
  
  /// Log data operations (Firestore, local storage, etc.)
  static void data(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.i('📊 [Data] $message', error: error, stackTrace: stackTrace);
  }
  
  /// Log UI-related operations
  static void ui(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.d('🎨 [UI] $message', error: error, stackTrace: stackTrace);
  }
}

/// Custom log filter for Project Atlas
/// Controls which log levels are shown in different build modes
class _AtlasLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kReleaseMode) {
      // In release mode, only show warnings and above
      return event.level.value >= Level.warning.value;
    } else if (kProfileMode) {
      // In profile mode, show info and above
      return event.level.value >= Level.info.value;
    } else {
      // In debug mode, show everything
      return true;
    }
  }
}

/// Custom log printer for Project Atlas
/// Formats log messages with explorer/traveler theming
class _AtlasLogPrinter extends PrettyPrinter {  _AtlasLogPrinter()
      : super(
          methodCount: 1, // Reduce stack trace noise
          errorMethodCount: 3, // More context for errors
          lineLength: 80, // Readable line length
          colors: true, // Enable colors in debug console
          printEmojis: true, // Use emojis for visual distinction
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Include timestamps
          excludeBox: const {
            Level.debug: true, // Clean debug output
          },
        );

  @override
  List<String> log(LogEvent event) {
    final logLines = super.log(event);
    
    // Add Project Atlas branding to the first line
    if (logLines.isNotEmpty) {
      final level = event.level;
      final emoji = _getLevelEmoji(level);
      logLines[0] = '⚡ Project Atlas $emoji ${logLines[0]}';
    }
    
    return logLines;
  }
  
  String _getLevelEmoji(Level level) {
    switch (level) {
      case Level.debug:
        return '🔍';
      case Level.info:
        return '📋';
      case Level.warning:
        return '⚠️';
      case Level.error:
        return '❌';
      case Level.fatal:
        return '💥';
      default:
        return '📝';
    }
  }
}

/// Custom log output for Project Atlas
/// Routes logs to appropriate destinations based on build mode
class _AtlasLogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    // In debug mode, output to console
    if (kDebugMode) {
      for (final line in event.lines) {
        // Use debugPrint for proper Flutter console integration
        debugPrint(line);
      }
    }
    
    // In release mode, you might want to send logs to a crash reporting service
    // like Firebase Crashlytics, Sentry, etc.
    if (kReleaseMode && event.level.value >= Level.error.value) {
      // TODO: Integrate with crash reporting service
      // Example: FirebaseCrashlytics.instance.log(event.lines.join('\n'));
    }
  }
}
