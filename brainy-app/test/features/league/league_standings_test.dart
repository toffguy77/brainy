import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/features/league/providers/league_provider.dart';
import 'package:brainy/models/leaderboard_entry.dart';

void main() {
  final entries = [
    const LeaderboardEntry(playerName: 'Alex', score: 300, rank: 1),
    const LeaderboardEntry(playerName: 'GC-Me', score: 120, rank: 2),
  ];

  test('a player with a custom name is matched by Game Center name, once', () {
    final players = buildRealStandings(
      entries: entries,
      userXp: 120,
      userLevel: 3,
      playerName: 'Masha',
      gameCenterName: 'GC-Me',
    );
    expect(players.where((p) => p.isCurrentUser).length, 1);
    expect(players.length, 2);
    final me = players.firstWhere((p) => p.isCurrentUser);
    expect(me.name, 'Masha');
    expect(players.map((p) => p.name), isNot(contains('GC-Me')));
  });

  test('a player missing from the board is appended and sorted', () {
    final players = buildRealStandings(
      entries: entries,
      userXp: 500,
      userLevel: 3,
      playerName: null,
      gameCenterName: 'Someone else',
    );
    expect(players.first.isCurrentUser, isTrue);
    expect(players.first.name, 'Lv3');
    expect(players.length, 3);
  });
}
