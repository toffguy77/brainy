import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum LeagueTier {
  bronze(
    xpThreshold: 0,
    assetPath: 'assets/leagues/bronze.png',
    color: Color(0xFFCD7F32),
  ),
  silver(
    xpThreshold: 150,
    assetPath: 'assets/leagues/silver.png',
    color: Color(0xFFC0C0C0),
  ),
  gold(
    xpThreshold: 400,
    assetPath: 'assets/leagues/gold.png',
    color: Color(0xFFFFD700),
  ),
  platinum(
    xpThreshold: 800,
    assetPath: 'assets/leagues/platinum.png',
    color: Color(0xFFE5E4E2),
  );

  final int xpThreshold;
  final String assetPath;
  final Color color;

  const LeagueTier({
    required this.xpThreshold,
    required this.assetPath,
    required this.color,
  });

  String title(AppLocalizations l10n) => switch (this) {
        LeagueTier.bronze => l10n.leagueBronze,
        LeagueTier.silver => l10n.leagueSilver,
        LeagueTier.gold => l10n.leagueGold,
        LeagueTier.platinum => l10n.leaguePlatinum,
      };

  LeagueTier? get nextTier {
    final idx = LeagueTier.values.indexOf(this);
    if (idx >= LeagueTier.values.length - 1) return null;
    return LeagueTier.values[idx + 1];
  }

  static LeagueTier fromWeeklyXp(int xp) {
    var tier = LeagueTier.bronze;
    for (final t in LeagueTier.values) {
      if (xp >= t.xpThreshold) tier = t;
    }
    return tier;
  }
}
