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
