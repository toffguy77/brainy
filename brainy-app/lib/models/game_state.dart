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
  final int nextNumber;
  final int elapsedSeconds;
  final int mistakesCount;
  final int penaltySeconds;
  final String mode;
  final int? countdownValue;

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
