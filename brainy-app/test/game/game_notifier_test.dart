import 'dart:io';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/constants/game_modes.dart';
import 'package:brainy/features/game/providers/game_provider.dart';
import 'package:brainy/models/game_state.dart';

({int row, int col}) _find(GameState s, int ordinal) {
  for (var r = 0; r < s.gridSize; r++) {
    for (var c = 0; c < s.gridSize; c++) {
      if (s.grid[r][c].number == ordinal) return (row: r, col: c);
    }
  }
  throw StateError('ordinal $ordinal not on the grid');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hive_game_');
    Hive.init(dir.path);
    final box = await Hive.openBox(AppConstants.userBox);
    // Sound and haptics reach platform channels; tests check the rules only.
    await box.put(AppConstants.soundEnabledKey, false);
    await box.put(AppConstants.hapticEnabledKey, false);
  });

  tearDownAll(() => Hive.close());

  test('countdown runs 3 seconds, then the timer counts', () {
    fakeAsync((async) {
      final container = ProviderContainer();
      final game = container.read(gameProvider.notifier);
      game.initGame(gridSize: 3, mode: GameModes.classic);

      expect(container.read(gameProvider).status, GameStatus.countdown);
      async.elapse(const Duration(seconds: 3));
      expect(container.read(gameProvider).status, GameStatus.playing);
      expect(container.read(gameProvider).countdownValue, isNull);

      async.elapse(const Duration(seconds: 10));
      expect(container.read(gameProvider).elapsedSeconds, 10);

      container.dispose();
    });
  });

  test('pause stops the clock and resume restarts it', () {
    fakeAsync((async) {
      final container = ProviderContainer();
      final game = container.read(gameProvider.notifier);
      game.initGame(gridSize: 3);
      async.elapse(const Duration(seconds: 5)); // 3 countdown + 2 play

      game.togglePause();
      async.elapse(const Duration(seconds: 10));
      expect(container.read(gameProvider).elapsedSeconds, 2);

      game.togglePause();
      async.elapse(const Duration(seconds: 3));
      expect(container.read(gameProvider).elapsedSeconds, 5);
      container.dispose();
    });
  });

  test('finishing stops the clock', () {
    fakeAsync((async) {
      final container = ProviderContainer();
      final game = container.read(gameProvider.notifier);
      game.initGame(gridSize: 3, mode: GameModes.reverse);
      async.elapse(const Duration(seconds: 4));

      for (var n = 1; n <= 9; n++) {
        final p = _find(container.read(gameProvider), n);
        game.tapCell(p.row, p.col);
      }
      final finished = container.read(gameProvider);
      expect(finished.status, GameStatus.finished);

      async.elapse(const Duration(seconds: 10));
      expect(container.read(gameProvider).elapsedSeconds,
          finished.elapsedSeconds);
      container.dispose();
    });
  });

  test('a wrong tap flashes the error, then clears it', () {
    fakeAsync((async) {
      final container = ProviderContainer();
      final game = container.read(gameProvider.notifier);
      game.initGame(gridSize: 3);
      async.elapse(const Duration(seconds: 3));

      final p = _find(container.read(gameProvider), 5);
      game.tapCell(p.row, p.col);
      var s = container.read(gameProvider);
      expect(s.grid[p.row][p.col].isError, isTrue);
      expect(s.penaltySeconds, AppConstants.mistakePenaltySeconds);
      expect(s.totalSeconds, s.elapsedSeconds + AppConstants.mistakePenaltySeconds);

      async.elapse(const Duration(milliseconds: 600));
      s = container.read(gameProvider);
      expect(s.grid[p.row][p.col].isError, isFalse);
      container.dispose();
    });
  });

  test('an unsupported size from the route is clamped to the mode', () {
    fakeAsync((async) {
      final container = ProviderContainer();
      final game = container.read(gameProvider.notifier);

      game.initGame(gridSize: 9, mode: GameModes.letters, locale: 'en');
      expect(container.read(gameProvider).gridSize, 5);

      game.initGame(gridSize: 3, mode: GameModes.gorbov);
      expect(container.read(gameProvider).gridSize, 5);
      container.dispose();
    });
  });

  test('disposing the container cancels running timers', () {
    fakeAsync((async) {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).initGame(gridSize: 3);
      async.elapse(const Duration(seconds: 1));
      container.dispose();
      // A live periodic timer would write to disposed state and throw here.
      async.elapse(const Duration(seconds: 10));
      expect(async.periodicTimerCount, 0);
    });
  });
}
