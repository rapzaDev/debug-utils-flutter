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

/// Timestamp provider type for injection/tests.
typedef TimestampProvider = String Function();

/// Default ISO 8601 timestamp provider.
String defaultTimestampProvider() => DateTime.now().toIso8601String();
