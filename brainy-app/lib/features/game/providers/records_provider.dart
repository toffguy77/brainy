import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/game_modes.dart';

/// Build a storage key: "classic_5", "reverse_9", "letters_4"…
String recordKey(String mode, int gridSize) => '${mode}_$gridSize';

/// Check if a key is in legacy format (just a number like "5")
bool isLegacyKey(String key) => int.tryParse(key) != null;

class RecordsNotifier extends Notifier<Map<String, int>> {
  static const String _boxName = AppConstants.recordsBox;

  @override
  Map<String, int> build() {
    _migrateIfNeeded();
    return _loadRecords();
  }

  void _migrateIfNeeded() {
    final box = Hive.box<int>(_boxName);
    final legacyKeys =
        box.keys.where((k) => isLegacyKey(k.toString())).toList();
    for (final key in legacyKeys) {
      final size = int.parse(key.toString());
      final value = box.get(key);
      if (value != null) {
        box.put(recordKey(GameModes.classic, size), value);
      }
      box.delete(key);
    }
  }

  /// Load every stored record. Reads all keys rather than a fixed list of
  /// modes and sizes, so a record written for any mode survives a restart.
  Map<String, int> _loadRecords() {
    final box = Hive.box<int>(_boxName);
    final records = <String, int>{};
    for (final key in box.keys) {
      final k = key.toString();
      if (isLegacyKey(k)) continue;
      final record = box.get(key);
      if (record != null) records[k] = record;
    }
    return records;
  }

  bool isPersonalRecord(int gridSize, int seconds, {String mode = GameModes.classic}) {
    final key = recordKey(mode, gridSize);
    final current = state[key];
    return current == null || seconds < current;
  }

  Future<void> saveRecord(int gridSize, int seconds,
      {String mode = GameModes.classic}) async {
    if (!isPersonalRecord(gridSize, seconds, mode: mode)) return;
    final box = Hive.box<int>(_boxName);
    final k = recordKey(mode, gridSize);
    await box.put(k, seconds);
    state = Map<String, int>.from(state)..[k] = seconds;
  }

  int? getRecord(int gridSize, {String mode = GameModes.classic}) =>
      state[recordKey(mode, gridSize)];
}

final recordsProvider =
    NotifierProvider<RecordsNotifier, Map<String, int>>(RecordsNotifier.new);
