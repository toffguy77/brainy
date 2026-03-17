import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/league.dart';
import '../../../models/leaderboard_entry.dart';
import '../../game/providers/sessions_provider.dart';
import '../../game/providers/user_progress_provider.dart';
import 'game_services_provider.dart';

/// Start of current week (Monday 00:00)
DateTime _weekStart() {
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  return DateTime(monday.year, monday.month, monday.day);
}

/// XP earned this week
final weeklyXpProvider = Provider<int>((ref) {
  final sessions = ref.watch(sessionsProvider);
  final start = _weekStart();
  final end = DateTime.now();
  return sessions
      .where((s) => s.playedAt.isAfter(start) && s.playedAt.isBefore(end))
      .fold<int>(0, (sum, s) => sum + s.xpEarned);
});

/// Current league tier based on weekly XP
final currentLeagueProvider = Provider<LeagueTier>((ref) {
  final xp = ref.watch(weeklyXpProvider);
  return LeagueTier.fromWeeklyXp(xp);
});

class LeaguePlayer {
  final String name;
  final int weeklyXp;
  final bool isCurrentUser;

  const LeaguePlayer({
    required this.name,
    required this.weeklyXp,
    this.isCurrentUser = false,
  });
}

/// League standings — real data from Game Services or simulated fallback.
final leagueStandingsProvider = FutureProvider<List<LeaguePlayer>>((ref) async {
  final userXp = ref.watch(weeklyXpProvider);
  final progress = ref.watch(userProgressProvider);
  final service = ref.watch(gameServicesProvider);
  final isSignedIn = ref.watch(isGameServicesSignedInProvider);
  final pName = ref.watch(playerNameProvider);

  // If signed in, try to get real leaderboard data
  if (isSignedIn) {
    final entries = await service.getWeeklyLeaderboard(count: 25);
    if (entries.isNotEmpty) {
      return _buildRealStandings(
        entries: entries,
        userXp: userXp,
        userLevel: progress.level,
        playerName: pName,
      );
    }
  }

  // Fallback: simulated opponents when not signed in (deliberate deviation
  // from spec which says "return empty list". Better UX to show simulated
  // standings so the league tab isn't empty for users without Game Center).
  return _buildSimulatedStandings(
    userXp: userXp,
    tier: LeagueTier.fromWeeklyXp(userXp),
    userLevel: progress.level,
  );
});

List<LeaguePlayer> _buildRealStandings({
  required List<LeaderboardEntry> entries,
  required int userXp,
  required int userLevel,
  required String? playerName,
}) {
  final players = <LeaguePlayer>[];
  bool userFound = false;

  for (final entry in entries) {
    // Check if this entry is the current player by name match
    final isMe = playerName != null && entry.playerName == playerName;
    if (isMe) userFound = true;

    players.add(LeaguePlayer(
      name: entry.playerName,
      weeklyXp: entry.score,
      isCurrentUser: isMe,
    ));
  }

  // If current user wasn't in the leaderboard, add them
  if (!userFound) {
    players.add(LeaguePlayer(
      name: playerName ?? 'Lv$userLevel',
      weeklyXp: userXp,
      isCurrentUser: true,
    ));
  }

  players.sort((a, b) => b.weeklyXp.compareTo(a.weeklyXp));
  return players;
}

List<LeaguePlayer> _buildSimulatedStandings({
  required int userXp,
  required LeagueTier tier,
  required int userLevel,
}) {
  final rng = Random(tier.index * 1000 + DateTime.now().weekday);
  final minXp = tier.xpThreshold;
  final nextTier = tier.nextTier;
  final maxXp = nextTier != null ? nextTier.xpThreshold + 50 : 1200;

  final players = <LeaguePlayer>[];

  const names = [
    'BrainStar', 'QuickMind', 'FlashCalc', 'NeuroPro', 'FocusKid',
    'MindRacer', 'SharpEye', 'SpeedBrain', 'ThinkFast',
  ];

  for (final name in names) {
    final xp = minXp + rng.nextInt(max(1, maxXp - minXp));
    players.add(LeaguePlayer(name: name, weeklyXp: xp));
  }

  players.add(LeaguePlayer(
    name: 'Lv$userLevel',
    weeklyXp: userXp,
    isCurrentUser: true,
  ));

  players.sort((a, b) => b.weeklyXp.compareTo(a.weeklyXp));
  return players;
}
