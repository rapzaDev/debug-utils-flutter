import 'package:debug_utils/example/debug_utils.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

/// Main app widget demonstrating usage of DebugLoggerService.
/// Logs messages with various levels and tags, including a breakpoint example.
/// View logs in IDE console or terminal during debug runs.
class MyApp extends StatelessWidget {
  final logger = DebugLoggerService();

  // Logs an error message and pauses execution in debug mode.
  late final void Function() logError = () => logger.log(
        'Failed to load user profile',
        breakPoint: true,
        level: LogLevel.error,
        tag: 'UserModule',
      );

  MyApp({super.key}) {
    logger.log(
      'User started checkout process',
      level: LogLevel.info,
    );

    logger.log(
      'Cart contains 3 items',
      level: LogLevel.debug,
      tag: 'CartModule',
    );

    logError();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyDebugger(),
    );
  }
}

class MyDebugger extends StatelessWidget {
  const MyDebugger({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Open your IDE console to see logs'),
      ),
    );
  }
}
