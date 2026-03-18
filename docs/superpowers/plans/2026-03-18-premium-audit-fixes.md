# Premium Audit Fixes — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix 4 premium offering issues: implement Gorbov-Schulte mode, add 9×9 to picker, fix paywall text, gate parent dashboard.

**Architecture:** Bottom-up — models & constants first, then game logic with tests, then UI. Each task produces a working commit. Localization strings added as needed per task.

**Tech Stack:** Flutter/Dart, Riverpod, Hive, go_router. Tests with flutter_test.

**Spec:** `docs/superpowers/specs/2026-03-18-premium-audit-fixes-design.md`

---

## Chunk 1: Models, Constants & Localization Foundation

### Task 1: Update AppConstants — add 9×9 to picker, add Gorbov grid sizes

**Files:**
- Modify: `brainy-app/lib/constants/app_constants.dart`
- Modify: `brainy-app/test/constants/app_constants_test.dart`

- [ ] **Step 1: Update the existing picker test to expect 9×9**

In `brainy-app/test/constants/app_constants_test.dart`, replace the test at line 20-23:

```dart
test('picker grid sizes include all playable sizes', () {
  expect(AppConstants.pickerGridSizes, [3, 4, 5, 6, 7, 9]);
  expect(AppConstants.pickerGridSizes, containsAll(AppConstants.allGridSizes));
});
```

Add a new test after it:

```dart
test('gorbov grid sizes are 5x5 and above', () {
  expect(AppConstants.gorbovGridSizes, [5, 6, 7, 9]);
  for (final size in AppConstants.gorbovGridSizes) {
    expect(size, greaterThanOrEqualTo(5));
  }
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd brainy-app && flutter test test/constants/app_constants_test.dart -v`
Expected: FAIL — pickerGridSizes mismatch + gorbovGridSizes not defined

- [ ] **Step 3: Update AppConstants**

In `brainy-app/lib/constants/app_constants.dart`:

Change `pickerGridSizes` (line 128):
```dart
// Grid sizes for home screen picker
static const List<int> pickerGridSizes = [3, 4, 5, 6, 7, 9];
```

Add after it:
```dart
// Grid sizes available in Gorbov-Schulte mode (5x5 and above)
static const List<int> gorbovGridSizes = [5, 6, 7, 9];
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd brainy-app && flutter test test/constants/app_constants_test.dart -v`
Expected: ALL PASS

- [ ] **Step 5: Commit**

```bash
cd brainy-app && git add lib/constants/app_constants.dart test/constants/app_constants_test.dart
git commit -m "feat: add 9×9 to picker grid sizes and define gorbov grid sizes"
```

---

### Task 2: Add Gorbov color to AppColors

**Files:**
- Modify: `brainy-app/lib/constants/app_colors.dart`

- [ ] **Step 1: Add gorbovRed color constant**

In `brainy-app/lib/constants/app_colors.dart`, add after `error` (line 10):

```dart
static const Color gorbovRed = Color(0xFFE17055);
```

- [ ] **Step 2: Commit**

```bash
cd brainy-app && git add lib/constants/app_colors.dart
git commit -m "feat: add gorbovRed color for Gorbov-Schulte mode"
```

---

### Task 3: Update GridCell model — add color field

**Files:**
- Modify: `brainy-app/lib/models/game_state.dart`

- [ ] **Step 1: Add `color` field to GridCell**

In `brainy-app/lib/models/game_state.dart`, update `GridCell` class (lines 3-16):

```dart
class GridCell {
  final int number;
  final int row;
  final int col;
  final String color; // 'white' | 'red'
  bool isFound;
  bool isError;

  GridCell({
    required this.number,
    required this.row,
    required this.col,
    this.color = 'white',
    this.isFound = false,
    this.isError = false,
  });
}
```

- [ ] **Step 2: Add gorbov tracking fields to GameState**

In `brainy-app/lib/models/game_state.dart`, update `GameState` (lines 19-68):

