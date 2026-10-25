import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/constants/game_modes.dart';
import 'package:brainy/features/game/providers/game_provider.dart';
import 'package:brainy/models/game_state.dart';

GameState _playing(String mode, int size) {
  final grid = switch (mode) {
    GameModes.reverse => generateReverseGrid(size),
    GameModes.letters => generateLettersGrid(size, 'en'),
    _ => generateClassicGrid(size),
  };
  return GameState(
    status: GameStatus.playing,
    gridSize: size,
    grid: grid,
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
  for (final mode in [GameModes.classic, GameModes.reverse, GameModes.letters]) {
    group('processOrdinalTap — $mode', () {
      test('a correct tap marks the cell found and advances', () {
        final s = _playing(mode, 3);
        final p = _find(s, 1);
        final r = processOrdinalTap(s, p.row, p.col);
        expect(r.isCorrect, isTrue);
        expect(r.newState.grid[p.row][p.col].isFound, isTrue);
        expect(r.newState.nextNumber, 2);
        expect(r.newState.status, GameStatus.playing);
      });

      test('a wrong tap penalises and does not advance', () {
        final s = _playing(mode, 3);
        final p = _find(s, 5);
        final r = processOrdinalTap(s, p.row, p.col);
        expect(r.isCorrect, isFalse);
        expect(r.newState.nextNumber, 1);
        expect(r.newState.mistakesCount, 1);
        expect(r.newState.penaltySeconds, AppConstants.mistakePenaltySeconds);
        expect(r.newState.grid[p.row][p.col].isError, isTrue);
        expect(r.newState.grid[p.row][p.col].isFound, isFalse);
      });

      test('tapping an already-found cell is ignored', () {
        var s = _playing(mode, 3);
        final p = _find(s, 1);
        s = processOrdinalTap(s, p.row, p.col).newState;
        final r = processOrdinalTap(s, p.row, p.col);
        expect(r.isAlreadyFound, isTrue);
        expect(identical(r.newState, s), isTrue);
      });

      test('the last ordinal finishes the game', () {
        var s = _playing(mode, 3);
        for (var n = 1; n <= 9; n++) {
          final p = _find(s, n);
          s = processOrdinalTap(s, p.row, p.col).newState;
          expect(s.status,
              n == 9 ? GameStatus.finished : GameStatus.playing);
        }
        expect(s.nextNumber, 10);
        expect(s.mistakesCount, 0);
      });
    });
  }

  group('expectedLabel — what the "find" badge shows', () {
    test('classic shows the next number', () {
      expect(_playing(GameModes.classic, 4).expectedLabel, '1');
    });

    test('reverse starts at N² and ends at 1', () {
      var s = _playing(GameModes.reverse, 4);
      expect(s.expectedLabel, '16');
      for (var n = 1; n < 16; n++) {
        final p = _find(s, n);
        s = processOrdinalTap(s, p.row, p.col).newState;
      }
      expect(s.expectedLabel, '1');
    });

    test('letters shows a letter, not a digit', () {
      var s = _playing(GameModes.letters, 3);
      expect(s.expectedLabel, 'A');
      final p = _find(s, 1);
      s = processOrdinalTap(s, p.row, p.col).newState;
      expect(s.expectedLabel, 'B');
    });
  });

  group('coins and session', () {
    test('coins come from the constants', () {
      expect(coinsForSession(isPersonalRecord: false),
          AppConstants.coinsPerSession);
      expect(coinsForSession(isPersonalRecord: true),
          AppConstants.coinsPerSession + AppConstants.coinsForRecord);
    });

    test('a session carries mode, size, total time with penalty and mistakes',
        () {
      final game = const GameState(
        gridSize: 4,
        mode: GameModes.reverse,
        elapsedSeconds: 20,
        penaltySeconds: 4,
        mistakesCount: 2,
      );
      final at = DateTime(2026, 10, 25, 18);
      final s = buildSessionFrom(game, isPersonalRecord: true, playedAt: at);
      expect(s.gridSize, 4);
      expect(s.mode, GameModes.reverse);
      expect(s.durationSeconds, 24);
      expect(s.mistakesCount, 2);
      expect(s.playedAt, at);
      expect(s.coinsEarned,
          AppConstants.coinsPerSession + AppConstants.coinsForRecord);
      expect(s.id, isNotEmpty);
    });
  });
}
