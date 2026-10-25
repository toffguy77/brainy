import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/achievement.dart';
import '../../../models/session.dart';
import '../../../models/user_progress.dart';
import '../../game/providers/sessions_provider.dart';
import '../../game/providers/user_progress_provider.dart';

class AchievementState {
  final AchievementDef def;
  final bool unlocked;

  const AchievementState({required this.def, required this.unlocked});
}

final achievementsStateProvider = Provider<List<AchievementState>>((ref) {
  final progress = ref.watch(userProgressProvider);
  return allAchievements
      .map((def) => AchievementState(
            def: def,
            unlocked: progress.unlockedAchievements.contains(def.idString),
          ))
      .toList();
});

/// Pure unlock rules: which still-locked achievements the just-completed
/// [session] earns, given [progress] (after streak, coins and XP were applied)
/// and all saved [sessions].
List<AchievementDef> achievementsToUnlock({
  required GameSession session,
  required UserProgress progress,
  required List<GameSession> sessions,
}) {
  return [
    for (final def in allAchievements)
      if (!progress.unlockedAchievements.contains(def.idString) &&
          _isEarned(def.id, session, progress, sessions))
        def,
  ];
}

bool _isEarned(AchievementId id, GameSession session, UserProgress progress,
    List<GameSession> sessions) {
  return switch (id) {
    AchievementId.firstGame => sessions.isNotEmpty,
    AchievementId.personalRecord => session.isPersonalRecord,
    AchievementId.speedDemon =>
      session.gridSize == 3 && session.durationSeconds <= 5,
    AchievementId.master5x5 =>
      session.gridSize == 5 && session.durationSeconds <= 20,
    AchievementId.focusMode => session.mistakesCount == 0,
    AchievementId.streak3 => progress.currentStreak >= 3,
    AchievementId.streak7 => progress.currentStreak >= 7,
    AchievementId.streak30 => progress.currentStreak >= 30,
    AchievementId.nightOwl => session.playedAt.hour >= 22,
    AchievementId.coinHoarder => progress.coins >= 500,
  };
}

/// Unlocks every achievement [session] earns and returns the newly unlocked
/// ones, so the result screen can announce them.
Future<List<AchievementDef>> checkAchievements({
  required GameSession session,
  required Ref ref,
}) async {
  final progressNotifier = ref.read(userProgressProvider.notifier);
  final earned = achievementsToUnlock(
    session: session,
    progress: ref.read(userProgressProvider),
    sessions: ref.read(sessionsProvider),
  );
  final newlyUnlocked = <AchievementDef>[];
  for (final def in earned) {
    if (await progressNotifier.unlockAchievement(def.idString)) {
      newlyUnlocked.add(def);
    }
  }
  return newlyUnlocked;
}
