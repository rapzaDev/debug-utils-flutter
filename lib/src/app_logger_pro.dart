import 'dart:developer' show debugger;
import 'package:flutter/foundation.dart';
import 'package:debug_utils/src/logger_interfaces.dart';
import 'package:debug_utils/src/log_level.dart';
import 'package:debug_utils/src/log_filter.dart';
import 'package:debug_utils/src/console_logger.dart';
import 'package:debug_utils/src/multi_logger.dart';
import 'package:debug_utils/src/timestamp_provider.dart';
import 'package:debug_utils/src/caller_info_extractor.dart';

// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
// Description: The primary class of the `debug_utils` package, responsible for
// managing professional logging in Flutter applications. Provides a configurable
// singleton that supports multiple log levels, breakpoints, and global error
// handling, optimized for debugging during development and tracking in production.
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

/// The primary class of the `debug_utils` package, responsible for managing
/// professional logging in Flutter applications. Provides a configurable singleton
/// that supports multiple log levels, breakpoints, and global error handling,
/// optimized for debugging during development and tracking in production.
///
/// This class is thread-safe and uses a singleton pattern to ensure a single
/// global instance. It is designed to be extensible and testable, with support
/// for custom logging strategies and breakpoint implementations.
class AppLoggerPro {
  /// The singleton instance of the logger, initialized via the `init` method.
  static AppLoggerPro? _instance;

  /// The primary logger responsible for processing and recording log entries.
  final ILogger _logger;

  /// Log filter that determines which messages are recorded based on level and tags.
  final ILogFilter _filter;

  /// Indicates whether caller information (e.g., method, file, line) should be
  /// included in logs.
  final bool _enableCallerInfo;

  /// The previous Flutter error handler, preserved for restoration.
  final FlutterExceptionHandler? _prevFlutterErrorHandler;

  /// The previous platform error handler, preserved for restoration.
  final PlatformDispatcherExceptionHandler? _prevPlatformErrorHandler;

  /// Timestamp provider for adding timestamps to logs.
  final ITimestampProvider _timestampProvider;

  /// Caller information extractor from the stack trace.
  final ICallerInfoExtractor _callerInfoExtractor;

  /// Breakpoint strategy for pausing execution at specific points.
  final BreakpointStrategy _breakpointStrategy;

  /// Private constructor for controlled initialization via `init`.
  ///
  /// [logger] is the primary logger.
  /// [filter] defines log filtering criteria.
  /// [enableCallerInfo] controls inclusion of caller information.
  /// [prevFlutterErrorHandler] stores the previous Flutter error handler.
  /// [prevPlatformErrorHandler] stores the previous platform error handler.
  /// [timestampProvider] provides timestamps.
  /// [callerInfoExtractor] extracts caller information.
  /// [breakpointStrategy] defines the breakpoint logic.
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
    /// Configures the Flutter error handler if a previous one exists.
    if (_prevFlutterErrorHandler != null) {
      FlutterError.onError = (details) {
        _prevFlutterErrorHandler?.call(details);
        error(details.exceptionAsString(),
            errObj: details.exception,
            stackTrace: details.stack,
            tag: 'FlutterError');
      };
    }

    /// Configures the platform error handler if a previous one exists.
    if (_prevPlatformErrorHandler != null) {
      PlatformDispatcher.instance.onError = (err, st) {
        _prevPlatformErrorHandler?.call(err, st);
        error(err.toString(),
            errObj: err, stackTrace: st, tag: 'PlatformError');
        return true;
      };
    }
  }

  /// Initializes the singleton logger instance with customizable settings.
  ///
  /// Throws [StateError] if the logger is already initialized.
  /// [debugLogger] is used in debug mode (default: [ConsoleLogger]).
  /// [releaseLogger] is used in release mode (default: [ConsoleLogger]).
  /// [logFilter] defines log filters (default: [LogFilter]).
  /// [enableCallerInfo] enables caller information (default: true).
  /// [attachGlobalErrorHandlers] activates global error capturing (default: true).
  /// [forceDebugMode] forces debug mode, overriding [kDebugMode] (default: false).
  /// [timestampProvider] customizes the timestamp provider (default: [DefaultTimestampProvider]).
  /// [callerInfoExtractor] customizes the caller extractor (default: [DefaultCallerInfoExtractor]).
  /// [breakpointStrategy] customizes the breakpoint strategy (default: [DefaultBreakpointStrategy]).
  /// Returns the initialized instance.
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

  /// Returns the singleton logger instance.
  ///
  /// Throws [StateError] if `init()` has not been called previously.
  static AppLoggerPro get instance {
    if (_instance == null) throw StateError('Call init() first');
    return _instance!;
  }

  /// Resets the singleton instance to null, restoring global handlers.
  /// Used exclusively in testing to ensure isolation between test cases.
  static void resetInstanceForTesting() {
    _instance?._restoreHandlers();
    _instance = null;
  }

  /// Restores the global error handlers to their previous state.
  /// Called internally by [resetInstanceForTesting] or [dispose].
  void _restoreHandlers() {
    if (_prevFlutterErrorHandler != null) {
      FlutterError.onError = _prevFlutterErrorHandler!;
    }
    if (_prevPlatformErrorHandler != null) {
      PlatformDispatcher.instance.onError = _prevPlatformErrorHandler!;
    }
  }

  /// Records a log entry based on the provided parameters.
  ///
  /// [message] is the message to be recorded.
  /// [level] defines the severity level of the log (required).
  /// [tag] identifies the module or context of the log (optional).
  /// [errObj] contains the associated error object (optional).
  /// [stackTrace] provides the stack trace (optional).
  /// [context] includes additional data in map format (optional).
  /// The method skips logging if [filter.shouldLog] returns false.
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

  /// Records a message at `trace` level.
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

  /// Records a message at `debug` level.
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

  /// Records a message at `info` level.
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

  /// Records a message at `warning` level.
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

  /// Records a message at `error` level.
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

  /// Records a message at `fatal` level.
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

  /// Records a message at `verbose` level.
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

  /// Triggers a breakpoint to pause execution and allow debugger inspection.
  void breakpoint() {
    _breakpointStrategy.trigger();
  }

  /// Releases resources, restoring global error handlers.
  void dispose() => _restoreHandlers();
}

/// Defines an exception handler for the Dart/Flutter platform.
typedef PlatformDispatcherExceptionHandler = bool Function(
    Object error, StackTrace stackTrace);

/// Abstract strategy for implementing breakpoints.
abstract class BreakpointStrategy {
  /// Triggers a breakpoint, enabling debugger inspection.
  void trigger();
}

/// Default implementation of the breakpoint strategy, using Dart's `debugger()`.
class DefaultBreakpointStrategy implements BreakpointStrategy {
  @override
  void trigger() {
    assert(() {
      debugger(); // Pauses execution in debug mode.
      return true;
    }());
  }
}

/// Null implementation of the breakpoint strategy, performing no action, safe for tests.
class NoOpBreakpointStrategy implements BreakpointStrategy {
  @override
  void trigger() {
    // No operation - safe for test environments.
  }
}
