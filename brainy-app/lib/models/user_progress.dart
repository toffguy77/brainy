class UserProgress {
  final int level;
  final int xp;
  final int coins;
  final int streak;
  final String activeCharacterId;

  const UserProgress({
    this.level = 1,
    this.xp = 0,
    this.coins = 0,
    this.streak = 0,
    this.activeCharacterId = 'brainy',
  });
}
