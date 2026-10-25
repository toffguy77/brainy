import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../constants/app_constants.dart';
import '../../../models/game_state.dart';
import '../../../models/session.dart';
import '../../../shared/services/haptic_service.dart';
import '../../../shared/services/sound_service.dart';
import '../../../constants/game_modes.dart';

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

/// Generate a reverse Schulte grid.
///
/// Cells carry their tap-sequence position in [GridCell.number] (1..size²) and
/// display the descending value, so the player taps size² first and 1 last
/// while validation reuses the classic ascending rule.
List<List<GridCell>> generateReverseGrid(int size) {
  final total = size * size;
  final order = List.generate(total, (i) => i + 1)..shuffle(_random);
  final grid = <List<GridCell>>[];
  for (int row = 0; row < size; row++) {
    final rowCells = <GridCell>[];
    for (int col = 0; col < size; col++) {
      final ordinal = order[row * size + col];
      rowCells.add(GridCell(
        number: ordinal,
        label: '${total - ordinal + 1}',
        row: row,
        col: col,
      ));
    }
    grid.add(rowCells);
  }
  return grid;
}

/// Generate a letters grid for [locale].
///
/// Uses a contiguous prefix of the alphabet so the target sequence is always
/// A, B, C… — a random sample would leave the player unable to know what comes
/// next without scanning the whole grid.
List<List<GridCell>> generateLettersGrid(int size, String locale) {
  final alphabet = AppConstants.alphabetFor(locale);
  final total = size * size;
  if (total > alphabet.length) {
    throw ArgumentError(
      'Grid ${size}x$size needs $total letters, alphabet has ${alphabet.length}',
    );
  }
  final order = List.generate(total, (i) => i + 1)..shuffle(_random);
  final grid = <List<GridCell>>[];
  for (int row = 0; row < size; row++) {
    final rowCells = <GridCell>[];
    for (int col = 0; col < size; col++) {
      final ordinal = order[row * size + col];
      rowCells.add(GridCell(
        number: ordinal,
        label: alphabet[ordinal - 1],
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
        label: cell.label,
        row: row,
        col: col,
        color: cell.color,
      ));
    }
    grid.add(rowCells);
  }
  return grid;
}

/// Outcome of a tap: whether it was correct, ignored, and the state after it.
class TapResult {
  final bool isCorrect;
  final bool isAlreadyFound;
  final GameState newState;
  const TapResult({
    required this.isCorrect,
    this.isAlreadyFound = false,
    required this.newState,
  });
}

/// A wrong tap: mark the cell, count the mistake, add the time penalty.
/// The expected target does not advance.
GameState _applyWrongTap(GameState state, int row, int col) {
  final newGrid = _copyGridStatic(state.grid);
  newGrid[row][col].isError = true;
  return state.copyWith(
    grid: newGrid,
    mistakesCount: state.mistakesCount + 1,
    penaltySeconds: state.penaltySeconds + AppConstants.mistakePenaltySeconds,
  );
}

/// Pure tap logic for classic, reverse and letters. All three validate the
/// cell's ordinal ([GridCell.number]) against [GameState.nextNumber]; only
/// what is drawn differs.
TapResult processOrdinalTap(GameState state, int row, int col) {
  final cell = state.grid[row][col];

  if (cell.isFound) {
    return TapResult(isCorrect: false, isAlreadyFound: true, newState: state);
  }

  if (cell.number != state.nextNumber) {
    return TapResult(isCorrect: false, newState: _applyWrongTap(state, row, col));
  }

  final newGrid = _copyGridStatic(state.grid);
  newGrid[row][col].isFound = true;
  newGrid[row][col].isError = false;

  var newState = state.copyWith(grid: newGrid, nextNumber: state.nextNumber + 1);
  if (newState.isCompleted) {
    newState = newState.copyWith(status: GameStatus.finished);
  }
  return TapResult(isCorrect: true, newState: newState);
}

