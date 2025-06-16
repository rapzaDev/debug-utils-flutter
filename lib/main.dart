import 'package:debug_utils/example/debug_utils.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    DebugUtils.debugLog('User started checkout process', level: LogLevel.info);

    DebugUtils.debugLog('Cart contains 3 items');

    DebugUtils.debugLog(
      'Failed to load user profile',
      level: LogLevel.error,
      tag: 'UserModule',
    );
  }

  // This widget is the root of your application.
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
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Open your IDE console to see logs')),
      ),
    );
  }
}
