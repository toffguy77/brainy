import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/models/league.dart';
import 'package:brainy/features/league/providers/league_provider.dart';

void main() {
  group('LeagueTier.fromWeeklyXp', () {
    test('0 XP returns bronze', () {
      expect(LeagueTier.fromWeeklyXp(0), LeagueTier.bronze);
    });

    test('149 XP returns bronze', () {
      expect(LeagueTier.fromWeeklyXp(149), LeagueTier.bronze);
    });

    test('150 XP returns silver', () {
      expect(LeagueTier.fromWeeklyXp(150), LeagueTier.silver);
    });

    test('399 XP returns silver', () {
      expect(LeagueTier.fromWeeklyXp(399), LeagueTier.silver);
    });

    test('400 XP returns gold', () {
      expect(LeagueTier.fromWeeklyXp(400), LeagueTier.gold);
    });

    test('799 XP returns gold', () {
      expect(LeagueTier.fromWeeklyXp(799), LeagueTier.gold);
    });

    test('800 XP returns platinum', () {
      expect(LeagueTier.fromWeeklyXp(800), LeagueTier.platinum);
    });

    test('9999 XP returns platinum', () {
      expect(LeagueTier.fromWeeklyXp(9999), LeagueTier.platinum);
    });
  });

  group('LeagueTier.nextTier', () {
    test('bronze -> silver', () {
      expect(LeagueTier.bronze.nextTier, LeagueTier.silver);
    });

    test('silver -> gold', () {
      expect(LeagueTier.silver.nextTier, LeagueTier.gold);
    });

    test('gold -> platinum', () {
      expect(LeagueTier.gold.nextTier, LeagueTier.platinum);
    });

    test('platinum -> null', () {
      expect(LeagueTier.platinum.nextTier, isNull);
    });
  });

  group('LeaguePlayer', () {
    test('creates with required fields', () {
      final player = LeaguePlayer(name: 'Test', weeklyXp: 100);
      expect(player.name, 'Test');
      expect(player.weeklyXp, 100);
      expect(player.isCurrentUser, false);
    });

    test('isCurrentUser can be true', () {
      final player = LeaguePlayer(
        name: 'Me',
        weeklyXp: 200,
        isCurrentUser: true,
      );
      expect(player.isCurrentUser, true);
    });
  });
}
