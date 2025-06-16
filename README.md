# DebugUtils for Flutter 🐞

A lightweight and flexible debug utility created to improve logging in Flutter app development.

With DebugUtils, it becomes easier to trace, categorize, and manage debug messages while ensuring they only run in debug mode. This keeps production builds clean and safe.

---

## What It Does

- Logs only when the app is running in debug mode
- Offers multiple log levels: info, warning, error, debug
- Includes ISO timestamps for better traceability
- Supports custom tags to give context to logs
- Uses dart:developer to integrate with IDE logging tools

---

## Why Use It

Logging is essential when debugging features in mobile apps. This utility helps you:

- Track important events with clear severity levels
- Add tags to identify the source or module
- Avoid scattered print statements across the code
- Keep logs well-structured and easy to read

---

## Quick Example

```dart
DebugUtils.debugLog('User started checkout process', level: LogLevel.info);

DebugUtils.debugLog('Cart contains 3 items');

DebugUtils.debugLog(
  'Failed to load user profile',
  level: LogLevel.error,
  tag: 'UserModule',
);
```

### Expected output in the debug console:

```
[2025-06-16T12:45:00.123Z][INFO] User started checkout process
[2025-06-16T12:45:01.456Z][DEBUG] Cart contains 3 items
[2025-06-16T12:45:02.789Z][ERROR] Failed to load user profile
```

---

## How It Works

This utility uses Dart’s `assert(() { ... return true; }());` to ensure logs are only executed in debug mode. In release or profile mode, it remains silent.

Each log entry is constructed with:

- ISO 8601 timestamp
- Log level in uppercase
- Optional custom tag for context
- Native integration with dart:developer

---

## Project Structure

```
debug-utils-flutter/
├── lib/
│   └── debug_utils.dart
├── example/
│   └── main.dart
├── pubspec.yaml
├── .gitignore
└── README.md
```

---

## How to Run

To try it on your local machine:

### Step 1: Clone the repository

```bash
git clone https://github.com/rafaelarango/debug-utils-flutter.git
cd debug-utils
```

### Step 2: Get dependencies

```bash
flutter pub get
```

### Step 3: Run the example

```bash
flutter run
```

The app will start and print logs to your debug console. Open the IDE console or terminal to view them.

Logs are only printed when the app is running in debug mode. Nothing will appear in release builds.

---

## About the Author

Built by [Rafael Arango](https://www.linkedin.com/in/rafaelarango), Flutter developer focused on clean architecture, reusable code and productivity tools for modern app teams.

Feel free to fork or contribute. If you are hiring Flutter engineers or looking to build powerful mobile apps, let’s connect on LinkedIn.

---

## License

MIT License. See the LICENSE file for details.