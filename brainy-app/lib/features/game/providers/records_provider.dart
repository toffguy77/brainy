import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Build a storage key: "classic_5" or "gorbov_7"
String recordKey(String mode, int gridSize) => '${mode}_$gridSize';

/// Check if a key is in legacy format (just a number like "5")
bool isLegacyKey(String key) => int.tryParse(key) != null;

class RecordsNotifier extends Notifier<Map<String, int>> {
  static const String _boxName = 'records';

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
        box.put(recordKey('classic', size), value);
      }
      box.delete(key);
    }
  }

  Map<String, int> _loadRecords() {
    final box = Hive.box<int>(_boxName);
    final records = <String, int>{};
    for (final size in [3, 4, 5, 6, 7, 9]) {
      for (final mode in ['classic', 'gorbov']) {
        final key = recordKey(mode, size);
        final record = box.get(key);
        if (record != null) records[key] = record;
      }
    }
    return records;
  }

  bool isPersonalRecord(int gridSize, int seconds, {String mode = 'classic'}) {
    final key = recordKey(mode, gridSize);
    final current = state[key];
    return current == null || seconds < current;
  }

  Future<void> saveRecord(int gridSize, int seconds,
      {String mode = 'classic'}) async {
    if (!isPersonalRecord(gridSize, seconds, mode: mode)) return;
    final box = Hive.box<int>(_boxName);
    final k = recordKey(mode, gridSize);
    await box.put(k, seconds);
    state = Map<String, int>.from(state)..[k] = seconds;
  }

  int? getRecord(int gridSize, {String mode = 'classic'}) =>
      state[recordKey(mode, gridSize)];
}

final recordsProvider =
    NotifierProvider<RecordsNotifier, Map<String, int>>(RecordsNotifier.new);
