// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
//
// Description:
// Provides a singleton facade for advanced logging in Flutter/Dart apps,
// supporting multiple loggers, log filtering, caller info, and integration
// with global Flutter and platform error handlers. Designed for flexible
// debugging and production logging with easy initialization and testability.
//
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

import 'package:debug_utils/src/console_logger.dart';
import 'package:debug_utils/src/log_filter.dart';
import 'package:debug_utils/src/log_level.dart';
import 'package:debug_utils/src/logger_interfaces.dart';
import 'package:debug_utils/src/multi_logger.dart';
import 'package:debug_utils/src/noop_logger.dart';
import 'package:flutter/foundation.dart';

/// Typedef for PlatformDispatcher error handler
typedef PlatformDispatcherExceptionHandler = bool Function(
    Object error, StackTrace stackTrace);

/// Facade singleton with explicit init, instance, and reset for testing.
class AppLoggerPro {
  static AppLoggerPro? _instance;

  final ILogger _logger;
  final LogFilter _filter;
  final bool _enableCallerInfo;
  final FlutterExceptionHandler? _prevFlutterErrorHandler;
  final PlatformDispatcherExceptionHandler? _prevPlatformErrorHandler;

  AppLoggerPro._(
    this._logger,
    this._filter,
    this._enableCallerInfo,
    this._prevFlutterErrorHandler,
    this._prevPlatformErrorHandler,
  ) {
    if (_prevFlutterErrorHandler != null) {
      FlutterError.onError = (details) {
        _prevFlutterErrorHandler?.call(details);
        error(
          details.exceptionAsString(),
          errObj: details.exception,
          stackTrace: details.stack,
          tag: 'FlutterError',
        );
      };
    }
    if (_prevPlatformErrorHandler != null) {
      PlatformDispatcher.instance.onError = (err, st) {
        _prevPlatformErrorHandler?.call(err, st);
        error(
          err.toString(),
          errObj: err,
          stackTrace: st,
          tag: 'PlatformError',
        );
        return true;
      };
    }
  }

  /// Initialize once; throws if already inited.
  static void init({
    ILogger? debugLogger,
    ILogger? releaseLogger,
    LogFilter? filter,
    bool enableCallerInfo = true,
    bool attachGlobalErrorHandlers = true,
    bool forceDebugMode = false,
  }) {
    if (_instance != null) throw StateError('Already initialized');

    final isDebug = forceDebugMode || kDebugMode;

    final lg = isDebug
        ? MultiLogger([debugLogger ?? ConsoleLogger()])
        : releaseLogger ?? NoopLogger();

    final prevFE = attachGlobalErrorHandlers ? FlutterError.onError : null;

    final prevPD =
        attachGlobalErrorHandlers ? PlatformDispatcher.instance.onError : null;

    _instance = AppLoggerPro._(
      lg,
      filter ?? LogFilter(),
      enableCallerInfo,
      prevFE,
      prevPD,
    );
  }

  static AppLoggerPro get instance {
    if (_instance == null) throw StateError('Call init() first');
    return _instance!;
  }

  /// Reset for testing purposes.
  static void resetInstanceForTesting() {
    _instance?._restoreHandlers();
    _instance = null;
  }

  void _restoreHandlers() {
    if (_prevFlutterErrorHandler != null)
      FlutterError.onError = _prevFlutterErrorHandler!;
    if (_prevPlatformErrorHandler != null)
      PlatformDispatcher.instance.onError = _prevPlatformErrorHandler!;
  }

  bool _shouldLog(LogLevel level, String? tag) => _filter.shouldLog(level, tag);

  void _log(
    String message, {
    required LogLevel level,
    String? tag,
    Object? errObj,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) {
    if (!_shouldLog(level, tag)) return;
    final effStack = _enableCallerInfo ? stackTrace : null;
    _logger.log(
      message,
      level: level,
      tag: tag,
      errObj: errObj,
      stackTrace: effStack,
      context: context,
    );
  }

  void trace(
    String msg, {
    String? tag,
    Object? errObj,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) =>
      _log(
        msg,
        level: LogLevel.trace,
        tag: tag,
        errObj: errObj,
        stackTrace: stackTrace,
        context: context,
      );

  void debug(
    String msg, {
    String? tag,
    Object? errObj,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) =>
      _log(
        msg,
        level: LogLevel.debug,
        tag: tag,
        errObj: errObj,
        stackTrace: stackTrace,
        context: context,
      );

  void info(
    String msg, {
    String? tag,
    Object? errObj,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) =>
      _log(
        msg,
        level: LogLevel.info,
        tag: tag,
        errObj: errObj,
        stackTrace: stackTrace,
        context: context,
      );

  void warning(
    String msg, {
    String? tag,
    Object? errObj,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) =>
      _log(
        msg,
        level: LogLevel.warning,
        tag: tag,
        errObj: errObj,
        stackTrace: stackTrace,
        context: context,
      );

  void error(
    String msg, {
    String? tag,
    Object? errObj,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) =>
      _log(
        msg,
        level: LogLevel.error,
        tag: tag,
        errObj: errObj,
        stackTrace: stackTrace,
        context: context,
      );

  void breakpoint() {
    if (_logger is IDebugLogger) (_logger as IDebugLogger).breakpoint();
  }

  /// Public dispose for cleanup.
  void dispose() => _restoreHandlers();
}
