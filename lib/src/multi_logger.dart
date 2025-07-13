// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
// Description: Provides a MultiLogger class that forwards log messages and
// breakpoints to multiple logger instances, handling errors and supporting
// debug utilities.
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'dart:developer' as dev;
import 'package:debug_utils/src/logger_interfaces.dart';

/// Composite logger that distributes messages and breakpoints to multiple loggers.
///
/// Implements [IDebugLogger] and is designed to be resilient to failures,
/// logging errors in debug mode if an error callback is not provided.
class MultiLogger implements IDebugLogger {
  /// List of loggers to be utilized.
  final List<ILogger> loggers;

  /// Optional callback to handle errors during logging.
  final void Function(Object, StackTrace)? onLoggerError;

  /// Constructor initializing with a list of loggers.
  ///
  /// [loggers] is the list of [ILogger] instances.
  /// [onLoggerError] is the error handler (optional).
  MultiLogger(this.loggers, {this.onLoggerError});

  @override

  /// Records a log entry to all loggers.
  ///
  /// [entry] contains the message details.
  /// Catches and handles exceptions, calling [onLoggerError] or logging in
  /// debug mode if configured.
  void log(LogEntry entry) {
    for (final logger in loggers) {
      try {
        logger.log(entry);
      } catch (e, st) {
        if (onLoggerError != null) {
          onLoggerError!(e, st);
        } else if (kDebugMode) {
          dev.log('MultiLogger error: $e', stackTrace: st);
        }
      }
    }
  }

  @override

  /// Triggers a breakpoint on all loggers that support the feature.
  ///
  /// Catches and handles exceptions, calling [onLoggerError] or logging in
  /// debug mode if configured.
  void breakpoint() {
    for (final logger in loggers) {
      if (logger is IDebugLogger) {
        try {
          logger.breakpoint();
        } catch (e, st) {
          if (onLoggerError != null) {
            onLoggerError!(e, st);
          } else if (kDebugMode) {
            dev.log('MultiLogger breakpoint error: $e', stackTrace: st);
          }
        }
      }
    }
  }
}
