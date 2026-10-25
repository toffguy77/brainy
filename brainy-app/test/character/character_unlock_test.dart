import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/features/character/data/characters_data.dart';

CharacterInfo _byId(String id) =>
    defaultCharacters.firstWhere((c) => c.id == id);

void main() {
  group('character unlock conditions', () {
    test('no unlock type represents a purchase', () {
      // Stronger than asserting no character uses it: the variant is gone, so
      // a paid unlock cannot be reintroduced without a deliberate enum change.
      expect(UnlockType.values, [
        UnlockType.free,
        UnlockType.level,
        UnlockType.streak,
      ]);
    });

    test('Brainy is free from the start', () {
      expect(_byId('brainy').unlockType, UnlockType.free);
    });

    test('Pixel unlocks on a 14-day streak', () {
      final pixel = _byId('pixel');
      expect(pixel.unlockType, UnlockType.streak);
      expect(pixel.requiredStreak, 14);
    });

    test('streak thresholds are distinct so each character is a new goal', () {
      final streaks = defaultCharacters
          .where((c) => c.unlockType == UnlockType.streak)
          .map((c) => c.requiredStreak)
          .toList();
      expect(streaks.toSet().length, streaks.length,
          reason: 'two characters unlock at the same streak');
    });

    test('streak ladder is ordered pixel -> vortex -> glitch', () {
      expect(_byId('pixel').requiredStreak!,
          lessThan(_byId('vortex').requiredStreak!));
      expect(_byId('vortex').requiredStreak!,
          lessThan(_byId('glitch').requiredStreak!));
    });

    test('every unlock condition has the value its type needs', () {
      for (final info in defaultCharacters) {
        switch (info.unlockType) {
          case UnlockType.free:
            break;
          case UnlockType.level:
            expect(info.requiredLevel, isNotNull, reason: info.id);
            expect(info.requiredLevel, greaterThan(0), reason: info.id);
          case UnlockType.streak:
            expect(info.requiredStreak, isNotNull, reason: info.id);
            expect(info.requiredStreak, greaterThan(0), reason: info.id);
        }
      }
    });

    test('unlock conditions are described in both locales', () {
      for (final info in defaultCharacters) {
        expect(info.unlockConditionRu, isNotEmpty, reason: info.id);
        expect(info.unlockConditionEn, isNotEmpty, reason: info.id);
      }
    });
  });
}
