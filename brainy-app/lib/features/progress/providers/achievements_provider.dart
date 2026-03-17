import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/achievement.dart';
import '../../../models/session.dart';
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

/// Checks all achievement conditions against the just-completed session
/// and current state. Returns the list of newly unlocked achievements.
Future<List<AchievementDef>> checkAchievements({
  required GameSession session,
  required WidgetRef ref,
}) async {
  final progress = ref.read(userProgressProvider);
  final progressNotifier = ref.read(userProgressProvider.notifier);
  final sessions = ref.read(sessionsProvider);
  final newlyUnlocked = <AchievementDef>[];

  for (final def in allAchievements) {
    if (progress.unlockedAchievements.contains(def.idString)) continue;

    final shouldUnlock = switch (def.id) {
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

    if (shouldUnlock) {
      final wasNew = await progressNotifier.unlockAchievement(def.idString);
      if (wasNew) newlyUnlocked.add(def);
    }
  }

  return newlyUnlocked;
}
