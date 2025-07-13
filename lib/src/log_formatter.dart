// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
// Description: Log formatter for debug utilities in Flutter, allowing full
// customization of log output format.
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

import 'dart:convert';

import 'package:debug_utils/src/log_level.dart';
import 'package:debug_utils/src/logger_interfaces.dart';

/// Default log formatter that structures output with timestamp, level, caller,
/// and context.
///
/// Implements [ILogFormatter] and is designed to be extensible, handling complex
/// contexts and serialization failures robustly.
class DefaultLogFormatter implements ILogFormatter {
  @override

  /// Formats a log entry into a readable string.
  ///
  /// [entry] contains the details of the message to be formatted.
  /// Returns a string in the format `[timestamp][level][caller] message [context]`.
  /// The context is serialized as JSON, with a fallback to simple formatting
  /// in case of errors (e.g., non-serializable objects like DateTime).
  String format(LogEntry entry) {
    var ctx = '';
    if (entry.context != null && entry.context!.isNotEmpty) {
      try {
        ctx = ' ${jsonEncode(entry.context)}';
      } catch (_) {
        ctx =
            ' {${entry.context!.entries.map((e) => '${e.key}=${e.value}').join(', ')}}';
      }
    }
    return '[${entry.timestamp}][${entry.level.label}][${entry.caller}] ${entry.message}$ctx';
  }
}
