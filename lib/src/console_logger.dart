// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
//
// Description:
// This file contains the implementation of a console logger utility for Dart applications.
// It provides functions and classes to output debug and log messages to the console,
// helping developers track application behavior and diagnose issues during development.
//
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

import 'package:debug_utils/src/log_formatter.dart';
import 'package:debug_utils/src/logger_interfaces.dart';

class ConsoleLogger implements ILogger {
  final ILogFormatter _formatter;

  ConsoleLogger({ILogFormatter? formatter})
      : _formatter = formatter ?? DefaultLogFormatter();

  @override
  void log(LogEntry entry) {
    final formatted = _formatter.format(entry);
    // Use print ou debugPrint conforme preferir
    print(formatted);
  }
}
