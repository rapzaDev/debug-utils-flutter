// lib/src/logger_interfaces.dart
// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
//
// Description:
// This file defines interfaces for logging functionality in Dart applications.
// It provides the base ILogger interface for general logging and the IDebugLogger
// interface for loggers that support breakpoints, enabling extensible and consistent
// logging implementations across projects.
//
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

import 'package:debug_utils/src/log_level.dart';

abstract class ILogger {
  void log(LogEntry entry);
}

abstract class IDebugLogger implements ILogger {
  void breakpoint();
}

abstract class ILogFormatter {
  String format(LogEntry entry);
}

abstract class ITimestampProvider {
  String get currentTimestamp;
}

abstract class ICallerInfoExtractor {
  String? extract(StackTrace stackTrace);
}

abstract class ILogFilter {
  bool shouldLog(LogLevel level, String? tag);
}

class LogEntry {
  final LogLevel level;
  final String message;
  final String? tag;
  final Object? errObj;
  final StackTrace? stackTrace;
  final Map<String, Object?>? context;
  final String caller;
  final String timestamp;

  const LogEntry({
    required this.level,
    required this.message,
    this.tag,
    this.errObj,
    this.stackTrace,
    this.context,
    required this.caller,
    required this.timestamp,
  });
}
