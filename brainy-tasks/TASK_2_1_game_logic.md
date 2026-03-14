# Задание 2.1 — Логика таблицы Шульте

> **Используй вместе с MASTER_CONTEXT.md**
> Выполняется после задания 1.1 и 1.2.

---

## Цель

Реализовать полную игровую логику таблицы Шульте с использованием Riverpod. Никакого UI в этом задании — только модели данных, провайдеры и бизнес-логика. После выполнения логика должна быть покрыта и протестирована вручную через простой тестовый экран.

---

## Модели данных

### `lib/models/session.dart`

```dart
import 'package:hive/hive.dart';

part 'session.g.dart';

@HiveType(typeId: 0)
class GameSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime playedAt;

  @HiveField(2)
  final int gridSize; // 3, 4, 5, 6, 7, 9

  @HiveField(3)
  final int durationSeconds; // время прохождения

  @HiveField(4)
  final int mistakesCount;

  @HiveField(5)
  final bool isPersonalRecord;

  @HiveField(6)
  final String mode; // 'classic' | 'gorbov'

  @HiveField(7)
  final int coinsEarned;

  GameSession({
    required this.id,
    required this.playedAt,
    required this.gridSize,
    required this.durationSeconds,
    required this.mistakesCount,
    required this.isPersonalRecord,
    required this.mode,
    required this.coinsEarned,
  });

  int get xpEarned => gridSize * gridSize;

  // Оценка по звёздам (1–3)
  int get stars {
    final target = gridSize * gridSize; // целевое время в секундах
    if (durationSeconds <= target * 0.8) return 3;
    if (durationSeconds <= target * 1.2) return 2;
    return 1;
  }
}
```

### `lib/models/game_state.dart`

```dart
enum GameStatus { idle, countdown, playing, finished, paused }

class GridCell {
  final int number;
  final int row;
  final int col;
  bool isFound;
  bool isError;

  GridCell({
    required this.number,
    required this.row,
    required this.col,
    this.isFound = false,
    this.isError = false,
  });
}

class GameState {
  final GameStatus status;
  final int gridSize;
  final List<List<GridCell>> grid;
  final int nextNumber; // следующий который нужно найти
  final int elapsedSeconds;
  final int mistakesCount;
  final int penaltySeconds; // штраф за ошибки (2 сек * mistakes)
  final String mode;
  final int? countdownValue; // 3, 2, 1, null

  const GameState({
    this.status = GameStatus.idle,
    this.gridSize = 5,
    this.grid = const [],
    this.nextNumber = 1,
    this.elapsedSeconds = 0,
    this.mistakesCount = 0,
    this.penaltySeconds = 0,
    this.mode = 'classic',
    this.countdownValue,
  });

  int get totalSeconds => elapsedSeconds + penaltySeconds;
  int get totalNumbers => gridSize * gridSize;
  bool get isCompleted => nextNumber > totalNumbers;

  GameState copyWith({
    GameStatus? status,
    int? gridSize,
    List<List<GridCell>>? grid,
    int? nextNumber,
    int? elapsedSeconds,
    int? mistakesCount,
    int? penaltySeconds,
    String? mode,
    int? countdownValue,
  }) {
    return GameState(
      status: status ?? this.status,
      gridSize: gridSize ?? this.gridSize,
      grid: grid ?? this.grid,
      nextNumber: nextNumber ?? this.nextNumber,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      mistakesCount: mistakesCount ?? this.mistakesCount,
      penaltySeconds: penaltySeconds ?? this.penaltySeconds,
      mode: mode ?? this.mode,
      countdownValue: countdownValue,
    );
  }
}
```

---

## Провайдер игры

### `lib/features/game/providers/game_provider.dart`

