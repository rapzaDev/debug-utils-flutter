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

/// Log formatter type for full customization.
typedef LogFormatter = String Function({
  required LogLevel level,
  required String message,
  required String caller,
  required String timestamp,
  Map<String, Object?>? context,
});

/// Default formatter: ISO timestamp, level, caller, message, JSON context.
String defaultLogFormatter({
  required LogLevel level,
  required String message,
  required String caller,
  required String timestamp,
  Map<String, Object?>? context,
}) {
  var ctx = '';
  // If context is null or empty, we don't append it.
  if (context != null && context.isNotEmpty) {
    try {
      ctx = ' ${jsonEncode(context)}';
    } catch (_) {
      ctx =
          ' {${context.entries.map((e) => '${e.key}=${e.value}').join(', ')}}';
    }
  }
  return '[$timestamp][${level.label}][$caller] $message$ctx';
}
