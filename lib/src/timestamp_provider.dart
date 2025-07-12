// -----------------------------------------------------------------------------
// Author: Rafael Perez (@rapzaDev)
//
// Description:
// Provides a typedef and default implementation for generating ISO 8601 timestamps.
// Useful for injecting custom timestamp providers in tests or logging utilities.
//
// Repository: https://github.com/rapzaDev/debug-utils-flutter
// License: MIT
// -----------------------------------------------------------------------------

import 'package:debug_utils/src/logger_interfaces.dart';

class DefaultTimestampProvider implements ITimestampProvider {
  @override
  String get currentTimestamp => DateTime.now().toIso8601String();
}