```dart
import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/game_state.dart';
import '../../../models/session.dart';
import '../../../constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class GameNotifier extends Notifier<GameState> {
  Timer? _timer;
  Timer? _countdownTimer;
  final _random = Random();
  final _uuid = const Uuid();

  @override
  GameState build() => const GameState();

  // Инициализация новой игры
  void initGame({int gridSize = 5, String mode = 'classic'}) {
    _timer?.cancel();
    _countdownTimer?.cancel();

    final grid = _generateGrid(gridSize);

    state = GameState(
      status: GameStatus.countdown,
      gridSize: gridSize,
      grid: grid,
      nextNumber: 1,
      mode: mode,
      countdownValue: 3,
    );

    _startCountdown();
  }

  // Генерация перемешанной сетки
  List<List<GridCell>> _generateGrid(int size) {
    final numbers = List.generate(size * size, (i) => i + 1)..shuffle(_random);
    final grid = <List<GridCell>>[];

    for (int row = 0; row < size; row++) {
      final rowCells = <GridCell>[];
      for (int col = 0; col < size; col++) {
        rowCells.add(GridCell(
          number: numbers[row * size + col],
          row: row,
          col: col,
        ));
      }
      grid.add(rowCells);
    }
    return grid;
  }

  // Обратный отсчёт перед игрой
  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = state.countdownValue ?? 0;
      if (current <= 1) {
        timer.cancel();
        state = state.copyWith(
          status: GameStatus.playing,
          countdownValue: null,
        );
        _startTimer();
      } else {
        state = state.copyWith(countdownValue: current - 1);
      }
    });
  }

  // Таймер игры
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.status == GameStatus.playing) {
        state = state.copyWith(
          elapsedSeconds: state.elapsedSeconds + 1,
        );
      }
    });
  }

  // Обработка тапа по клетке
  void tapCell(int row, int col) {
    if (state.status != GameStatus.playing) return;

    final cell = state.grid[row][col];
    if (cell.isFound) return;

    if (cell.number == state.nextNumber) {
      // Правильный тап
      _handleCorrectTap(row, col);
    } else {
      // Неправильный тап
      _handleWrongTap(row, col);
    }
  }

  void _handleCorrectTap(int row, int col) {
    final newGrid = _copyGrid();
    newGrid[row][col].isFound = true;
    newGrid[row][col].isError = false;

    final newNextNumber = state.nextNumber + 1;
    final isCompleted = newNextNumber > state.totalNumbers;

    state = state.copyWith(
      grid: newGrid,
      nextNumber: newNextNumber,
      status: isCompleted ? GameStatus.finished : GameStatus.playing,
    );

    if (isCompleted) {
      _timer?.cancel();
    }
  }

  void _handleWrongTap(int row, int col) {
    final newGrid = _copyGrid();
    newGrid[row][col].isError = true;

    state = state.copyWith(
      grid: newGrid,
      mistakesCount: state.mistakesCount + 1,
      penaltySeconds: state.penaltySeconds + 2,
    );

    // Убираем подсветку ошибки через 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (state.status == GameStatus.playing) {
        final clearedGrid = _copyGrid();
        clearedGrid[row][col].isError = false;
        state = state.copyWith(grid: clearedGrid);
      }
    });
  }

  // Пауза / продолжение
  void togglePause() {
    if (state.status == GameStatus.playing) {
      _timer?.cancel();
      state = state.copyWith(status: GameStatus.paused);
    } else if (state.status == GameStatus.paused) {
      _startTimer();
      state = state.copyWith(status: GameStatus.playing);
    }
  }

  // Создание сессии по результатам игры
  GameSession buildSession({required bool isPersonalRecord}) {
    final coins = _calculateCoins(isPersonalRecord);
    return GameSession(
      id: _uuid.v4(),
      playedAt: DateTime.now(),
      gridSize: state.gridSize,
      durationSeconds: state.totalSeconds,
      mistakesCount: state.mistakesCount,
      isPersonalRecord: isPersonalRecord,
      mode: state.mode,
      coinsEarned: coins,
    );
  }

  int _calculateCoins(bool isPersonalRecord) {
    int coins = 10; // базовые
    if (isPersonalRecord) coins += 25;
    return coins;
  }

  // Сброс игры
  void resetGame() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    state = const GameState();
  }

  List<List<GridCell>> _copyGrid() {
    return state.grid
        .map((row) => row
            .map((cell) => GridCell(
                  number: cell.number,
                  row: cell.row,
                  col: cell.col,
                  isFound: cell.isFound,
                  isError: cell.isError,
                ))
            .toList())
        .toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(GameNotifier.new);
```

