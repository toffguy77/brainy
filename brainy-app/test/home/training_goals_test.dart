import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/constants/game_modes.dart';
import 'package:brainy/features/home/providers/training_goals_provider.dart';
import 'package:brainy/models/session.dart';

var _n = 0;
GameSession _s(String mode, int size, int seconds, {DateTime? at}) => GameSession(
      id: '${_n++}',
      playedAt: at ?? DateTime(2026, 10, 25, 10, _n % 60),
      gridSize: size,
      durationSeconds: seconds,
      mistakesCount: 0,
      isPersonalRecord: false,
      mode: mode,
      coinsEarned: 10,
    );

List<GameSession> _many(String mode, int size, int seconds,
        [int count = AppConstants.sessionsForAdaptive]) =>
    [for (var i = 0; i < count; i++) _s(mode, size, seconds)];

void main() {
  group('todayPlaySeconds', () {
    test('sums only sessions played today', () {
      final now = DateTime(2026, 10, 25, 20);
      final sessions = [
        _s(GameModes.classic, 3, 40, at: DateTime(2026, 10, 25, 8)),
        _s(GameModes.letters, 4, 50, at: DateTime(2026, 10, 25, 19)),
        _s(GameModes.classic, 5, 90, at: DateTime(2026, 10, 24, 23, 59)),
      ];
      expect(todayPlaySeconds(sessions, now), 90);
      expect(todayPlaySeconds(const [], now), 0);
    });
  });

  group('suggestNextGridSize', () {
    final classicTarget = AppConstants.adaptiveTargetSeconds(GameModes.classic, 4)!;

    test('needs a full window of games at the current size and mode', () {
      expect(
          suggestNextGridSize(
              mode: GameModes.classic,
              currentSize: 4,
              sessions: _many(GameModes.classic, 4, 1,
                  AppConstants.sessionsForAdaptive - 1)),
          isNull);
      // Fast games in another mode or size do not count.
      expect(
          suggestNextGridSize(
              mode: GameModes.classic,
              currentSize: 4,
              sessions: [
                ..._many(GameModes.reverse, 4, 1),
                ..._many(GameModes.classic, 3, 1),
              ]),
          isNull);
    });

    test('suggests the next size when the average meets the target', () {
      expect(
          suggestNextGridSize(
              mode: GameModes.classic,
              currentSize: 4,
              sessions: _many(GameModes.classic, 4, classicTarget)),
          5);
      expect(
          suggestNextGridSize(
              mode: GameModes.classic,
              currentSize: 4,
              sessions: _many(GameModes.classic, 4, classicTarget + 1)),
          isNull);
    });

    test('skips sizes the mode lacks and stops at its ceiling', () {
      final t7 = AppConstants.adaptiveTargetSeconds(GameModes.classic, 7)!;
      expect(
          suggestNextGridSize(
              mode: GameModes.classic,
              currentSize: 7,
              sessions: _many(GameModes.classic, 7, t7)),
          9);
      final t5 = AppConstants.adaptiveTargetSeconds(GameModes.letters, 5)!;
      expect(
          suggestNextGridSize(
              mode: GameModes.letters,
              currentSize: 5,
              sessions: _many(GameModes.letters, 5, t5)),
          isNull, reason: 'letters never goes past 5x5');
    });

    test('letters and Gorbov use looser targets than classic', () {
      final c = AppConstants.adaptiveTargetSeconds(GameModes.classic, 5)!;
      expect(AppConstants.adaptiveTargetSeconds(GameModes.letters, 5)!,
          greaterThan(c));
      expect(AppConstants.adaptiveTargetSeconds(GameModes.gorbov, 5)!,
          greaterThan(c));
    });

    test('only the most recent window counts', () {
      final old = [
        for (var i = 0; i < 5; i++)
          _s(GameModes.classic, 4, 999, at: DateTime(2026, 1, 1, 10, i)),
      ];
      final recent = [
        for (var i = 0; i < 5; i++)
          _s(GameModes.classic, 4, classicTarget, at: DateTime(2026, 10, 25, 10, i)),
      ];
      expect(
          suggestNextGridSize(
              mode: GameModes.classic, currentSize: 4, sessions: [...old, ...recent]),
          5);
    });
  });
}
