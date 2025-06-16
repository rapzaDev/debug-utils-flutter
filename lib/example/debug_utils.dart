import 'dart:developer' as dev;

enum LogLevel { info, warning, error, debug }

/// Utility class for flexible debug logging in Flutter apps.
/// Uses assert to run only in debug mode, supporting log levels and tags for better traceability.
class DebugUtils {
  /// Logs a message with an optional [level] and [tag].
  /// Runs only in debug mode.
  static void debugLog(
    String message, {
    LogLevel level = LogLevel.debug,
    String? tag,
  }) {
    assert(() {
      dev.debugger();
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

    dev.log(
      formattedMessage,
      name: '$effectiveTag - @rapzaDev',
      level: _mapLogLevelToInt(level),
    );
  }

  /// Maps LogLevel enum to integers understood by dart:developer
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
