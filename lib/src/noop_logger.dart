// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
//
// Description: Provides a no-operation (silent) logger implementation for use when logging is disabled or not required.
//
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

import 'package:debug_utils/src/log_level.dart';
import 'package:debug_utils/src/logger_interfaces.dart';

/// Silent logger (no-op).
class NoopLogger implements ILogger {
  @override
  void log(
    String message, {
    required LogLevel level,
    String? tag,
    Object? errObj,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) {}
}
