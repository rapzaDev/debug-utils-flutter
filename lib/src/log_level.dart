// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
// Description: Defines log levels and their priorities for structured logging
// in Dart applications.
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

/// Enumeration representing log levels with a standard priority scale.
enum LogLevel {
  trace,
  debug,
  info,
  warning,
  error,
  fatal,
  verbose,
}

/// Extension providing utility methods for the [LogLevel] enum.
extension LogLevelExtension on LogLevel {
  /// Returns the numerical priority of the log level, where higher values
  /// indicate greater severity (0 for trace, 6 for verbose).
  int get priority {
    switch (this) {
      case LogLevel.trace:
        return 0;
      case LogLevel.debug:
        return 1;
      case LogLevel.info:
        return 2;
      case LogLevel.warning:
        return 3;
      case LogLevel.error:
        return 4;
      case LogLevel.fatal:
        return 5;
      case LogLevel.verbose:
        return 6;
    }
  }

  /// Returns the textual label corresponding to the log level in uppercase.
  String get label {
    switch (this) {
      case LogLevel.trace:
        return 'TRACE';
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.fatal:
        return 'FATAL';
      case LogLevel.verbose:
        return 'VERBOSE';
    }
  }
}
