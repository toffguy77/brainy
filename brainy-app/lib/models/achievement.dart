import '../l10n/app_localizations.dart';

enum AchievementId {
  firstGame,
  personalRecord,
  speedDemon,
  master5x5,
  focusMode,
  streak3,
  streak7,
  streak30,
  nightOwl,
  coinHoarder,
}

class AchievementDef {
  final AchievementId id;
  final String assetPath;

  const AchievementDef({required this.id, required this.assetPath});

  String get idString {
    // Convert enum name to snake_case for persistence
    return switch (id) {
      AchievementId.firstGame => 'first_game',
      AchievementId.personalRecord => 'personal_record',
      AchievementId.speedDemon => 'speed_demon',
      AchievementId.master5x5 => 'master_5x5',
      AchievementId.focusMode => 'focus_mode',
      AchievementId.streak3 => 'streak_3',
      AchievementId.streak7 => 'streak_7',
      AchievementId.streak30 => 'streak_30',
      AchievementId.nightOwl => 'night_owl',
      AchievementId.coinHoarder => 'coin_hoarder',
    };
  }

  String title(AppLocalizations l10n) => switch (id) {
        AchievementId.firstGame => l10n.achievementFirstGame,
        AchievementId.personalRecord => l10n.achievementPersonalRecord,
        AchievementId.speedDemon => l10n.achievementSpeedDemon,
        AchievementId.master5x5 => l10n.achievementMaster5x5,
        AchievementId.focusMode => l10n.achievementFocusMode,
        AchievementId.streak3 => l10n.achievementStreak3,
        AchievementId.streak7 => l10n.achievementStreak7,
        AchievementId.streak30 => l10n.achievementStreak30,
        AchievementId.nightOwl => l10n.achievementNightOwl,
        AchievementId.coinHoarder => l10n.achievementCoinHoarder,
      };

  String description(AppLocalizations l10n) => switch (id) {
        AchievementId.firstGame => l10n.achievementFirstGameDesc,
        AchievementId.personalRecord => l10n.achievementPersonalRecordDesc,
        AchievementId.speedDemon => l10n.achievementSpeedDemonDesc,
        AchievementId.master5x5 => l10n.achievementMaster5x5Desc,
        AchievementId.focusMode => l10n.achievementFocusModeDesc,
        AchievementId.streak3 => l10n.achievementStreak3Desc,
        AchievementId.streak7 => l10n.achievementStreak7Desc,
        AchievementId.streak30 => l10n.achievementStreak30Desc,
        AchievementId.nightOwl => l10n.achievementNightOwlDesc,
        AchievementId.coinHoarder => l10n.achievementCoinHoarderDesc,
      };
}

const allAchievements = [
  AchievementDef(id: AchievementId.firstGame, assetPath: 'assets/badges/first_game.png'),
  AchievementDef(id: AchievementId.personalRecord, assetPath: 'assets/badges/personal_record.png'),
  AchievementDef(id: AchievementId.speedDemon, assetPath: 'assets/badges/speed_demon.png'),
  AchievementDef(id: AchievementId.master5x5, assetPath: 'assets/badges/master_5x5.png'),
  AchievementDef(id: AchievementId.focusMode, assetPath: 'assets/badges/focus_mode.png'),
  AchievementDef(id: AchievementId.streak3, assetPath: 'assets/badges/streak_3.png'),
  AchievementDef(id: AchievementId.streak7, assetPath: 'assets/badges/streak_7.png'),
  AchievementDef(id: AchievementId.streak30, assetPath: 'assets/badges/streak_30.png'),
  AchievementDef(id: AchievementId.nightOwl, assetPath: 'assets/badges/night_owl.png'),
  AchievementDef(id: AchievementId.coinHoarder, assetPath: 'assets/badges/coin_hoarder.png'),
];
