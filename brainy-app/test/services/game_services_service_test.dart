import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/shared/services/game_services_service.dart';

void main() {
  group('GameServicesService', () {
    group('leaderboardId', () {
      test('returns correct ID for weekly_xp', () {
        expect(
          GameServicesService.weeklyXpLeaderboardId(platform: 'ios'),
          'brainy_weekly_xp',
        );
        expect(
          GameServicesService.weeklyXpLeaderboardId(platform: 'android'),
          'brainy_weekly_xp',
        );
      });

      test('returns correct ID for best time leaderboards', () {
        expect(
          GameServicesService.bestTimeLeaderboardId(gridSize: 3, platform: 'ios'),
          'brainy_best_time_3x3',
        );
        expect(
          GameServicesService.bestTimeLeaderboardId(gridSize: 5, platform: 'ios'),
          'brainy_best_time_5x5',
        );
        expect(
          GameServicesService.bestTimeLeaderboardId(gridSize: 9, platform: 'ios'),
          'brainy_best_time_9x9',
        );
      });

      test('returns correct ID for all grid sizes', () {
        for (final size in [3, 4, 5, 6, 7, 9]) {
          final id = GameServicesService.bestTimeLeaderboardId(
            gridSize: size,
            platform: 'ios',
          );
          expect(id, 'brainy_best_time_${size}x$size');
        }
      });
    });

    group('isSignedIn', () {
      test('starts as false', () {
        final service = GameServicesService();
        expect(service.isSignedIn, false);
      });
    });
  });
}
