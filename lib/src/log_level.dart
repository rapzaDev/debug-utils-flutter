// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
//
// Description:
// Defines log levels and their priorities for structured logging in Dart applications.
//
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

/// Log levels with standard priority scale.
enum LogLevel {
  trace,
  debug,
  info,
  warning,
  error,
}

extension LogLevelExtension on LogLevel {
  String get label => name.toUpperCase();

  int get priority {
    switch (this) {
      case LogLevel.trace:
        return 500;
      case LogLevel.debug:
        return 1000;
      case LogLevel.info:
        return 2000;
      case LogLevel.warning:
        return 3000;
      case LogLevel.error:
        return 4000;
    }
  }
}
