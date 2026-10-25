import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/constants/game_modes.dart';
import 'package:brainy/features/progress/providers/achievements_provider.dart';
import 'package:brainy/models/session.dart';
import 'package:brainy/models/user_progress.dart';

GameSession _session({
  int gridSize = 4,
  int seconds = 30,
  int mistakes = 1,
  bool record = false,
  int hour = 12,
  String mode = GameModes.classic,
}) =>
    GameSession(
      id: 'x',
      playedAt: DateTime(2026, 10, 25, hour),
      gridSize: gridSize,
      durationSeconds: seconds,
      mistakesCount: mistakes,
      isPersonalRecord: record,
      mode: mode,
      coinsEarned: 10,
    );

/// Ids [achievementsToUnlock] grants for one session, with a non-empty
/// session history unless [firstGame] is checked explicitly.
Set<String> _earned(GameSession s,
    {UserProgress? progress, List<GameSession>? sessions}) {
  return achievementsToUnlock(
    session: s,
    progress: progress ?? UserProgress(),
    sessions: sessions ?? [s],
  ).map((a) => a.idString).toSet();
}

void main() {
  test('first_game needs at least one saved session', () {
    expect(_earned(_session(), sessions: [_session()]), contains('first_game'));
    expect(_earned(_session(), sessions: []), isNot(contains('first_game')));
  });

  test('personal_record follows the session flag', () {
    expect(_earned(_session(record: true)), contains('personal_record'));
    expect(_earned(_session(record: false)), isNot(contains('personal_record')));
  });

  test('speed_demon: 3x3 in 5 seconds or less', () {
    expect(_earned(_session(gridSize: 3, seconds: 5)), contains('speed_demon'));
    expect(_earned(_session(gridSize: 3, seconds: 6)),
        isNot(contains('speed_demon')));
    expect(_earned(_session(gridSize: 4, seconds: 5)),
        isNot(contains('speed_demon')));
  });

  test('master_5x5: 5x5 in 20 seconds or less, any mode', () {
    expect(_earned(_session(gridSize: 5, seconds: 20)), contains('master_5x5'));
    expect(_earned(_session(gridSize: 5, seconds: 20, mode: GameModes.letters)),
        contains('master_5x5'));
    expect(_earned(_session(gridSize: 5, seconds: 21)),
        isNot(contains('master_5x5')));
    expect(_earned(_session(gridSize: 4, seconds: 20)),
        isNot(contains('master_5x5')));
  });

  test('focus_mode: no mistakes', () {
    expect(_earned(_session(mistakes: 0)), contains('focus_mode'));
    expect(_earned(_session(mistakes: 1)), isNot(contains('focus_mode')));
  });

  test('streak achievements unlock at 3, 7 and 30 days', () {
    Set<String> at(int streak) =>
        _earned(_session(), progress: UserProgress(currentStreak: streak));
    expect(at(2), isNot(contains('streak_3')));
    expect(at(3), contains('streak_3'));
    expect(at(6), isNot(contains('streak_7')));
    expect(at(7), containsAll(['streak_3', 'streak_7']));
    expect(at(29), isNot(contains('streak_30')));
    expect(at(30), containsAll(['streak_3', 'streak_7', 'streak_30']));
  });

  test('night_owl: a session started at 22:00 or later', () {
    expect(_earned(_session(hour: 22)), contains('night_owl'));
    expect(_earned(_session(hour: 23)), contains('night_owl'));
    expect(_earned(_session(hour: 21)), isNot(contains('night_owl')));
  });

  test('coin_hoarder: a balance of 500 coins', () {
    expect(_earned(_session(), progress: UserProgress(coins: 500)),
        contains('coin_hoarder'));
    expect(_earned(_session(), progress: UserProgress(coins: 499)),
        isNot(contains('coin_hoarder')));
  });

  test('an already unlocked achievement is never granted again', () {
    final progress = UserProgress(
      currentStreak: 30,
      coins: 900,
      unlockedAchievements: ['first_game', 'streak_30', 'coin_hoarder'],
    );
    final ids = _earned(_session(), progress: progress);
    expect(ids, isNot(contains('first_game')));
    expect(ids, isNot(contains('streak_30')));
    expect(ids, isNot(contains('coin_hoarder')));
    expect(ids, contains('streak_7'));
  });
}
