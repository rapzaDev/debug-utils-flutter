// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
//
// Description: Provides a MultiLogger class that forwards log messages and breakpoints to multiple logger instances, handling errors and supporting debug utilities.
//
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'dart:developer' as dev;
import 'package:debug_utils/src/logger_interfaces.dart';

class MultiLogger implements IDebugLogger {
  final List<ILogger> loggers;
  final void Function(Object, StackTrace)? onLoggerError;

  MultiLogger(this.loggers, {this.onLoggerError});

  @override
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
