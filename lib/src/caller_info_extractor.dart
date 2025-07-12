// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
//
// Description:
// This utility extracts **caller information** (e.g. method name, file, and line number)
// from a StackTrace. It uses the `stack_trace` package to improve parsing accuracy,
// and it implements an LRU (Least Recently Used) cache to avoid redundant parsing,
// optimizing performance when logging repeatedly from the same places.
//
// This is extremely useful in debugging, logging, error tracking, or analytics.
//
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

import 'dart:developer' as dev; // Used to log errors during debug mode
import 'package:flutter/foundation.dart'; // Used to check if app is in debug mode
import 'package:stack_trace/stack_trace.dart'; // Advanced stack trace parsing

/// This class provides static methods to extract caller information (method, file, line).
/// It's designed for logging/debugging tools that want to know *where* a log was triggered.
class CallerInfoExtractor {
  /// Maximum number of cached stack traces (LRU cache strategy).
  /// Prevents memory leak from uncontrolled cache growth.
  static const _cacheMaxSize = 1000;

  /// The actual cache storing previously extracted caller info.
  /// Key: raw StackTrace string, Value: extracted caller string.
  static final _cache = <String, String>{};

  /// Value returned when caller info is disabled.
  static const _noCallerInfo = 'NO_CALLER_INFO';

  /// Extracts the caller (function, file, line) from a stack trace.
  ///
  /// Params:
  /// - [stackTrace]: custom trace or null to use current trace.
  /// - [excludeMembers]: list of method names to ignore during stack parsing.
  /// - [enableCallerInfo]: disables the parsing entirely when false (e.g. in production).
  ///
  /// Returns a formatted string like "myFunction@main.dart:42"
  static String extract(
    StackTrace? stackTrace, {
    List<String> excludeMembers = const [
      'log',
      'debug',
      'info',
      'warning',
      'error',
      'trace',
      'breakpoint',
    ],
    bool enableCallerInfo = true,
  }) {
    // If caller info is disabled, return the default fallback
    if (!enableCallerInfo) return _noCallerInfo;

    // Use passed stack trace or generate current one
    final traceObj = stackTrace ?? StackTrace.current;

    // Use full string of the trace as the cache key
    final traceKey = traceObj.toString();

    // If the trace has already been parsed, return the cached result
    if (_cache.containsKey(traceKey)) {
      // To apply LRU strategy, move the accessed key to the end
      final cached = _cache.remove(traceKey)!;
      _cache[traceKey] = cached;
      return cached;
    }

    try {
      // Use the Chain API for accurate parsing (via stack_trace package)
      final chain = Chain.forTrace(traceObj);

      // Loop through each frame in the stack trace
      for (final frame in chain.toTrace().frames) {
        // Get the function or method name
        final member = frame.member ?? '';

        // Skip logging utility functions like "log", "debug", etc.
        final isExcluded = excludeMembers.any(
          (ex) => member.toLowerCase().contains(ex.toLowerCase()),
        );
        if (!isExcluded) {
          // Build the caller string: e.g., "doCheckout@cart_service.dart:42"
          final caller =
              '${member}@${frame.uri.pathSegments.last}:${frame.line}';

          // If cache is too big, remove the oldest (LRU logic)
          if (_cache.length >= _cacheMaxSize) {
            _cache.remove(_cache.keys.first);
          }

          // Cache the result and return it
          _cache[traceKey] = caller;
          return caller;
        }
      }
    } catch (e, st) {
      // If something goes wrong, log it in debug mode only
      if (kDebugMode) {
        dev.log('CallerInfoExtractor error: $e', stackTrace: st);
      }
      return 'UNKNOWN_CALLER';
    }

    // If no caller could be determined, use this default
    final unknown = 'UNKNOWN_CALLER';

    // Cache the unknown result to avoid re-parsing
    if (_cache.length >= _cacheMaxSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[traceKey] = unknown;
    return unknown;
  }
}
