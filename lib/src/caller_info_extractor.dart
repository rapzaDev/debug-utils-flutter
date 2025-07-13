// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
// Description: Utility for extracting caller information (e.g., method name,
// file, and line number) from a StackTrace. Utilizes the `stack_trace` package
// for improved parsing accuracy and implements an LRU (Least Recently Used)
// cache to optimize performance for repeated logging from the same locations.
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

import 'package:debug_utils/src/logger_interfaces.dart';
import 'package:stack_trace/stack_trace.dart';
import 'dart:collection';

/// Default caller information extractor, optimized with an LRU cache for
/// performance in intensive logging scenarios.
///
/// Implements [ICallerInfoExtractor] and is designed to be thread-safe and
/// efficient, avoiding unnecessary reprocessing of stack traces.
class DefaultCallerInfoExtractor implements ICallerInfoExtractor {
  /// Maximum size of the LRU cache to prevent excessive memory usage.
  static const int _cacheMaxSize = 1000;

  /// LRU cache storing associations between stack traces and caller information.
  final LinkedHashMap<String, String> _cache = LinkedHashMap();

  @override

  /// Extracts caller information from a [stackTrace].
  ///
  /// Returns a string in the format `method@file:line` or `UNKNOWN_CALLER` if
  /// extraction fails. Uses caching to optimize repeated calls.
  /// [stackTrace] is the stack trace to be analyzed.
  /// May return null in critical failure cases but uses a safe fallback.
  String? extract(StackTrace stackTrace) {
    final traceString = stackTrace.toString();

    /// Checks if the stack trace is in the cache to avoid reprocessing.
    if (_cache.containsKey(traceString)) {
      final cached = _cache.remove(traceString)!;
      _cache[traceString] = cached; // Updates LRU order.
      return cached;
    }

    try {
      /// Converts the stack trace into an analyzable chain.
      final chain = Chain.forTrace(stackTrace);
      for (final frame in chain.toTrace().frames) {
        final member = frame.member ?? '';

        /// Excludes internal or irrelevant methods to avoid noise.
        if (!_isExcluded(member)) {
          final caller =
              '${member}@${frame.uri.pathSegments.last}:${frame.line}';
          _addToCache(traceString, caller);
          return caller;
        }
      }
    } catch (_) {
      // Silences exceptions to ensure robustness.
    }

    const unknown = 'UNKNOWN_CALLER';
    _addToCache(traceString, unknown);
    return unknown;
  }

  /// Checks if a method name should be excluded from extraction.
  ///
  /// [member] is the method name to evaluate.
  /// Returns true if the method is in the exclusion list.
  bool _isExcluded(String member) {
    const excludes = [
      'log',
      'debug',
      'info',
      'warning',
      'error',
      'trace',
      'breakpoint',
      'fatal',
      'verbose',
      'DefaultCallerInfoExtractor.extract',
    ];
    return excludes
        .any((ex) => member.toLowerCase().contains(ex.toLowerCase()));
  }

  /// Adds an entry to the LRU cache, removing the least recent if necessary.
  ///
  /// [key] is the stack trace string.
  /// [value] is the extracted caller information.
  void _addToCache(String key, String value) {
    if (_cache.length >= _cacheMaxSize) {
      _cache.remove(_cache.keys.first); // Removes the least recent entry.
    }
    _cache[key] = value;
  }
}
