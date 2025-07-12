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

/// Interface for general loggers (without breakpoint).
abstract class ILogger {
  void log(
    String message, {
    required LogLevel level,
    String? tag,
    Object? errObj,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  });
}

/// Interface for loggers that support breakpoint (debuggers).
abstract class IDebugLogger implements ILogger {
  void breakpoint();
}
