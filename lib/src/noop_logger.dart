// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
// Description: Provides a no-operation (silent) logger implementation for use
// when logging is disabled or not required.
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

import 'package:debug_utils/src/logger_interfaces.dart';

/// Silent logger (no-op) that performs no action when recording logs.
///
/// Implements [ILogger] and is designed for scenarios where logging should
/// be disabled (e.g., production) without impacting performance.
class NoopLogger implements ILogger {
  @override

  /// Records a log entry without performing any action.
  ///
  /// [entry] is ignored to maintain compatibility with [ILogger].
  void log(LogEntry entry) {}
}
