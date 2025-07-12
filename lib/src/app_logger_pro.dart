// lib/src/app_logger_pro.dart
import 'dart:developer' show debugger;
import 'package:flutter/foundation.dart';
import 'package:debug_utils/src/logger_interfaces.dart';
import 'package:debug_utils/src/log_level.dart';
import 'package:debug_utils/src/log_filter.dart';
import 'package:debug_utils/src/console_logger.dart';
import 'package:debug_utils/src/multi_logger.dart';
import 'package:debug_utils/src/timestamp_provider.dart';
import 'package:debug_utils/src/caller_info_extractor.dart';

typedef PlatformDispatcherExceptionHandler = bool Function(
    Object error, StackTrace stackTrace);

abstract class BreakpointStrategy {
  void trigger();
}

class DefaultBreakpointStrategy implements BreakpointStrategy {
  @override
  void trigger() {
    assert(() {
      debugger();
      return true;
    }());
  }
}

class NoOpBreakpointStrategy implements BreakpointStrategy {
  @override
  void trigger() {
    // No operation - safe for tests
  }
}

class AppLoggerPro {
  static AppLoggerPro? _instance;

  final ILogger _logger;
  final ILogFilter _filter;
  final bool _enableCallerInfo;
  final FlutterExceptionHandler? _prevFlutterErrorHandler;
  final PlatformDispatcherExceptionHandler? _prevPlatformErrorHandler;
  final ITimestampProvider _timestampProvider;
  final ICallerInfoExtractor _callerInfoExtractor;
  final BreakpointStrategy _breakpointStrategy;

  AppLoggerPro._(
    this._logger,
    this._filter,
    this._enableCallerInfo,
    this._prevFlutterErrorHandler,
    this._prevPlatformErrorHandler,
    this._timestampProvider,
    this._callerInfoExtractor,
    this._breakpointStrategy,
  ) {
    if (_prevFlutterErrorHandler != null) {
      FlutterError.onError = (details) {
        _prevFlutterErrorHandler?.call(details);
        error(details.exceptionAsString(),
            errObj: details.exception,
            stackTrace: details.stack,
            tag: 'FlutterError');
      };
    }
    if (_prevPlatformErrorHandler != null) {
      PlatformDispatcher.instance.onError = (err, st) {
        _prevPlatformErrorHandler?.call(err, st);
        error(err.toString(),
            errObj: err, stackTrace: st, tag: 'PlatformError');
        return true;
      };
    }
  }

  static AppLoggerPro init({
    ILogger? debugLogger,
    ILogger? releaseLogger,
    ILogFilter? logFilter,
    bool enableCallerInfo = true,
    bool attachGlobalErrorHandlers = true,
    bool forceDebugMode = false,
    ITimestampProvider? timestampProvider,
    ICallerInfoExtractor? callerInfoExtractor,
    BreakpointStrategy? breakpointStrategy,
  }) {
    if (_instance != null) throw StateError('Already initialized');

    final isDebug = forceDebugMode || kDebugMode;

    final logger = isDebug
        ? MultiLogger([debugLogger ?? ConsoleLogger()])
        : releaseLogger ?? ConsoleLogger();

    final prevFlutterError =
        attachGlobalErrorHandlers ? FlutterError.onError : null;
    final prevPlatformError =
        attachGlobalErrorHandlers ? PlatformDispatcher.instance.onError : null;

    _instance = AppLoggerPro._(
      logger,
      logFilter ?? LogFilter(),
      enableCallerInfo,
      prevFlutterError,
      prevPlatformError,
      timestampProvider ?? DefaultTimestampProvider(),
      callerInfoExtractor ?? DefaultCallerInfoExtractor(),
      breakpointStrategy ?? DefaultBreakpointStrategy(),
    );

    return _instance!;
  }

  static AppLoggerPro get instance {
    if (_instance == null) throw StateError('Call init() first');
    return _instance!;
  }

  static void resetInstanceForTesting() {
    _instance?._restoreHandlers();
    _instance = null;
  }

  void _restoreHandlers() {
    if (_prevFlutterErrorHandler != null) {
      FlutterError.onError = _prevFlutterErrorHandler!;
    }
    if (_prevPlatformErrorHandler != null) {
      PlatformDispatcher.instance.onError = _prevPlatformErrorHandler!;
    }
  }

  void _log(
    String message, {
    required LogLevel level,
    String? tag,
    Object? errObj,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) {
    if (!_filter.shouldLog(level, tag)) return;

    final caller = _enableCallerInfo
        ? _callerInfoExtractor.extract(stackTrace ?? StackTrace.current) ??
            'NO_CALLER'
        : 'CALLER_DISABLED';

    final fullMessage = (level == LogLevel.error || level == LogLevel.fatal) &&
            stackTrace != null
        ? '$message\n$stackTrace'
        : message;

    final entry = LogEntry(
      level: level,
      message: fullMessage,
      tag: tag,
      errObj: errObj,
      stackTrace: stackTrace,
      context: context,
      caller: caller,
      timestamp: _timestampProvider.currentTimestamp,
    );

    _logger.log(entry);
  }

  // Métodos públicos para cada nível de log:
  void trace(String msg,
          {String? tag,
          Object? errObj,
          StackTrace? stackTrace,
          Map<String, Object?>? context}) =>
      _log(msg,
          level: LogLevel.trace,
          tag: tag,
          errObj: errObj,
          stackTrace: stackTrace,
          context: context);

  void debug(String msg,
          {String? tag,
          Object? errObj,
          StackTrace? stackTrace,
          Map<String, Object?>? context}) =>
      _log(msg,
          level: LogLevel.debug,
          tag: tag,
          errObj: errObj,
          stackTrace: stackTrace,
          context: context);

  void info(String msg,
          {String? tag,
          Object? errObj,
          StackTrace? stackTrace,
          Map<String, Object?>? context}) =>
      _log(msg,
          level: LogLevel.info,
          tag: tag,
          errObj: errObj,
          stackTrace: stackTrace,
          context: context);

  void warning(String msg,
          {String? tag,
          Object? errObj,
          StackTrace? stackTrace,
          Map<String, Object?>? context}) =>
      _log(msg,
          level: LogLevel.warning,
          tag: tag,
          errObj: errObj,
          stackTrace: stackTrace,
          context: context);

  void error(String msg,
          {String? tag,
          Object? errObj,
          StackTrace? stackTrace,
          Map<String, Object?>? context}) =>
      _log(msg,
          level: LogLevel.error,
          tag: tag,
          errObj: errObj,
          stackTrace: stackTrace,
          context: context);

  void fatal(String msg,
          {String? tag,
          Object? errObj,
          StackTrace? stackTrace,
          Map<String, Object?>? context}) =>
      _log(msg,
          level: LogLevel.fatal,
          tag: tag,
          errObj: errObj,
          stackTrace: stackTrace,
          context: context);

  void verbose(String msg,
          {String? tag,
          Object? errObj,
          StackTrace? stackTrace,
          Map<String, Object?>? context}) =>
      _log(msg,
          level: LogLevel.verbose,
          tag: tag,
          errObj: errObj,
          stackTrace: stackTrace,
          context: context);

  void breakpoint() {
    _breakpointStrategy.trigger();
  }

  void dispose() => _restoreHandlers();
}
