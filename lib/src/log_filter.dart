// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
// Description: Encapsulates runtime filter state for logging, allowing configuration
// of minimum log level and enabled tags. Provides methods to check if a log should
// be recorded based on these settings.
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

import 'package:debug_utils/src/logger_interfaces.dart';
import 'package:debug_utils/src/log_level.dart';

/// Log filter that controls which messages are recorded based on severity level
/// and tags.
///
/// Implements [ILogFilter] and is designed to be dynamically configurable,
/// ensuring efficiency and flexibility in production and test scenarios.
class LogFilter implements ILogFilter {
  /// Minimum log level to be recorded.
  LogLevel _minLevel;

  /// Set of enabled tags for filtering.
  final Set<String> _enabledTags;

  /// Constructor initializing the filter with default settings.
  ///
  /// [minLevel] defines the minimum log level (default: [LogLevel.trace]).
  /// [enabledTags] defines permitted tags (default: empty set).
  LogFilter({
    LogLevel minLevel = LogLevel.trace,
    Set<String>? enabledTags,
  })  : _minLevel = minLevel,
        _enabledTags = enabledTags != null ? Set.from(enabledTags) : <String>{};

  /// Reconfigures the filter at runtime.
  ///
  /// [minLevel] updates the minimum level (optional).
  /// [enabledTags] updates the enabled tags (optional).
  void configure({LogLevel? minLevel, Set<String>? enabledTags}) {
    if (minLevel != null) _minLevel = minLevel;
    if (enabledTags != null) {
      _enabledTags.clear();
      _enabledTags.addAll(enabledTags);
    }
  }

  @override

  /// Checks if a message should be recorded based on level and tag.
  ///
  /// [level] is the severity level of the message.
  /// [tag] is the associated tag (optional).
  /// Returns true if the message meets the filtering criteria.
  bool shouldLog(LogLevel level, String? tag) {
    if (level.priority < _minLevel.priority) return false;
    return _enabledTags.isEmpty
        ? true
        : tag != null && _enabledTags.contains(tag);
  }
}
