import '../constants/game_modes.dart';
enum GameStatus { idle, countdown, playing, finished, paused }

class GridCell {
  /// Position in the tap sequence, always 1..N². Validation compares this, so
  /// one rule covers classic, reverse and letters — only what is drawn differs.
  final int number;

  /// What the cell shows. Defaults to [number] so classic and Gorbov are
  /// unchanged; reverse draws the descending value, letters draws a letter.
  final String? label;

  final int row;
  final int col;
  final String color; // 'white' | 'red'
  bool isFound;
  bool isError;

  GridCell({
    required this.number,
    required this.row,
    required this.col,
    this.label,
    this.color = 'white',
    this.isFound = false,
    this.isError = false,
  });

  String get display => label ?? '$number';
}

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
    this.mode = GameModes.classic,
    this.countdownValue,
    this.nextWhiteNumber = 1,
    this.nextRedNumber = 0,
    this.nextExpectedColor = 'white',
    this.whiteCount = 0,
    this.redCount = 0,
  });

  int get totalSeconds => elapsedSeconds + penaltySeconds;

  /// What the player must find next, as drawn on the grid: N² first in
  /// reverse, a letter in letters mode. Gorbov shows its own two-colour hint.
  String get expectedLabel {
    for (final row in grid) {
      for (final cell in row) {
        if (cell.number == nextNumber) return cell.display;
      }
    }
    return '$nextNumber';
  }
  int get totalNumbers => gridSize * gridSize;

  bool get isCompleted {
    if (mode == GameModes.gorbov) {
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