```dart
class GameState {
  final GameStatus status;
  final int gridSize;
  final List<List<GridCell>> grid;
  final int nextNumber;
  final int elapsedSeconds;
  final int mistakesCount;
  final int penaltySeconds;
  final String mode;
  final int? countdownValue;
  // Gorbov-Schulte fields
  final int nextWhiteNumber;
  final int nextRedNumber;
  final String nextExpectedColor; // 'white' | 'red'
  final int whiteCount;
  final int redCount;

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
    this.nextWhiteNumber = 1,
    this.nextRedNumber = 0,
    this.nextExpectedColor = 'white',
    this.whiteCount = 0,
    this.redCount = 0,
  });

  int get totalSeconds => elapsedSeconds + penaltySeconds;
  int get totalNumbers => gridSize * gridSize;

  bool get isCompleted {
    if (mode == 'gorbov') {
      return nextWhiteNumber > whiteCount && nextRedNumber < 1;
    }
    return nextNumber > totalNumbers;
  }

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
    int? nextWhiteNumber,
    int? nextRedNumber,
    String? nextExpectedColor,
    int? whiteCount,
    int? redCount,
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
      nextWhiteNumber: nextWhiteNumber ?? this.nextWhiteNumber,
      nextRedNumber: nextRedNumber ?? this.nextRedNumber,
      nextExpectedColor: nextExpectedColor ?? this.nextExpectedColor,
      whiteCount: whiteCount ?? this.whiteCount,
      redCount: redCount ?? this.redCount,
    );
  }
}
```

- [ ] **Step 3: Update _copyGrid in GameProvider to include color**

In `brainy-app/lib/features/game/providers/game_provider.dart`, update `_copyGrid` (lines 175-187):

```dart
List<List<GridCell>> _copyGrid() {
  return state.grid
      .map((row) => row
          .map((cell) => GridCell(
                number: cell.number,
                row: cell.row,
                col: cell.col,
                color: cell.color,
                isFound: cell.isFound,
                isError: cell.isError,
              ))
          .toList())
      .toList();
}
```

- [ ] **Step 4: Verify build compiles**

Run: `cd brainy-app && flutter analyze --no-fatal-infos`
Expected: No errors (warnings OK)

- [ ] **Step 5: Commit**

```bash
cd brainy-app && git add lib/models/game_state.dart lib/features/game/providers/game_provider.dart
git commit -m "feat: add color field to GridCell and gorbov tracking to GameState"
```

---

### Task 4: Add all new localization strings

**Files:**
- Modify: `brainy-app/l10n/app_en.arb`
- Modify: `brainy-app/l10n/app_ru.arb`

- [ ] **Step 1: Update app_en.arb**

In `brainy-app/l10n/app_en.arb`:

Change `"paywallBenefit2"` value (line 195):
```json
"paywallBenefit2": "Exclusive character",
```

Change `"onboardingPaywallBenefit2"` value (line 62):
```json
"onboardingPaywallBenefit2": "Exclusive character",
```

Add before the closing `}`:
```json
"gameModeClassic": "Classic",
"gameModeGorbov": "Gorbov",
"gorbovHintWhite": "Find: white {number}",
"@gorbovHintWhite": {
  "placeholders": {
    "number": {"type": "int"}
  }
},
"gorbovHintRed": "Find: red {number}",
"@gorbovHintRed": {
  "placeholders": {
    "number": {"type": "int"}
  }
},
"gorbovModeBadge": "Gorbov-Schulte",
"parentPremiumGateTitle": "Parent Progress Panel",
"parentPremiumGateSubtitle": "Track your child's progress with detailed statistics",
"parentPremiumGateUnlock": "Unlock with Premium",
"parentPremiumGateSettings": "Settings"
```

- [ ] **Step 2: Update app_ru.arb**

In `brainy-app/l10n/app_ru.arb`:

Change `paywallBenefit2` to: `"Эксклюзивный персонаж"`
Change `onboardingPaywallBenefit2` to: `"Эксклюзивный персонаж"`

Add the same new keys with Russian values:
```json
"gameModeClassic": "Классика",
"gameModeGorbov": "Горбов",
"gorbovHintWhite": "Найди: белую {number}",
"@gorbovHintWhite": {
  "placeholders": {
    "number": {"type": "int"}
  }
},
"gorbovHintRed": "Найди: красную {number}",
"@gorbovHintRed": {
  "placeholders": {
    "number": {"type": "int"}
  }
},
"gorbovModeBadge": "Горбов-Шульте",
"parentPremiumGateTitle": "Панель прогресса для родителей",
"parentPremiumGateSubtitle": "Следите за прогрессом ребёнка с подробной статистикой",
"parentPremiumGateUnlock": "Открыть с Premium",
"parentPremiumGateSettings": "Настройки"
```

- [ ] **Step 3: Regenerate localizations**

Run: `cd brainy-app && flutter gen-l10n`
Expected: Files regenerated without errors

- [ ] **Step 4: Verify build compiles**

Run: `cd brainy-app && flutter analyze --no-fatal-infos`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
cd brainy-app && git add l10n/ lib/l10n/
git commit -m "feat: add gorbov and parent gate localization strings, fix paywall character text"
```

---

## Chunk 2: Gorbov Game Logic (TDD)

### Task 5: Gorbov grid generation — tests first

**Files:**
- Create: `brainy-app/test/game/gorbov_grid_generation_test.dart`
- Modify: `brainy-app/lib/features/game/providers/game_provider.dart`

- [ ] **Step 1: Write failing tests for grid generation**

Create `brainy-app/test/game/gorbov_grid_generation_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/features/game/providers/game_provider.dart';
import 'package:brainy/models/game_state.dart';

