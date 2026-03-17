import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/shared/services/game_services_service.dart';

void main() {
  group('Score submission logic', () {
    test('submitWeeklyXp does nothing when not signed in', () async {
      final service = GameServicesService();
      expect(service.isSignedIn, false);
      await service.submitWeeklyXp(100); // Should silently return
    });

    test('submitBestTime does nothing when not signed in', () async {
      final service = GameServicesService();
      expect(service.isSignedIn, false);
      await service.submitBestTime(gridSize: 5, timeMs: 22000);
      // Should silently return without error
    });

    test('getWeeklyLeaderboard returns empty list when not signed in',
        () async {
      final service = GameServicesService();
      final results = await service.getWeeklyLeaderboard();
      expect(results, isEmpty);
    });

    test('leaderboard IDs are correctly generated for all grid sizes', () {
      for (final size in [3, 4, 5, 6, 7, 9]) {
        final iosId = GameServicesService.bestTimeLeaderboardId(
          gridSize: size,
          platform: 'ios',
        );
        final androidId = GameServicesService.bestTimeLeaderboardId(
          gridSize: size,
          platform: 'android',
        );
        expect(iosId, 'brainy_best_time_${size}x$size');
        expect(androidId, 'brainy_best_time_${size}x$size');
      }
    });

    test('weekly XP leaderboard ID is consistent across platforms', () {
      expect(
        GameServicesService.weeklyXpLeaderboardId(platform: 'ios'),
        GameServicesService.weeklyXpLeaderboardId(platform: 'android'),
      );
    });
  });
}
