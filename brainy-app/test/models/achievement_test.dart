import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/models/achievement.dart';

void main() {
  group('AchievementDef', () {
    test('all achievements have unique idStrings', () {
      final ids = allAchievements.map((a) => a.idString).toList();
      expect(ids.toSet().length, ids.length, reason: 'Duplicate achievement IDs found');
    });

    test('all achievements have asset paths', () {
      for (final achievement in allAchievements) {
        expect(achievement.assetPath, isNotEmpty);
        expect(achievement.assetPath, startsWith('assets/badges/'));
        expect(achievement.assetPath, endsWith('.png'));
      }
    });

    test('there are 10 achievements', () {
      expect(allAchievements, hasLength(10));
    });

    test('idString returns snake_case', () {
      final firstGame = allAchievements.firstWhere((a) => a.id == AchievementId.firstGame);
      expect(firstGame.idString, 'first_game');

      final speedDemon = allAchievements.firstWhere((a) => a.id == AchievementId.speedDemon);
      expect(speedDemon.idString, 'speed_demon');

      final master5x5 = allAchievements.firstWhere((a) => a.id == AchievementId.master5x5);
      expect(master5x5.idString, 'master_5x5');
    });

    test('all AchievementId values are covered', () {
      final coveredIds = allAchievements.map((a) => a.id).toSet();
      for (final id in AchievementId.values) {
        expect(coveredIds, contains(id), reason: '$id not found in allAchievements');
      }
    });
  });
}