---

## Провайдер прогресса и рекордов

### `lib/features/game/providers/records_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/session.dart';

class RecordsNotifier extends Notifier<Map<int, int>> {
  static const String _boxName = 'records';
  // Map<gridSize, bestTimeSeconds>

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
```

---

## Провайдер сессий (история)

### `lib/features/game/providers/sessions_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/session.dart';

class SessionsNotifier extends Notifier<List<GameSession>> {
  static const String _boxName = 'sessions';

  @override
  List<GameSession> build() {
    final box = Hive.box<GameSession>(_boxName);
    return box.values.toList()
      ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
  }

  Future<void> saveSession(GameSession session) async {
    final box = Hive.box<GameSession>(_boxName);
    await box.put(session.id, session);
    state = [session, ...state];
  }

  List<GameSession> getSessionsForPeriod(DateTime from, DateTime to) {
    return state
        .where((s) => s.playedAt.isAfter(from) && s.playedAt.isBefore(to))
        .toList();
  }

  List<GameSession> getLast7Days() {
    final from = DateTime.now().subtract(const Duration(days: 7));
    return getSessionsForPeriod(from, DateTime.now());
  }
}

final sessionsProvider =
    NotifierProvider<SessionsNotifier, List<GameSession>>(SessionsNotifier.new);
```

---

## Константы

### `lib/constants/app_constants.dart`

```dart
class AppConstants {
  AppConstants._();

  // Размеры сеток
  static const List<int> freeGridSizes = [3, 4, 5];
  static const List<int> premiumGridSizes = [6, 7, 9];
  static const List<int> allGridSizes = [3, 4, 5, 6, 7, 9];

  // Целевое время для каждой сетки (секунды)
  static const Map<int, int> targetTimes = {
    3: 9,
    4: 16,
    5: 25,
    6: 36,
    7: 49,
    9: 81,
  };

  // Штраф за ошибку
  static const int mistakePenaltySeconds = 2;

  // Монеты
  static const int coinsPerSession = 10;
  static const int coinsForRecord = 25;
  static const int coinsForStreak7 = 50;
  static const int coinsForStreak30 = 200;

  // XP
  static const Map<int, int> xpThresholds = {
    1: 0,
    5: 500,
    10: 1500,
    20: 5000,
  };

  // Hive box names
  static const String sessionsBox = 'sessions';
  static const String recordsBox = 'records';
  static const String userBox = 'user';
  static const String characterBox = 'character';
}
```

---

## Hive инициализация

Обнови **`lib/main.dart`** — добавь инициализацию Hive перед `runApp`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(GameSessionAdapter());
  await Hive.openBox<GameSession>(AppConstants.sessionsBox);
  await Hive.openBox<int>(AppConstants.recordsBox);
  await Hive.openBox(AppConstants.userBox);
  await Hive.openBox(AppConstants.characterBox);
  runApp(const ProviderScope(child: BrainyApp()));
}
```

---

## Критерии готовности

- [ ] `flutter pub get` и `flutter pub run build_runner build` без ошибок
- [ ] `GameState` корректно отражает все состояния игры
- [ ] `GameNotifier.initGame(gridSize: 5)` создаёт сетку 5×5 с числами 1–25
- [ ] `tapCell` с правильным числом помечает клетку как найденную
- [ ] `tapCell` с неправильным числом добавляет штраф +2 сек
- [ ] После нахождения последнего числа статус меняется на `GameStatus.finished`
- [ ] `RecordsNotifier` сохраняет рекорд в Hive
- [ ] `SessionsNotifier` сохраняет историю сессий
