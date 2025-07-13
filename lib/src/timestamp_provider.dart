// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
// Description: Provides a typedef and default implementation for generating
// ISO 8601 timestamps. Useful for injecting custom timestamp providers in
// tests or logging utilities.
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

import 'package:debug_utils/src/logger_interfaces.dart';

/// Default timestamp provider generating timestamps in ISO 8601 format.
///
/// Implements [ITimestampProvider] and is designed to be simple and thread-safe,
/// using the system’s current time.
class DefaultTimestampProvider implements ITimestampProvider {
  @override

  /// Returns the current timestamp in ISO 8601 format (e.g., 2025-07-13T14:03:00Z).
  ///
  /// The precision depends on the implementation of [DateTime.now()].
  String get currentTimestamp => DateTime.now().toIso8601String();
}