void main() {
  late GameNotifier notifier;

  setUp(() {
    // Create a testable notifier — we'll test the grid generation logic directly
  });

  group('Gorbov grid generation', () {
    test('5x5 grid has 13 white and 12 red cells', () {
      final grid = generateGorbovGrid(5);
      final allCells = grid.expand((row) => row).toList();
      final whites = allCells.where((c) => c.color == 'white');
      final reds = allCells.where((c) => c.color == 'red');
      expect(whites.length, 13); // ceil(25/2)
      expect(reds.length, 12);  // floor(25/2)
    });

    test('7x7 grid has 25 white and 24 red cells', () {
      final grid = generateGorbovGrid(7);
      final allCells = grid.expand((row) => row).toList();
      final whites = allCells.where((c) => c.color == 'white');
      final reds = allCells.where((c) => c.color == 'red');
      expect(whites.length, 25);
      expect(reds.length, 24);
    });

    test('9x9 grid has 41 white and 40 red cells', () {
      final grid = generateGorbovGrid(9);
      final allCells = grid.expand((row) => row).toList();
      final whites = allCells.where((c) => c.color == 'white');
      final reds = allCells.where((c) => c.color == 'red');
      expect(whites.length, 41);
      expect(reds.length, 40);
    });

    test('white numbers are 1..whiteCount', () {
      final grid = generateGorbovGrid(5);
      final whites = grid.expand((r) => r).where((c) => c.color == 'white').toList();
      final numbers = whites.map((c) => c.number).toList()..sort();
      expect(numbers, List.generate(13, (i) => i + 1));
    });

    test('red numbers are 1..redCount', () {
      final grid = generateGorbovGrid(5);
      final reds = grid.expand((r) => r).where((c) => c.color == 'red').toList();
      final numbers = reds.map((c) => c.number).toList()..sort();
      expect(numbers, List.generate(12, (i) => i + 1));
    });

    test('all cells have valid row and col', () {
      final grid = generateGorbovGrid(5);
      for (int r = 0; r < 5; r++) {
        for (int c = 0; c < 5; c++) {
          expect(grid[r][c].row, r);
          expect(grid[r][c].col, c);
        }
      }
    });

    test('no duplicate positions', () {
      final grid = generateGorbovGrid(7);
      final positions = <String>{};
      for (final row in grid) {
        for (final cell in row) {
          final key = '${cell.row},${cell.col}';
          expect(positions.contains(key), isFalse, reason: 'Duplicate position $key');
          positions.add(key);
        }
      }
      expect(positions.length, 49);
    });

    test('classic grid cells all have white color', () {
      final grid = generateClassicGrid(5);
      for (final row in grid) {
        for (final cell in row) {
          expect(cell.color, 'white');
        }
      }
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd brainy-app && flutter test test/game/gorbov_grid_generation_test.dart -v`
Expected: FAIL — `generateGorbovGrid` not found

- [ ] **Step 3: Extract grid generation as top-level testable functions**

In `brainy-app/lib/features/game/providers/game_provider.dart`, add these top-level functions before the `GameNotifier` class (after imports):

```dart
import 'dart:math';

final _random = Random();

/// Generate a classic Schulte grid (all white numbers 1..size²)
List<List<GridCell>> generateClassicGrid(int size) {
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

/// Generate a Gorbov-Schulte grid (white + red numbers)
List<List<GridCell>> generateGorbovGrid(int size) {
  final total = size * size;
  final whiteCount = (total + 1) ~/ 2; // ceil(total/2)
  final redCount = total ~/ 2;          // floor(total/2)

  final whites = List.generate(whiteCount, (i) => GridCell(
    number: i + 1,
    row: 0, col: 0,
    color: 'white',
  ));
  final reds = List.generate(redCount, (i) => GridCell(
    number: i + 1,
    row: 0, col: 0,
    color: 'red',
  ));

  final allCells = [...whites, ...reds]..shuffle(_random);

  final grid = <List<GridCell>>[];
  for (int row = 0; row < size; row++) {
    final rowCells = <GridCell>[];
    for (int col = 0; col < size; col++) {
      final idx = row * size + col;
      final cell = allCells[idx];
      rowCells.add(GridCell(
        number: cell.number,
        row: row,
        col: col,
        color: cell.color,
      ));
    }
    grid.add(rowCells);
  }
  return grid;
}
```

Update the `_generateGrid` method in `GameNotifier` to call `generateClassicGrid`:
```dart
// Inside GameNotifier, replace _generateGrid with:
// (Remove the old _generateGrid method and update initGame)
void initGame({int gridSize = 5, String mode = 'classic'}) {
  _timer?.cancel();
  _countdownTimer?.cancel();

  final grid = mode == 'gorbov'
      ? generateGorbovGrid(gridSize)
      : generateClassicGrid(gridSize);

  final whiteCount = (gridSize * gridSize + 1) ~/ 2;
  final redCount = gridSize * gridSize ~/ 2;

  state = GameState(
    status: GameStatus.countdown,
    gridSize: gridSize,
    grid: grid,
    nextNumber: 1,
    mode: mode,
    countdownValue: 3,
    nextWhiteNumber: 1,
    nextRedNumber: redCount,
    nextExpectedColor: 'white',
    whiteCount: whiteCount,
    redCount: redCount,
  );

  _startCountdown();
}
```

Remove the old `_generateGrid` method and the instance `_random` field (now using top-level).

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd brainy-app && flutter test test/game/gorbov_grid_generation_test.dart -v`
Expected: ALL PASS

- [ ] **Step 5: Verify existing tests still pass**

Run: `cd brainy-app && flutter test`
Expected: ALL PASS

- [ ] **Step 6: Commit**

```bash
cd brainy-app && git add lib/features/game/providers/game_provider.dart test/game/gorbov_grid_generation_test.dart
git commit -m "feat: implement gorbov grid generation with tests"
```

---

### Task 6: Gorbov tap logic — tests first

**Files:**
- Create: `brainy-app/test/game/gorbov_tap_logic_test.dart`
- Modify: `brainy-app/lib/features/game/providers/game_provider.dart`

- [ ] **Step 1: Write failing tests for gorbov tap logic**

Create `brainy-app/test/game/gorbov_tap_logic_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/models/game_state.dart';
import 'package:brainy/features/game/providers/game_provider.dart';

/// Helper: build a deterministic 3x3 gorbov-like state for testing tap logic.
/// 3x3 = 9 cells: 5 white (1-5) + 4 red (1-4)
/// Grid layout (for predictable testing):
/// [W1, R4, W2]
/// [R3, W3, R2]
/// [W4, R1, W5]
GameState _buildTestGorbovState() {
  final grid = [
    [
      GridCell(number: 1, row: 0, col: 0, color: 'white'),
      GridCell(number: 4, row: 0, col: 1, color: 'red'),
      GridCell(number: 2, row: 0, col: 2, color: 'white'),
    ],
    [
      GridCell(number: 3, row: 1, col: 0, color: 'red'),
      GridCell(number: 3, row: 1, col: 1, color: 'white'),
      GridCell(number: 2, row: 1, col: 2, color: 'red'),
    ],
    [
      GridCell(number: 4, row: 2, col: 0, color: 'white'),
      GridCell(number: 1, row: 2, col: 1, color: 'red'),
      GridCell(number: 5, row: 2, col: 2, color: 'white'),
    ],
  ];

  return GameState(
    status: GameStatus.playing,
    gridSize: 3,
    grid: grid,
    mode: 'gorbov',
    nextWhiteNumber: 1,
    nextRedNumber: 4,
    nextExpectedColor: 'white',
    whiteCount: 5,
    redCount: 4,
  );
}

void main() {
  group('Gorbov tap logic', () {
    test('correct white tap advances white counter and switches to red', () {
      final state = _buildTestGorbovState();
      // Tap W1 at (0,0) — correct first white
      final result = processGorbovTap(state, 0, 0);
      expect(result.isCorrect, isTrue);
      expect(result.newState.nextWhiteNumber, 2);
      expect(result.newState.nextExpectedColor, 'red');
      expect(result.newState.grid[0][0].isFound, isTrue);
    });

    test('correct sequence: W1 -> R4 -> W2 -> R3', () {
      var state = _buildTestGorbovState();

      // W1 at (0,0)
      var result = processGorbovTap(state, 0, 0);
      expect(result.isCorrect, isTrue);
      state = result.newState;

      // R4 at (0,1)
      result = processGorbovTap(state, 0, 1);
      expect(result.isCorrect, isTrue);
      expect(state.nextExpectedColor, 'red');
      state = result.newState;
      expect(state.nextRedNumber, 3);
      expect(state.nextExpectedColor, 'white');

      // W2 at (0,2)
      result = processGorbovTap(state, 0, 2);
      expect(result.isCorrect, isTrue);
      state = result.newState;

      // R3 at (1,0)
      result = processGorbovTap(state, 1, 0);
      expect(result.isCorrect, isTrue);
      state = result.newState;
      expect(state.nextRedNumber, 2);
    });

    test('wrong color tap is an error', () {
      final state = _buildTestGorbovState();
      // Expecting white, tap R4 at (0,1)
      final result = processGorbovTap(state, 0, 1);
      expect(result.isCorrect, isFalse);
      expect(result.newState.mistakesCount, 1);
    });

    test('right color wrong number is an error', () {
      final state = _buildTestGorbovState();
      // Expecting white 1, tap W2 at (0,2)
      final result = processGorbovTap(state, 0, 2);
      expect(result.isCorrect, isFalse);
      expect(result.newState.mistakesCount, 1);
    });

    test('tapping already found cell does nothing', () {
      var state = _buildTestGorbovState();
      // Find W1
      state = processGorbovTap(state, 0, 0).newState;
      // Tap W1 again
      final result = processGorbovTap(state, 0, 0);
      expect(result.isCorrect, isFalse);
      expect(result.isAlreadyFound, isTrue);
      expect(result.newState.mistakesCount, state.mistakesCount); // no penalty
    });

    test('game completes when all cells found', () {
      var state = _buildTestGorbovState();
      // Full sequence: W1 R4 W2 R3 W3 R2 W4 R1 W5
      final taps = [
        [0, 0], // W1
        [0, 1], // R4
        [0, 2], // W2
        [1, 0], // R3
        [1, 1], // W3
        [1, 2], // R2
        [2, 0], // W4
        [2, 1], // R1
        [2, 2], // W5
      ];
      for (final tap in taps) {
        final result = processGorbovTap(state, tap[0], tap[1]);
        expect(result.isCorrect, isTrue, reason: 'Tap at ${tap[0]},${tap[1]} should be correct');
        state = result.newState;
      }
      expect(state.isCompleted, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd brainy-app && flutter test test/game/gorbov_tap_logic_test.dart -v`
Expected: FAIL — `processGorbovTap` not found

- [ ] **Step 3: Implement processGorbovTap**

In `brainy-app/lib/features/game/providers/game_provider.dart`, add after `generateGorbovGrid`:

```dart
class GorbovTapResult {
  final bool isCorrect;
  final bool isAlreadyFound;
  final GameState newState;
  const GorbovTapResult({
    required this.isCorrect,
    this.isAlreadyFound = false,
    required this.newState,
  });
}

/// Pure function for testable gorbov tap logic.
GorbovTapResult processGorbovTap(GameState state, int row, int col) {
  final cell = state.grid[row][col];

  if (cell.isFound) {
    return GorbovTapResult(isCorrect: false, isAlreadyFound: true, newState: state);
  }

  final expectedColor = state.nextExpectedColor;
  final expectedNumber = expectedColor == 'white'
      ? state.nextWhiteNumber
      : state.nextRedNumber;

  if (cell.color != expectedColor || cell.number != expectedNumber) {
    // Wrong tap
    final newGrid = _copyGridStatic(state.grid);
    newGrid[row][col].isError = true;
    return GorbovTapResult(
      isCorrect: false,
      newState: state.copyWith(
        grid: newGrid,
        mistakesCount: state.mistakesCount + 1,
        penaltySeconds: state.penaltySeconds + 2,
      ),
    );
  }

  // Correct tap
  final newGrid = _copyGridStatic(state.grid);
  newGrid[row][col].isFound = true;
  newGrid[row][col].isError = false;

  final newWhite = expectedColor == 'white'
      ? state.nextWhiteNumber + 1
      : state.nextWhiteNumber;
  final newRed = expectedColor == 'red'
      ? state.nextRedNumber - 1
      : state.nextRedNumber;
  final newExpected = expectedColor == 'white' ? 'red' : 'white';

  var newState = state.copyWith(
    grid: newGrid,
    nextWhiteNumber: newWhite,
    nextRedNumber: newRed,
    nextExpectedColor: newExpected,
  );

  // Check completion
  if (newState.isCompleted) {
    newState = newState.copyWith(status: GameStatus.finished);
  }

  return GorbovTapResult(isCorrect: true, newState: newState);
}

/// Static grid copy for pure functions
List<List<GridCell>> _copyGridStatic(List<List<GridCell>> grid) {
  return grid
      .map((row) => row
          .map((cell) => GridCell(
                number: cell.number,
                row: cell.row,
                col: cell.col,
                color: cell.color,
                isFound: cell.isFound,
                isError: cell.isError,
              ))
          .toList())
      .toList();
}
```

Now update `tapCell` in `GameNotifier` to use gorbov logic:

```dart
void tapCell(int row, int col) {
  if (state.status != GameStatus.playing) return;

  final cell = state.grid[row][col];
  if (cell.isFound) return;

  if (state.mode == 'gorbov') {
    _handleGorbovTap(row, col);
  } else {
    if (cell.number == state.nextNumber) {
      _handleCorrectTap(row, col);
    } else {
      _handleWrongTap(row, col);
    }
  }
}

void _handleGorbovTap(int row, int col) {
  final result = processGorbovTap(state, row, col);

  if (result.isAlreadyFound) return;

  if (result.isCorrect) {
    HapticService.correctTap();
    SoundService.play(SoundEffect.tapCorrect);
    state = result.newState;
    if (state.status == GameStatus.finished) {
      _timer?.cancel();
    }
  } else {
    HapticService.wrongTap();
    SoundService.play(SoundEffect.tapWrong);
    state = result.newState;

    // Clear error after delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (state.status == GameStatus.playing) {
        final clearedGrid = _copyGrid();
        clearedGrid[row][col].isError = false;
        state = state.copyWith(grid: clearedGrid);
      }
    });
  }
}
```

- [ ] **Step 4: Run gorbov tap tests**

Run: `cd brainy-app && flutter test test/game/gorbov_tap_logic_test.dart -v`
Expected: ALL PASS

- [ ] **Step 5: Run all tests**

Run: `cd brainy-app && flutter test`
Expected: ALL PASS

- [ ] **Step 6: Commit**

```bash
cd brainy-app && git add lib/features/game/providers/game_provider.dart test/game/gorbov_tap_logic_test.dart
git commit -m "feat: implement gorbov tap logic with alternating white/red sequence"
```

---

### Task 7: Records migration — per-mode keys

**Files:**
- Create: `brainy-app/test/game/records_migration_test.dart`
- Modify: `brainy-app/lib/features/game/providers/records_provider.dart`

- [ ] **Step 1: Write migration tests**

Create `brainy-app/test/game/records_migration_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:brainy/features/game/providers/records_provider.dart';

void main() {
  group('Records key format', () {
    test('recordKey builds correct format', () {
      expect(recordKey('classic', 5), 'classic_5');
      expect(recordKey('gorbov', 7), 'gorbov_7');
    });

    test('isLegacyKey detects old-format keys', () {
      expect(isLegacyKey('5'), isTrue);
      expect(isLegacyKey('9'), isTrue);
      expect(isLegacyKey('classic_5'), isFalse);
      expect(isLegacyKey('gorbov_7'), isFalse);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd brainy-app && flutter test test/game/records_migration_test.dart -v`
Expected: FAIL — functions not found

- [ ] **Step 3: Implement per-mode records**

In `brainy-app/lib/features/game/providers/records_provider.dart`:

```dart
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
    final legacyKeys = box.keys.where((k) => isLegacyKey(k.toString())).toList();
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

  Future<void> saveRecord(int gridSize, int seconds, {String mode = 'classic'}) async {
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
```

- [ ] **Step 4: Update callers of recordsProvider**

The type changed from `Map<int, int>` to `Map<String, int>`. Update these files:

**`brainy-app/lib/features/game/screens/game_screen.dart`** — update `_handleGameFinished`:
```dart
final isRecord = records.isPersonalRecord(
  gameState.gridSize,
  gameState.totalSeconds,
  mode: gameState.mode,
);
// ...
if (isRecord) {
  records.saveRecord(gameState.gridSize, gameState.totalSeconds, mode: gameState.mode);
```

**`brainy-app/lib/features/parent/screens/parent_dashboard_screen.dart`** — update `_BestResultsCard`:
Replace `records[size]` with `ref` access using `getRecord(size, mode: 'classic')`.
Since this is a StatelessWidget that receives `records` as `Map<String, int>`, update it to look up `records[recordKey('classic', size)]`. Import `recordKey` from records_provider.

**`brainy-app/lib/features/progress/screens/progress_screen.dart`** — update `records[size]` (around line 735) to:
```dart
seconds: records[recordKey('classic', size)],
```
Import `recordKey` at the top:
```dart
import '../../game/providers/records_provider.dart' show recordKey, recordsProvider;
```
Note: The existing import `import '../../game/providers/records_provider.dart';` already exists — just ensure `recordKey` is accessible (it's a top-level function, so it will be).

- [ ] **Step 5: Run all tests**

Run: `cd brainy-app && flutter test`
Expected: ALL PASS

- [ ] **Step 6: Commit**

```bash
cd brainy-app && git add lib/features/game/providers/records_provider.dart test/game/records_migration_test.dart lib/features/game/screens/game_screen.dart lib/features/parent/screens/parent_dashboard_screen.dart
git commit -m "feat: migrate records to per-mode keys (classic_N / gorbov_N)"
```

---

## Chunk 3: UI Changes

### Task 8: Home screen — mode toggle + layout adjustments

**Files:**
- Modify: `brainy-app/lib/features/home/screens/home_screen.dart`

- [ ] **Step 1: Add mode state and toggle widget**

In `_HomeScreenState`, add state field:
```dart
String _selectedMode = 'classic';
```

Add the toggle builder method:
```dart
Widget _buildModeToggle(bool isPremium, AppLocalizations l10n) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 40),
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedMode = 'classic'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: _selectedMode == 'classic' ? AppColors.primaryGradient : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  l10n.gameModeClassic,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _selectedMode == 'classic'
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (!isPremium) {
                showPremiumBottomSheet(
                  context,
                  feature: l10n.gorbovModeBadge,
                  benefit: l10n.paywallBenefit5,
                );
                return;
              }
              setState(() => _selectedMode = 'gorbov');
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: _selectedMode == 'gorbov'
                    ? const LinearGradient(colors: [Color(0xFFE17055), Color(0xFFFDCB6E)])
                    : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Text(
                      l10n.gameModeGorbov,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _selectedMode == 'gorbov'
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (!isPremium)
                    Positioned(
                      top: -6,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.background,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 2: Update build method layout**

In the `build` method Column children, update:
- Change avatar container size from 200 to 160 (width and height)
- Change `Spacer(flex: 2)` to `Spacer(flex: 1)` (both instances)
- Add mode toggle between avatar section and grid picker:

```dart
const Spacer(flex: 1),
_buildModeToggle(isPremium, l10n),
const SizedBox(height: 16),
_buildGridSizePicker(l10n, isFixedMode, effectiveGridSize, isPremium),
```

- [ ] **Step 3: Update grid size picker to filter by mode**

Update `_buildGridSizePicker` to use mode-appropriate sizes:

```dart
final sizes = _selectedMode == 'gorbov'
    ? AppConstants.gorbovGridSizes
    : AppConstants.pickerGridSizes;
```

Replace `AppConstants.pickerGridSizes.map((size) {` with `sizes.map((size) {`.

Also adjust chip width from 56 to 50 if 6+ items:
```dart
child: _GridSizeChip(
  size: size,
  isSelected: isSelected,
  isLocked: isLocked,
  onTap: () => _onGridSizeTap(size, isLocked, l10n),
),
```

- [ ] **Step 4: Update play button to pass mode**

In `_buildPlayButton`, change the navigation:
```dart
context.go('/game?size=$effectiveGridSize&mode=$_selectedMode');
```

- [ ] **Step 5: Ensure gorbov mode resets grid selection when switching**

When switching to gorbov, if current grid size < 5, auto-select 5:
```dart
onTap: () {
  if (!isPremium) { /* show premium sheet */ return; }
  setState(() {
    _selectedMode = 'gorbov';
    if (_selectedGridSize < 5) _selectedGridSize = 5;
  });
},
```

- [ ] **Step 6: Verify build compiles and run app**

Run: `cd brainy-app && flutter analyze --no-fatal-infos`
Expected: No errors

- [ ] **Step 7: Commit**

```bash
cd brainy-app && git add lib/features/home/screens/home_screen.dart
git commit -m "feat: add mode toggle and layout adjustments to home screen"
```

---

### Task 9: Game screen — colored cells and gorbov hint

**Files:**
- Modify: `brainy-app/lib/features/game/widgets/schulte_grid.dart`
- Modify: `brainy-app/lib/features/game/widgets/game_header.dart`
- Modify: `brainy-app/lib/features/game/screens/game_screen.dart`

- [ ] **Step 1: Update GridCellWidget to show red color**

In `brainy-app/lib/features/game/widgets/schulte_grid.dart`, update `_textColor` getter:

```dart
Color get _textColor {
  if (widget.cell?.isFound == true) return AppColors.success;
  if (widget.cell?.isError == true) return AppColors.error;
  if (widget.cell?.color == 'red') return AppColors.gorbovRed;
  return AppColors.textPrimary;
}
```

Import `AppColors` is already there. Add import for gorbovRed if added to AppColors.

- [ ] **Step 2: Update GameHeader for gorbov mode hint**

In `brainy-app/lib/features/game/widgets/game_header.dart`, update `_NextNumberBadge` to handle gorbov mode. Change it to accept the full `GameState`:

```dart
class _NextNumberBadge extends StatelessWidget {
  final GameState gameState;
  const _NextNumberBadge({required this.gameState});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isGorbov = gameState.mode == 'gorbov';

    String hintText;
    int displayNumber;
    Color badgeColor;

    if (isGorbov) {
      if (gameState.nextExpectedColor == 'white') {
        hintText = l10n.gorbovHintWhite(gameState.nextWhiteNumber);
        displayNumber = gameState.nextWhiteNumber;
        badgeColor = AppColors.textPrimary;
      } else {
        hintText = l10n.gorbovHintRed(gameState.nextRedNumber);
        displayNumber = gameState.nextRedNumber;
        badgeColor = AppColors.gorbovRed;
      }
    } else {
      hintText = ''; // classic uses simple number
      displayNumber = gameState.nextNumber;
      badgeColor = Colors.white;
    }

    return Column(
      children: [
        if (isGorbov)
          Text(
            hintText,
            style: const TextStyle(
              fontFamily: 'Nunito',
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          )
        else
          const Text(
            'Найди',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: isGorbov && gameState.nextExpectedColor == 'red'
                ? const LinearGradient(colors: [Color(0xFFE17055), Color(0xFFFDCB6E)])
                : AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$displayNumber',
            style: TextStyle(
              color: badgeColor,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
```

Update the header `build` to pass gameState:
```dart
_NextNumberBadge(gameState: gameState),
```

Add imports for `AppLocalizations` and `AppColors.gorbovRed`.

- [ ] **Step 3: Update progress bar in game_screen for gorbov**

In `brainy-app/lib/features/game/screens/game_screen.dart`, update `_buildProgressBar`:

For gorbov mode, calculate found count differently:
```dart
final found = gameState.mode == 'gorbov'
    ? (gameState.nextWhiteNumber - 1) + (gameState.redCount - gameState.nextRedNumber)
    : gameState.nextNumber - 1;
```

- [ ] **Step 4: Verify build compiles**

Run: `cd brainy-app && flutter analyze --no-fatal-infos`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
cd brainy-app && git add lib/features/game/widgets/schulte_grid.dart lib/features/game/widgets/game_header.dart lib/features/game/screens/game_screen.dart
git commit -m "feat: colored cells and gorbov hint in game screen"
```

---

### Task 10: Parent dashboard — premium gate

**Files:**
- Modify: `brainy-app/lib/features/parent/screens/parent_dashboard_screen.dart`

- [ ] **Step 1: Add _PremiumGateScreen widget**

At the bottom of `parent_dashboard_screen.dart`, add:

```dart
class _PremiumGateScreen extends StatelessWidget {
  const _PremiumGateScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          l10n.parentTitle,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.textPrimary),
            onPressed: () => context.go('/parent/settings'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 36,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.parentPremiumGateTitle,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.parentPremiumGateSubtitle,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.go('/paywall'),
                      child: Center(
                        child: Text(
                          l10n.parentPremiumGateUnlock,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Gate the dashboard build method**

In `ParentDashboardScreen.build()`, add at the top after `isPremium`:

```dart
if (!isPremium) return const _PremiumGateScreen();
```

- [ ] **Step 3: Update _BestResultsCard for new records format**

**Critical:** Change `_BestResultsCard`'s field type from `Map<int, int>` to `Map<String, int>` (line 364):
```dart
// Before:
final Map<int, int> records;
// After:
final Map<String, int> records;
```

Import records_provider and update the records lookup to use the new key format:
```dart
import '../../game/providers/records_provider.dart' show recordKey;
```

In `_BestResultsCard`, change `records[size]` to `records[recordKey('classic', size)]`:
```dart
final record = records[recordKey('classic', size)];
```

Also update the constructor call site (around line 80) — `records` now comes from the provider as `Map<String, int>`, so the types will align automatically after the field change.

- [ ] **Step 4: Verify build compiles**

Run: `cd brainy-app && flutter analyze --no-fatal-infos`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
cd brainy-app && git add lib/features/parent/screens/parent_dashboard_screen.dart
git commit -m "feat: gate parent dashboard behind premium subscription"
```

---

### Task 11: Final integration test and cleanup

**Files:**
- All modified files

- [ ] **Step 1: Run full test suite**

Run: `cd brainy-app && flutter test`
Expected: ALL PASS

- [ ] **Step 2: Run analyzer**

Run: `cd brainy-app && flutter analyze --no-fatal-infos`
Expected: No errors

- [ ] **Step 3: Verify the app builds**

Run: `cd brainy-app && flutter build ios --no-codesign 2>&1 | tail -5`
Expected: Build succeeds

- [ ] **Step 4: Final commit if any cleanup needed**

```bash
git add -A && git status
# Only commit if there are changes
```
