/// -----------------------------------------------------------------------------
/// Author: rapzaDev
/// Description: Flexible debug logging utility for Flutter apps.
/// Repository: https://github.com/rapzaDev/debug-utils-flutter
/// License: MIT
/// -----------------------------------------------------------------------------
///
/// Created and maintained by rapzaDev.
/// For questions or contributions, visit the repository or contact the author.
/// -----------------------------------------------------------------------------

import 'dart:developer' as dev;

/// Log levels for categorizing debug messages.
enum LogLevel { info, warning, error, debug }

/// Utility class for flexible debug logging in Flutter apps.
/// Runs only in debug mode via `assert`.
/// Supports log levels, tags, and optional breakpoint for pausing execution.
///
/// Example usage:
/// ```dart
/// DebugUtils.debugLog('A debug message');
/// DebugUtils.debugLog('An error occurred', level: LogLevel.error, breakPoint: true, tag: 'Auth');
/// ```
class DebugUtils {
  /// Logs a message only in debug mode.
  ///
  /// [message] is the text to log.
  /// [level] categorizes the log (default is debug).
  /// [breakPoint], if true, pauses execution for debugger (default is false).
  /// [tag] is an optional string for categorizing logs.
  static void debugLog(
    String message, {
    LogLevel level = LogLevel.debug,
    bool breakPoint = false,
    String? tag,
  }) {
    assert(() {
      if (breakPoint) dev.debugger();

      _logMessage(message, level: level, tag: tag);
      return true;
    }());
  }

  static void _logMessage(
    String message, {
    required LogLevel level,
    String? tag,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.toString().split('.').last.toUpperCase();
    final effectiveTag = tag ?? 'DebugUtils';

    final formattedMessage = '[$timestamp][$levelStr] $message';

    // Maps LogLevel to integers following syslog levels used by dart:developer:
    // debug=700, info=800, warning=900, error=1000
    dev.log(
      formattedMessage,
      name: '$effectiveTag - @rapzaDev',
      level: _mapLogLevelToInt(level),
    );
  }

  static int _mapLogLevelToInt(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.debug:
        return 700;
    }
  }
}

/// Service class to allow dependency injection and mocking of logging.
/// Wraps DebugUtils.debugLog for easier testing and extensibility.
///
/// Example:
/// ```dart
/// final logger = DebugLoggerService();
/// logger.log('Message', level: LogLevel.info, breakPoint: false);
/// ```
class DebugLoggerService {
  void log(
    String message, {
    bool breakPoint = false,
    LogLevel level = LogLevel.info,
    String? tag,
  }) {
    DebugUtils.debugLog(
      message,
      breakPoint: breakPoint,
      level: level,
      tag: tag,
    );
  }
}
