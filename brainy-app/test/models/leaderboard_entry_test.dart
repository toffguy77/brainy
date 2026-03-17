import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/models/leaderboard_entry.dart';

void main() {
  group('LeaderboardEntry', () {
    test('creates with all fields', () {
      final entry = LeaderboardEntry(
        playerName: 'TestPlayer',
        score: 500,
        rank: 3,
        isCurrentPlayer: false,
      );

      expect(entry.playerName, 'TestPlayer');
      expect(entry.score, 500);
      expect(entry.rank, 3);
      expect(entry.isCurrentPlayer, false);
    });

    test('isCurrentPlayer defaults to false', () {
      final entry = LeaderboardEntry(
        playerName: 'Other',
        score: 100,
        rank: 1,
      );

      expect(entry.isCurrentPlayer, false);
    });

    test('isCurrentPlayer can be true', () {
      final entry = LeaderboardEntry(
        playerName: 'Me',
        score: 200,
        rank: 5,
        isCurrentPlayer: true,
      );

      expect(entry.isCurrentPlayer, true);
    });
  });
}
