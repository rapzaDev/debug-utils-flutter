import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:debug_utils/debug_utils.dart';
import 'dart:async';

class TestNoOpBreakpointStrategy implements BreakpointStrategy {
  bool triggered = false;

  @override
  void trigger() {
    triggered = true; // marca que foi chamado, mas não trava o teste
  }
}

void main() {
  tearDown(() {
    // Reset global handlers and singleton between tests
    FlutterError.onError = null;
    PlatformDispatcher.instance.onError = null;
    AppLoggerPro.resetInstanceForTesting();
  });

  group('AppLoggerPro', () {
    test('initializes and throws on re-init', () {
      final logger = AppLoggerPro.init(
        forceDebugMode: true,
        attachGlobalErrorHandlers: false,
        debugLogger: TestLogger((entry) {}),
        breakpointStrategy: TestNoOpBreakpointStrategy(),
      );
      expect(logger, isNotNull);
      expect(() => AppLoggerPro.init(), throwsStateError);
    });

    test('logs respecting filter', () {
      bool logged = false;
      final testLogger = TestLogger((entry) {
        logged = true;
        expect(entry.level.priority >= LogLevel.warning.priority, isTrue);
      });

      AppLoggerPro.init(
        forceDebugMode: true,
        attachGlobalErrorHandlers: false,
        logFilter: LogFilter(minLevel: LogLevel.warning),
        debugLogger: testLogger,
        breakpointStrategy: TestNoOpBreakpointStrategy(),
      );

      AppLoggerPro.instance.info('info'); // should NOT log
      expect(logged, false);

      AppLoggerPro.instance.warning('warning'); // should log
      expect(logged, true);
    });

    test('breakpoint triggers if logger supports', () {
      final breakpointStrategy = TestNoOpBreakpointStrategy();
      AppLoggerPro.init(
        forceDebugMode: true,
        attachGlobalErrorHandlers: false,
        debugLogger: TestDebugLogger(),
        breakpointStrategy: breakpointStrategy,
      );

      AppLoggerPro.instance.breakpoint();

      expect(breakpointStrategy.triggered, isTrue);
    });
  });

  group('LogFilter', () {
    late LogFilter filter;

    setUp(() {
      filter = LogFilter(minLevel: LogLevel.info, enabledTags: {'tag1'});
    });

    test('blocks levels below minLevel', () {
      expect(filter.shouldLog(LogLevel.debug, 'tag1'), false);
    });

    test('allows levels above minLevel', () {
      expect(filter.shouldLog(LogLevel.warning, 'tag1'), true);
    });

    test('blocks tags not in enabledTags', () {
      expect(filter.shouldLog(LogLevel.error, 'otherTag'), false);
    });

    test('allows when enabledTags is empty (no tag filtering)', () {
      final f = LogFilter(minLevel: LogLevel.info);
      expect(f.shouldLog(LogLevel.info, 'anything'), true);
    });

    test('configure updates minLevel and enabledTags', () {
      filter.configure(minLevel: LogLevel.error, enabledTags: {'newTag'});
      expect(filter.shouldLog(LogLevel.warning, 'newTag'), false);
      expect(filter.shouldLog(LogLevel.error, 'newTag'), true);
      expect(filter.shouldLog(LogLevel.error, 'tag1'), false);
    });
  });

  group('ConsoleLogger', () {
    test('formats and prints log entries', () async {
      final buffer = <String>[];
      final formatter = DefaultLogFormatter();
      final logger = ConsoleLogger(formatter: formatter);

      final logEntry = LogEntry(
        level: LogLevel.info,
        message: 'Test message',
        caller: 'CallerInfo',
        timestamp: '2025-07-12T00:00:00Z',
      );

      await runZonedGuarded(
        () async {
          logger.log(logEntry);
        },
        (e, st) {},
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) {
            buffer.add(line);
          },
        ),
      );

      expect(buffer.length, 1);
      expect(buffer.first, contains('Test message'));
      expect(buffer.first, contains('CallerInfo'));
      expect(buffer.first, contains('INFO'));
      expect(buffer.first, contains('2025-07-12T00:00:00Z'));
    });
  });

  group('DefaultLogFormatter', () {
    test('formats log entry without context correctly', () {
      final formatter = DefaultLogFormatter();
      final entry = LogEntry(
        level: LogLevel.debug,
        message: 'msg',
        caller: 'caller',
        timestamp: 'time',
      );
      final output = formatter.format(entry);
      expect(output, contains('msg'));
      expect(output, contains('caller'));
      expect(output, contains('DEBUG'));
      expect(output, contains('time'));
    });

    test('formats log entry with context as JSON', () {
      final formatter = DefaultLogFormatter();
      final entry = LogEntry(
        level: LogLevel.debug,
        message: 'msg',
        caller: 'caller',
        timestamp: 'time',
        context: {'key': 'value'},
      );
      final output = formatter.format(entry);
      expect(output, contains('"key":"value"'));
    });

    test('formats log entry with context fallback on JSON error', () {
      final formatter = DefaultLogFormatter();
      final entry = LogEntry(
        level: LogLevel.debug,
        message: 'msg',
        caller: 'caller',
        timestamp: 'time',
        context: {
          'bad': DateTime.now(), // JSON encoding DateTime fails
        },
      );
      final output = formatter.format(entry);
      expect(output, contains('bad='));
    });
  });

  group('MultiLogger', () {
    test('calls all loggers', () {
      int callCount = 0;
      final logger1 = TestLogger((_) => callCount++);
      final logger2 = TestLogger((_) => callCount++);
      final multiLogger = MultiLogger([logger1, logger2]);

      final entry = LogEntry(
        level: LogLevel.info,
        message: 'msg',
        caller: 'caller',
        timestamp: 'time',
      );

      multiLogger.log(entry);

      expect(callCount, 2);
    });
  });

  group('LogEntry', () {
    test('stores all fields correctly', () {
      final entry = LogEntry(
        level: LogLevel.error,
        message: 'error occurred',
        tag: 'tag',
        errObj: Exception('ex'),
        stackTrace: StackTrace.current,
        context: {'key': 'value'},
        caller: 'caller',
        timestamp: 'timestamp',
      );

      expect(entry.level, LogLevel.error);
      expect(entry.message, 'error occurred');
      expect(entry.tag, 'tag');
      expect(entry.errObj, isException);
      expect(entry.context, containsPair('key', 'value'));
      expect(entry.caller, 'caller');
      expect(entry.timestamp, 'timestamp');
    });
  });
}

// Helpers

typedef LogCallback = void Function(LogEntry entry);

class TestLogger implements ILogger {
  final LogCallback onLog;
  TestLogger(this.onLog);
  @override
  void log(LogEntry entry) => onLog(entry);
}

class TestDebugLogger implements IDebugLogger {
  bool breakpointCalled = false;
  @override
  void breakpoint() => breakpointCalled = true;
  @override
  void log(LogEntry entry) {}
}
