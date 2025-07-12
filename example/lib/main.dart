import 'package:debug_utils/debug_utils.dart';
import 'package:flutter/material.dart';

void main() {
  // Initialize the AppLoggerPro singleton
  AppLoggerPro.init(
    debugLogger: ConsoleLogger(), // Uses dev.log under the hood
    logFilter: LogFilter(
      minLevel: LogLevel.debug, // Minimum level that will be shown
      enabledTags: {'Debugging', 'CartModule'}, // Filtered tags (optional)
    ),
    enableCallerInfo: true, // Enables showing where the log was called
    attachGlobalErrorHandlers: true, // Captures Flutter and Platform errors
    forceDebugMode: true, // Force debug mode regardless of build mode
  );

  // You can now access the logger like this
  AppLoggerPro.instance.info('Logger initialized successfully');

  // Run your app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Log some messages during app startup
    AppLoggerPro.instance.debug(
      'Building MyApp widget',
      tag: 'AppStartup',
      context: {'userId': 123},
    );

    return MaterialApp(
      title: 'Logger Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logger Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Logs an informational message
                AppLoggerPro.instance.info(
                  'User tapped "Checkout"',
                  tag: 'CartModule',
                  context: {'cartItems': 3, 'total': 159.90},
                );
              },
              child: const Text('Simulate Checkout'),
            ),
            ElevatedButton(
              onPressed: () {
                // Logs an error with exception and stack trace
                try {
                  throw Exception('Simulated failure');
                } catch (e, st) {
                  AppLoggerPro.instance.error(
                    'Checkout failed',
                    tag: 'CartModule',
                    errObj: e,
                    stackTrace: st,
                  );
                }
              },
              child: const Text('Simulate Error'),
            ),
            ElevatedButton(
              onPressed: () {
                // Triggers a breakpoint if debugger is attached
                AppLoggerPro.instance.breakpoint();

                AppLoggerPro.instance.debug(
                  'Breakpoint triggered',
                  tag: 'Debugging',
                );
              },
              child: const Text('Trigger Breakpoint'),
            ),
          ],
        ),
      ),
    );
  }
}
