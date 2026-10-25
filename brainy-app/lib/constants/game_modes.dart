/// Game mode identifiers. Persisted in sessions and record keys
/// (`{mode}_{size}`), so the values must never change.
class GameModes {
  GameModes._();

  static const String classic = 'classic';
  static const String reverse = 'reverse';
  static const String gorbov = 'gorbov';
  static const String letters = 'letters';

  /// Display and iteration order.
  static const List<String> all = [classic, reverse, gorbov, letters];
}
