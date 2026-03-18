import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../models/game_state.dart';
import '../../../models/session.dart';
import '../../../shared/services/haptic_service.dart';
import '../../../shared/services/sound_service.dart';

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

class GameNotifier extends Notifier<GameState> {
  Timer? _timer;
  Timer? _countdownTimer;
  final _uuid = const Uuid();

  @override
  GameState build() => const GameState();

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

  void _handleCorrectTap(int row, int col) {
    HapticService.correctTap();
    SoundService.play(SoundEffect.tapCorrect);

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
    HapticService.wrongTap();
    SoundService.play(SoundEffect.tapWrong);

    final newGrid = _copyGrid();
    newGrid[row][col].isError = true;

    state = state.copyWith(
      grid: newGrid,
      mistakesCount: state.mistakesCount + 1,
      penaltySeconds: state.penaltySeconds + 2,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (state.status == GameStatus.playing) {
        final clearedGrid = _copyGrid();
        clearedGrid[row][col].isError = false;
        state = state.copyWith(grid: clearedGrid);
      }
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
    int coins = 10;
    if (isPersonalRecord) coins += 25;
    return coins;
  }

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
                  color: cell.color,
                  isFound: cell.isFound,
                  isError: cell.isError,
                ))
            .toList())
        .toList();
  }
}

final gameProvider =
    NotifierProvider<GameNotifier, GameState>(GameNotifier.new);