/// Pure function for testable gorbov tap logic.
TapResult processGorbovTap(GameState state, int row, int col) {
  final cell = state.grid[row][col];

  if (cell.isFound) {
    return TapResult(isCorrect: false, isAlreadyFound: true, newState: state);
  }

  final expectedColor = state.nextExpectedColor;
  final expectedNumber = expectedColor == 'white'
      ? state.nextWhiteNumber
      : state.nextRedNumber;

  if (cell.color != expectedColor || cell.number != expectedNumber) {
    return TapResult(isCorrect: false, newState: _applyWrongTap(state, row, col));
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

  return TapResult(isCorrect: true, newState: newState);
}

/// Static grid copy for pure functions
List<List<GridCell>> _copyGridStatic(List<List<GridCell>> grid) {
  return grid
      .map((row) => row
          .map((cell) => GridCell(
                number: cell.number,
                label: cell.label,
                row: cell.row,
                col: cell.col,
                color: cell.color,
                isFound: cell.isFound,
                isError: cell.isError,
              ))
          .toList())
      .toList();
}

const _uuid = Uuid();

/// Coins for one finished game: the per-session reward, plus a bonus for a
/// personal record.
int coinsForSession({required bool isPersonalRecord}) =>
    AppConstants.coinsPerSession +
    (isPersonalRecord ? AppConstants.coinsForRecord : 0);

/// The persisted record of a finished [game].
GameSession buildSessionFrom(
  GameState game, {
  required bool isPersonalRecord,
  DateTime? playedAt,
}) {
  return GameSession(
    id: _uuid.v4(),
    playedAt: playedAt ?? DateTime.now(),
    gridSize: game.gridSize,
    durationSeconds: game.totalSeconds,
    mistakesCount: game.mistakesCount,
    isPersonalRecord: isPersonalRecord,
    mode: game.mode,
    coinsEarned: coinsForSession(isPersonalRecord: isPersonalRecord),
  );
}

class GameNotifier extends Notifier<GameState> {
  Timer? _timer;
  Timer? _countdownTimer;
  bool _disposed = false;

  @override
  GameState build() {
    // Timers outlive the notifier otherwise and write to disposed state.
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
      _countdownTimer?.cancel();
    });
    return const GameState();
  }

  void initGame({
    int gridSize = 5,
    String mode = GameModes.classic,
    String locale = 'ru',
  }) {
    _timer?.cancel();
    _countdownTimer?.cancel();
    // Route parameters are untrusted: letters cannot exceed 5x5, Gorbov
    // starts at 5x5. Never build a grid the mode cannot support.
    gridSize = AppConstants.clampGridSizeForMode(mode, gridSize);

    final grid = switch (mode) {
      GameModes.gorbov => generateGorbovGrid(gridSize),
      GameModes.reverse => generateReverseGrid(gridSize),
      GameModes.letters => generateLettersGrid(gridSize, locale),
      _ => generateClassicGrid(gridSize),
    };

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

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = state.countdownValue ?? 0;
      if (current <= 1) {
        timer.cancel();
        state = state.copyWith(
          status: GameStatus.playing,
          countdownValue: null,
        );
        SoundService.play(SoundEffect.gameStart);
        _startTimer();
      } else {
        state = state.copyWith(countdownValue: current - 1);
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.status == GameStatus.playing) {
        state = state.copyWith(
          elapsedSeconds: state.elapsedSeconds + 1,
        );
      }
    });
  }

  void tapCell(int row, int col) {
    if (state.status != GameStatus.playing) return;

    final result = state.mode == GameModes.gorbov
        ? processGorbovTap(state, row, col)
        : processOrdinalTap(state, row, col);
    if (result.isAlreadyFound) return;

    state = result.newState;
    if (result.isCorrect) {
      HapticService.correctTap();
      SoundService.play(SoundEffect.tapCorrect);
      if (state.status == GameStatus.finished) _timer?.cancel();
    } else {
      HapticService.wrongTap();
      SoundService.play(SoundEffect.tapWrong);
      _clearErrorLater(row, col);
    }
  }

  /// Flash the error state on a wrongly tapped cell, then clear it.
  void _clearErrorLater(int row, int col) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_disposed || state.status != GameStatus.playing) return;
      final clearedGrid = _copyGridStatic(state.grid);
      clearedGrid[row][col].isError = false;
      state = state.copyWith(grid: clearedGrid);
    });
  }

  void togglePause() {
    if (state.status == GameStatus.playing) {
      _timer?.cancel();
      state = state.copyWith(status: GameStatus.paused);
    } else if (state.status == GameStatus.paused) {
      _startTimer();
      state = state.copyWith(status: GameStatus.playing);
    }
  }

  void resetGame() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    state = const GameState();
  }
}

final gameProvider =
    NotifierProvider<GameNotifier, GameState>(GameNotifier.new);
