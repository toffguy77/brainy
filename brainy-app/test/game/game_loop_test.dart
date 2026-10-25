import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/features/game/providers/game_provider.dart';
import 'package:brainy/models/game_state.dart';

/// Build a playing state directly, skipping the countdown timer so the tap
/// rules can be exercised without waiting on wall-clock time.
GameState _playing(String mode, int size, {String locale = 'en'}) {
  final grid = switch (mode) {
    'reverse' => generateReverseGrid(size),
    'letters' => generateLettersGrid(size, locale),
    _ => generateClassicGrid(size),
  };
  return GameState(
    status: GameStatus.playing,
    gridSize: size,
    grid: grid,
    nextNumber: 1,
    mode: mode,
  );
}

({int row, int col}) _find(GameState s, int ordinal) {
  for (var r = 0; r < s.gridSize; r++) {
    for (var c = 0; c < s.gridSize; c++) {
      if (s.grid[r][c].number == ordinal) return (row: r, col: c);
    }
  }
  throw StateError('ordinal $ordinal not on the grid');
}

void main() {
  group('grid generation invariants', () {
    for (final mode in ['classic', 'reverse']) {
      test('$mode: every ordinal appears exactly once', () {
        final s = _playing(mode, 5);
        final ordinals = <int>[];
        for (final row in s.grid) {
          ordinals.addAll(row.map((c) => c.number));
        }
        ordinals.sort();
        expect(ordinals, List.generate(25, (i) => i + 1));
      });

      test('$mode: grid is square and fully populated', () {
        final s = _playing(mode, 4);
        expect(s.grid.length, 4);
        for (final row in s.grid) {
          expect(row.length, 4);
        }
      });

      test('$mode: no cell starts found or in error', () {
        final s = _playing(mode, 4);
        for (final row in s.grid) {
          for (final cell in row) {
            expect(cell.isFound, isFalse);
            expect(cell.isError, isFalse);
          }
        }
      });

      test('$mode: row and col match the cell position', () {
        final s = _playing(mode, 5);
        for (var r = 0; r < 5; r++) {
          for (var c = 0; c < 5; c++) {
            expect(s.grid[r][c].row, r);
            expect(s.grid[r][c].col, c);
          }
        }
      });
    }
  });

  group('completion rule', () {
    test('classic completes when the sequence is exhausted', () {
      final s = _playing('classic', 3);
      expect(s.isCompleted, isFalse);
      expect(s.copyWith(nextNumber: 10).isCompleted, isTrue);
    });

    test('classic is not complete one tap early', () {
      final s = _playing('classic', 3).copyWith(nextNumber: 9);
      expect(s.isCompleted, isFalse);
    });

    test('reverse completes on the same ordinal rule', () {
      final s = _playing('reverse', 3);
      expect(s.copyWith(nextNumber: 10).isCompleted, isTrue);
    });

    test('letters completes on the same ordinal rule', () {
      final s = _playing('letters', 3);
      expect(s.copyWith(nextNumber: 10).isCompleted, isTrue);
    });

    test('totalNumbers is the cell count', () {
      expect(_playing('classic', 7).totalNumbers, 49);
    });
  });

  group('elapsed time accounting', () {
    test('a penalty adds to the total but not to elapsed', () {
      final s = _playing('classic', 4)
          .copyWith(elapsedSeconds: 30, penaltySeconds: 4);
      expect(s.elapsedSeconds, 30);
      expect(s.totalSeconds, 34);
    });

    test('with no mistakes the total equals elapsed', () {
      final s = _playing('classic', 4).copyWith(elapsedSeconds: 30);
      expect(s.totalSeconds, 30);
    });
  });

  group('gorbov tap logic', () {
    test('the expected white number is accepted', () {
      final grid = generateGorbovGrid(5);
      var s = GameState(
        status: GameStatus.playing,
        gridSize: 5,
        grid: grid,
        mode: 'gorbov',
        nextWhiteNumber: 1,
        nextRedNumber: 12,
        nextExpectedColor: 'white',
        whiteCount: 13,
        redCount: 12,
      );
      final pos = () {
        for (var r = 0; r < 5; r++) {
          for (var c = 0; c < 5; c++) {
            final cell = s.grid[r][c];
            if (cell.color == 'white' && cell.number == 1) {
              return (row: r, col: c);
            }
          }
        }
        throw StateError('white 1 missing');
      }();

      final result = processGorbovTap(s, pos.row, pos.col);

      expect(result.isCorrect, isTrue);
      expect(result.newState.nextWhiteNumber, 2);
      expect(result.newState.nextExpectedColor, 'red');
    });

    test('a wrong colour is a mistake even with the right number', () {
      final grid = generateGorbovGrid(5);
      final s = GameState(
        status: GameStatus.playing,
        gridSize: 5,
        grid: grid,
        mode: 'gorbov',
        nextWhiteNumber: 1,
        nextRedNumber: 12,
        nextExpectedColor: 'white',
        whiteCount: 13,
        redCount: 12,
      );
      final pos = () {
        for (var r = 0; r < 5; r++) {
          for (var c = 0; c < 5; c++) {
            final cell = s.grid[r][c];
            if (cell.color == 'red' && cell.number == 1) {
              return (row: r, col: c);
            }
          }
        }
        throw StateError('red 1 missing');
      }();

      final result = processGorbovTap(s, pos.row, pos.col);

      expect(result.isCorrect, isFalse);
      expect(result.newState.mistakesCount, 1);
      expect(result.newState.penaltySeconds,
          AppConstants.mistakePenaltySeconds);
    });

    test('tapping an already-found cell is ignored, not penalised', () {
      final grid = generateGorbovGrid(5);
      grid[0][0].isFound = true;
      final s = GameState(
        status: GameStatus.playing,
        gridSize: 5,
        grid: grid,
        mode: 'gorbov',
        whiteCount: 13,
        redCount: 12,
      );

      final result = processGorbovTap(s, 0, 0);

      expect(result.isAlreadyFound, isTrue);
      expect(result.newState.mistakesCount, 0);
    });

    test('white and red counts split the grid', () {
      const size = 5;
      final grid = generateGorbovGrid(size);
      var whites = 0, reds = 0;
      for (final row in grid) {
        for (final cell in row) {
          cell.color == 'white' ? whites++ : reds++;
        }
      }
      expect(whites + reds, size * size);
      expect(whites, (size * size + 1) ~/ 2);
      expect(reds, size * size ~/ 2);
    });
  });

  group('mode-agnostic tap ordinal', () {
    test('the first expected tap is ordinal 1 in every non-gorbov mode', () {
      for (final mode in ['classic', 'reverse', 'letters']) {
        final s = _playing(mode, 3);
        expect(s.nextNumber, 1, reason: mode);
        expect(() => _find(s, 1), returnsNormally, reason: mode);
      }
    });

    test('the penalty constant is what the rules charge', () {
      expect(AppConstants.mistakePenaltySeconds, 2);
    });
  });
}
