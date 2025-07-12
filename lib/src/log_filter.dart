// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
//
// Description: Encapsulates runtime filter state for logging, allowing configuration of minimum log level and enabled tags. Provides methods to check if a log should be recorded based on these settings.
//
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

import 'package:debug_utils/src/log_level.dart';

/// Encapsulates runtime filter state; copies sets to avoid external mutation.
class LogFilter {
  LogLevel _minLevel;
  Set<String> _enabledTags;

  LogFilter({
    LogLevel minLevel = LogLevel.trace,
    Set<String>? enabledTags,
  })  : _minLevel = minLevel,
        _enabledTags = enabledTags != null ? Set.from(enabledTags) : <String>{};

  LogLevel get minLevel => _minLevel;
  Set<String> get enabledTags => Set.unmodifiable(_enabledTags);

  void configure({LogLevel? minLevel, Set<String>? enabledTags}) {
    if (minLevel != null) _minLevel = minLevel;
    if (enabledTags != null) _enabledTags = Set.from(enabledTags);
  }

  bool shouldLog(LogLevel level, String? tag) {
    if (level.priority < _minLevel.priority) return false;
    return _enabledTags.isEmpty
        ? true
        : tag != null && _enabledTags.contains(tag);
  }
}
