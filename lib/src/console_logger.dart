// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
//
// Description:
// This file contains the implementation of a console logger utility for Dart applications.
// It provides functions and classes to output debug and log messages to the console,
// helping developers track application behavior and diagnose issues during development.
//
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

import 'dart:developer' as dev;

import 'package:debug_utils/src/caller_info_extractor.dart';
import 'package:debug_utils/src/log_formatter.dart';
import 'package:debug_utils/src/log_level.dart';
import 'package:debug_utils/src/logger_interfaces.dart';
import 'package:debug_utils/src/timestamp_provider.dart';

/// Logger writing to dev.log; supports breakpoint.
class ConsoleLogger implements IDebugLogger {
  final List<String> excludeMembers;

  ConsoleLogger({
    this.excludeMembers = const [
      'log',
      'debug',
      'info',
      'warning',
      'error',
      'trace',
      'breakpoint'
    ],
  });

  @override
  void log(
    String message, {
    required LogLevel level,
    String? tag,
    Object? errObj,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) {
    final caller = CallerInfoExtractor.extract(
      stackTrace,
      excludeMembers: excludeMembers,
      enableCallerInfo: stackTrace != null,
    );
    final formatted = defaultLogFormatter(
      level: level,
      message: message,
      caller: caller,
      timestamp: defaultTimestampProvider(),
      context: context,
    );
    dev.log(
      formatted,
      name: tag ?? '',
      error: errObj,
      stackTrace: stackTrace,
      level: level.priority,
    );
  }

  @override
  void breakpoint() => dev.debugger();
}
