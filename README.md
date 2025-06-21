# DebugUtils for Flutter 🐞

A lightweight and flexible debug utility to improve logging in Flutter app development.

With DebugUtils, it becomes easier to trace, categorize, and manage debug messages while ensuring they only run in debug mode. This keeps production builds clean and safe.

---

## What It Does

- Logs only when the app is running in debug mode  
- Offers multiple log levels: info, warning, error, debug  
- Includes ISO timestamps for better traceability  
- Supports custom tags to give context to logs  
- Integrates with `dart:developer` for IDE console visibility  
- Provides a service layer (`DebugLoggerService`) for easy injection and testing  

---

## Why Use It

Logging is essential during development. DebugUtils helps you:

- Track app behavior with consistent log formatting  
- Use severity levels and tags to quickly identify issues  
- Replace scattered `print()` statements with structured logs  
- Pause execution using breakpoints for deep debugging (`breakPoint: true`)  

---

## Quick Example

```dart
final logger = DebugLoggerService();

logger.log('User started checkout process', level: LogLevel.info);

logger.log('Cart contains 3 items', level: LogLevel.debug, tag: 'CartModule');

logger.log(
  'Failed to load user profile',
  level: LogLevel.error,
  breakPoint: true,
  tag: 'UserModule',
);
```

### Output in the debug console:

```
[2025-06-21T12:45:00.123Z][INFO] User started checkout process  
[2025-06-21T12:45:01.456Z][DEBUG] Cart contains 3 items  
[2025-06-21T12:45:02.789Z][ERROR] Failed to load user profile  
```

---

## How It Works

This utility uses Dart’s `assert(() { ... return true; }());` to ensure logs only execute in debug mode.

Each log entry includes:

- ISO 8601 timestamp  
- Log level in uppercase  
- Optional tag for categorization  
- Native integration with `dart:developer` for filtering in IDEs like VS Code or Android Studio  

If `breakPoint: true` is set, execution will pause using `debugger()` — useful for setting logical breakpoints in code.

---

## Project Structure

```
debug-utils-flutter/
├── lib/
│   └── example/
│       └── debug_utils.dart      # Core logging utility
│   └── main.dart                 # Example app
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
```

---

## How to Run

### Step 1: Clone the repository

```bash
git clone https://github.com/rafaelarango/debug-utils-flutter.git
cd debug-utils-flutter
```

### Step 2: Get dependencies

```bash
flutter pub get
```

### Step 3: Run the example app

```bash
flutter run
```

You’ll see the logs in your IDE’s debug console.  
**Note:** Logs only appear in debug mode.

---

## About the Author

Built by [Rafael Arango Pérez](https://www.linkedin.com/in/rapzadev/), Flutter developer focused on clean architecture, reusable code, and tools that boost productivity for mobile teams.

Fork, use, or contribute! If you're building powerful apps or hiring Flutter engineers, feel free to connect.

---

## License

MIT License. See the [LICENSE](LICENSE) file for details.
