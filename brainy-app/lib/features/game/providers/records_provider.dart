import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RecordsNotifier extends Notifier<Map<int, int>> {
  static const String _boxName = 'records';

  @override
  Map<int, int> build() {
    return _loadRecords();
  }

  Map<int, int> _loadRecords() {
    final box = Hive.box<int>(_boxName);
    final records = <int, int>{};
    for (final size in [3, 4, 5, 6, 7, 9]) {
      final record = box.get(size.toString());
      if (record != null) records[size] = record;
    }
    return records;
  }

  bool isPersonalRecord(int gridSize, int seconds) {
    final current = state[gridSize];
    return current == null || seconds < current;
  }

  Future<void> saveRecord(int gridSize, int seconds) async {
    if (!isPersonalRecord(gridSize, seconds)) return;
    final box = Hive.box<int>(_boxName);
    await box.put(gridSize.toString(), seconds);
    state = {...state, gridSize: seconds};
  }

  int? getRecord(int gridSize) => state[gridSize];
}

final recordsProvider =
    NotifierProvider<RecordsNotifier, Map<int, int>>(RecordsNotifier.new);
