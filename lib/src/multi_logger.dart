// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
//
// Description: Provides a MultiLogger class that forwards log messages and breakpoints to multiple logger instances, handling errors and supporting debug utilities.
//
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

import 'dart:developer' as dev;

import 'package:debug_utils/src/log_level.dart';
import 'package:debug_utils/src/logger_interfaces.dart';
import 'package:flutter/foundation.dart';

/// Forwards to multiple loggers; propagates breakpoint; logs internal errors.
class MultiLogger implements ILogger, IDebugLogger {
  final List<ILogger> loggers;
  final void Function(Object, StackTrace)? onLoggerError;

  MultiLogger(this.loggers, {this.onLoggerError});

  @override
  void log(
    String message, {
    required LogLevel level,
    String? tag,
    Object? errObj,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) {
    for (final lg in loggers) {
      try {
        lg.log(
          message,
          level: level,
          tag: tag,
          errObj: errObj,
          stackTrace: stackTrace,
          context: context,
        );
      } catch (e, st) {
        try {
          if (onLoggerError != null)
            onLoggerError!(e, st);
          else if (kDebugMode)
            dev.log('MultiLogger log error: $e', stackTrace: st);
        } catch (_) {}
      }
    }
  }

  @override
  void breakpoint() {
    for (final lg in loggers) {
      if (lg is IDebugLogger) {
        try {
          lg.breakpoint();
        } catch (e, st) {
          try {
            if (onLoggerError != null)
              onLoggerError!(e, st);
            else if (kDebugMode)
              dev.log('MultiLogger bp error: $e', stackTrace: st);
          } catch (_) {}
        }
      }
    }
  }
}
