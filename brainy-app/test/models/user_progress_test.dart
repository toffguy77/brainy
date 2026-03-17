import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/models/user_progress.dart';

void main() {
  group('UserProgress', () {
    test('default values', () {
      final progress = UserProgress();
      expect(progress.coins, 0);
      expect(progress.xp, 0);
      expect(progress.level, 1);
      expect(progress.currentStreak, 0);
      expect(progress.longestStreak, 0);
      expect(progress.lastPlayedDate, isNull);
      expect(progress.childAge, '');
      expect(progress.goals, isEmpty);
      expect(progress.dailyGoalMinutes, 10);
      expect(progress.activeCharacterId, 'brainy');
      expect(progress.lastSelectedGridSize, 5);
      expect(progress.unlockedAccessories, isEmpty);
      expect(progress.unlockedAchievements, isEmpty);
    });

    test('custom values', () {
      final progress = UserProgress(
        coins: 100,
        xp: 500,
        level: 5,
        currentStreak: 7,
        longestStreak: 14,
        childAge: '10-12',
        goals: ['concentration', 'reading'],
        dailyGoalMinutes: 15,
        activeCharacterId: 'zap',
        lastSelectedGridSize: 4,
        unlockedAccessories: ['hat_crown'],
        unlockedAchievements: ['first_game', 'streak_3'],
      );
      expect(progress.coins, 100);
      expect(progress.xp, 500);
      expect(progress.level, 5);
      expect(progress.currentStreak, 7);
      expect(progress.longestStreak, 14);
      expect(progress.childAge, '10-12');
      expect(progress.goals, ['concentration', 'reading']);
      expect(progress.activeCharacterId, 'zap');
      expect(progress.unlockedAccessories, ['hat_crown']);
      expect(progress.unlockedAchievements, hasLength(2));
    });

    test('unlockedAccessories defaults to empty list when null', () {
      final progress = UserProgress(unlockedAccessories: null);
      expect(progress.unlockedAccessories, isA<List<String>>());
      expect(progress.unlockedAccessories, isEmpty);
    });

    test('unlockedAchievements defaults to empty list when null', () {
      final progress = UserProgress(unlockedAchievements: null);
      expect(progress.unlockedAchievements, isA<List<String>>());
      expect(progress.unlockedAchievements, isEmpty);
    });
  });
}
