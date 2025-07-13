# debug_utils - DebugUtils for Flutter 🐞


Lightweight, flexible logging utility for Flutter, engineered to make your debug logs clean, powerful, and context-rich without polluting production builds.

---

## 🚀 Features


- Logs **only** in debug mode ( zero overhead in release )
- Multiple log levels: `debug`, `info`, `warning`, `error`
- ISO 8601 timestamps for easy tracing
- Support for custom tags to organize logs by modules or features
- Integrates with `dart:developer` for IDE-friendly debugging
- Easily extendable with custom loggers and formatters


---

## 📦 Installation

Add the latest version to your `pubspec.yaml`:

```yaml
dependencies:
  debug_utils: ^<latest_version>
```

Then run:

```bash
flutter pub get
```

---

## ⚡ Quick Start

Initialize the logger early in your app, ideally in `main()`:

```dart
import 'package:debug_utils/debug_utils.dart';

void main() {
  AppLoggerPro.init(forceDebugMode: true);
  runApp(MyApp());
}
```

Use it anywhere to log messages with different severities:

```dart
AppLoggerPro.instance.info('User started checkout process');

AppLoggerPro.instance.debug('Cart contains 3 items');

AppLoggerPro.instance.error(
  'Failed to load user profile',
  tag: 'UserModule',
);
```

**Expected output in debug console:**

```
[2025-07-12T12:45:00.123Z][INFO] User started checkout process
[2025-07-12T12:45:01.456Z][DEBUG] Cart contains 3 items
[2025-07-12T12:45:02.789Z][ERROR][UserModule] Failed to load user profile
```

---

## 🎯 Why Choose debug_utils?

- **Zero noise in production:** Logs only appear in debug builds.
- **Structured & searchable:** ISO timestamps and tags make filtering simple.
- **Highly configurable:** Customize filters, formatters, and add your own loggers.
- **IDE integration:** Logs appear in DevTools and IDE consoles smoothly.
- **Lightweight:** Minimal dependencies, easy to integrate in any Flutter app.

---

## 🧰 Advanced Usage

You can provide a custom log filter to control which logs are emitted:

```dart
AppLoggerPro.init(
  forceDebugMode: true,
  logFilter: LogFilter(
    minLevel: LogLevel.warning,
    enabledTags: {'Network', 'Auth'},
  ),
);
```

Combine multiple loggers for advanced scenarios:

```dart
final multiLogger = MultiLogger([
  ConsoleLogger(),
  FileLogger(path: '/logs/app.log'), // hypothetical file logger
]);

AppLoggerPro.init(
  forceDebugMode: true,
  debugLogger: multiLogger,
);
```

---

## 🧪 Testing

The package includes comprehensive unit tests covering initialization, log filtering, formatting, and multi-logger behavior. Ensure you run:

```bash
flutter test
```

before publishing.

---

## 🧑‍💻 About the Author

Created by [Rafael Arango Pérez](https://www.linkedin.com/in/rapzadev/), a Flutter engineer specializing in clean architecture, scalable mobile solutions, and developer productivity tools.

Feel free to contribute or reach out on LinkedIn.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.