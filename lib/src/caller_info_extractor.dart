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

import 'package:debug_utils/src/logger_interfaces.dart';
import 'package:stack_trace/stack_trace.dart';
import 'dart:collection';

class DefaultCallerInfoExtractor implements ICallerInfoExtractor {
  static const int _cacheMaxSize = 1000;
  final LinkedHashMap<String, String> _cache = LinkedHashMap();

  @override
  String? extract(StackTrace stackTrace) {
    final traceString = stackTrace.toString();

    if (_cache.containsKey(traceString)) {
      final cached = _cache.remove(traceString)!;
      _cache[traceString] = cached; // refresh LRU order
      return cached;
    }

    try {
      final chain = Chain.forTrace(stackTrace);
      for (final frame in chain.toTrace().frames) {
        final member = frame.member ?? '';
        if (!_isExcluded(member)) {
          final caller =
              '${member}@${frame.uri.pathSegments.last}:${frame.line}';
          _addToCache(traceString, caller);
          return caller;
        }
      }
    } catch (_) {
      // fallback silently
    }

    const unknown = 'UNKNOWN_CALLER';
    _addToCache(traceString, unknown);
    return unknown;
  }

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

  void _addToCache(String key, String value) {
    if (_cache.length >= _cacheMaxSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }
}
