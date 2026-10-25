import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/models/achievement.dart';

void main() {
  group('achievement catalogue', () {
    test('every AchievementId has a definition', () {
      final defined = allAchievements.map((a) => a.id).toSet();
      expect(defined, AchievementId.values.toSet());
    });

    test('there are no duplicate definitions', () {
      final ids = allAchievements.map((a) => a.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('persistence keys are unique', () {
      final keys = allAchievements.map((a) => a.idString).toList();
      expect(keys.toSet().length, keys.length);
    });

    test('persistence keys are snake_case and stable', () {
      // These strings are written into Hive, so renaming one silently orphans
      // every unlock a player already earned.
      for (final a in allAchievements) {
        expect(a.idString, matches(RegExp(r'^[a-z0-9]+(_[a-z0-9]+)*$')),
            reason: '${a.id} produced "${a.idString}"');
      }
    });

    test('known keys have not drifted', () {
      final keys = allAchievements.map((a) => a.idString).toSet();
      expect(
          keys,
          containsAll([
            'first_game',
            'personal_record',
            'speed_demon',
            'master_5x5',
            'focus_mode',
            'streak_3',
            'streak_7',
            'streak_30',
            'night_owl',
            'coin_hoarder',
          ]));
    });

    test('every achievement has a badge asset path', () {
      for (final a in allAchievements) {
        expect(a.assetPath, startsWith('assets/badges/'), reason: '${a.id}');
        expect(a.assetPath, endsWith('.png'), reason: '${a.id}');
      }
    });

    test('badge asset paths are unique', () {
      final paths = allAchievements.map((a) => a.assetPath).toList();
      expect(paths.toSet().length, paths.length);
    });

    test('asset filename matches the persistence key', () {
      for (final a in allAchievements) {
        expect(a.assetPath, 'assets/badges/${a.idString}.png',
            reason: '${a.id} asset and key disagree');
      }
    });

    test('the streak ladder is ordered', () {
      final keys = allAchievements.map((a) => a.idString).toList();
      expect(keys.indexOf('streak_3'), lessThan(keys.indexOf('streak_7')));
      expect(keys.indexOf('streak_7'), lessThan(keys.indexOf('streak_30')));
    });

    test('the catalogue is not empty', () {
      expect(allAchievements, isNotEmpty);
      expect(allAchievements.length, AchievementId.values.length);
    });
  });
}
