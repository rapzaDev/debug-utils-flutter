// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
//
// Description: Log formatter for debug utilities in Flutter, allowing full customization of log output format.
//
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

import 'dart:convert';

import 'package:debug_utils/src/log_level.dart';
import 'package:debug_utils/src/logger_interfaces.dart';

class DefaultLogFormatter implements ILogFormatter {
  @override
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
