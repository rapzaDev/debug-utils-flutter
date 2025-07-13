// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
// Description: Defines interfaces for logging functionality in Dart applications.
// Provides the base [ILogger] interface for general logging and the [IDebugLogger]
// interface for loggers supporting breakpoints, enabling extensible and consistent
// logging implementations across projects.
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

import 'package:debug_utils/src/log_level.dart';

/// Base interface for logger implementations, defining the log recording method.
abstract class ILogger {
  /// Records a log entry.
  ///
  /// [entry] contains the details of the message to be recorded.
  void log(LogEntry entry);
}

/// Extended interface for loggers that support breakpoints.
abstract class IDebugLogger implements ILogger {
  /// Triggers a breakpoint for debugger inspection.
  void breakpoint();
}

/// Interface for log formatters, responsible for structuring output.
abstract class ILogFormatter {
  /// Formats a log entry into a string.
  ///
  /// [entry] contains the details to be formatted.
  /// Returns the formatted string.
  String format(LogEntry entry);
}

/// Interface for timestamp providers, generating time stamps.
abstract class ITimestampProvider {
  /// Returns the current timestamp in ISO 8601 format (e.g., 2025-07-13T14:02:00Z).
  String get currentTimestamp;
}

/// Interface for caller information extractors.
abstract class ICallerInfoExtractor {
  /// Extracts caller information from a stack trace.
  ///
  /// [stackTrace] is the stack trace to be analyzed.
  /// Returns a string with caller information or null in case of failure.
  String? extract(StackTrace stackTrace);
}

/// Interface for log filters, controlling which messages are recorded.
abstract class ILogFilter {
  /// Checks if a message should be recorded.
  ///
  /// [level] is the severity level.
  /// [tag] is the associated tag (optional).
  /// Returns true if the log should be processed.
  bool shouldLog(LogLevel level, String? tag);
}

/// Immutable class representing a log entry.
class LogEntry {
  /// Severity level of the message.
  final LogLevel level;

  /// Main message to be recorded.
  final String message;

  /// Tag identifying the module or context (optional).
  final String? tag;

  /// Associated error object (optional).
  final Object? errObj;

  /// Associated stack trace (optional).
  final StackTrace? stackTrace;

  /// Additional context in map format (optional).
  final Map<String, Object?>? context;

  /// Caller information (e.g., method, file, line).
  final String caller;

  /// Timestamp of log generation.
  final String timestamp;

  /// Constructor requiring [level], [message], [caller], and [timestamp].
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
