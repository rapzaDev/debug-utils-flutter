// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
//
// Description: Encapsulates runtime filter state for logging, allowing configuration of minimum log level and enabled tags. Provides methods to check if a log should be recorded based on these settings.
//
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

import 'package:debug_utils/src/logger_interfaces.dart';
import 'package:debug_utils/src/log_level.dart';

class LogFilter implements ILogFilter {
  LogLevel _minLevel;
  final Set<String> _enabledTags;

  LogFilter({
    LogLevel minLevel = LogLevel.trace,
    Set<String>? enabledTags,
  })  : _minLevel = minLevel,
        _enabledTags = enabledTags != null ? Set.from(enabledTags) : <String>{};

  void configure({LogLevel? minLevel, Set<String>? enabledTags}) {
    if (minLevel != null) _minLevel = minLevel;
    if (enabledTags != null) {
      _enabledTags.clear();
      _enabledTags.addAll(enabledTags);
    }
  }

  @override
  bool shouldLog(LogLevel level, String? tag) {
    if (level.priority < _minLevel.priority) return false;
    return _enabledTags.isEmpty
        ? true
        : tag != null && _enabledTags.contains(tag);
  }
}
