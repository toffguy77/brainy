class LeaderboardEntry {
  final String playerName;
  final int score;
  final int rank;
  final bool isCurrentPlayer;

  const LeaderboardEntry({
    required this.playerName,
    required this.score,
    required this.rank,
    this.isCurrentPlayer = false,
  });
}
