import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/game_modes.dart';
import '../../../models/achievement.dart';
import '../../../models/game_state.dart';
import '../../../models/session.dart';
import '../../../shared/services/notification_service.dart';
import '../../character/providers/character_provider.dart';
import '../../league/providers/game_services_provider.dart';
import '../../league/providers/league_provider.dart';
import '../../progress/providers/achievements_provider.dart';
import 'game_provider.dart';
import 'records_provider.dart';
import 'sessions_provider.dart';
import 'user_progress_provider.dart';

/// Everything the result screen needs to announce a finished game.
class SessionOutcome {
  final GameSession session;
  final bool isRecord;
  final bool leveledUp;
  final List<AchievementDef> newAchievements;
  final List<String> unlockedCharacters;

  const SessionOutcome({
    required this.session,
    required this.isRecord,
    required this.leveledUp,
    required this.newAchievements,
    required this.unlockedCharacters,
  });
}

/// Persists a finished game: record, session, streak, coins, XP, character
/// unlocks, achievements, leaderboards and the next reminder. Lives outside
/// the widget so the whole chain is testable with a ProviderContainer.
class SessionCompleter {
  final Ref _ref;

  /// Schedules the next reminder. Injectable so tests avoid the platform
  /// notification plugin.
  final Future<void> Function() _rescheduleReminder;

  /// Where failures of side effects go; Crashlytics in the app.
  final void Function(Object error, StackTrace stack) _onSideEffectError;

  SessionCompleter(
    this._ref, {
    Future<void> Function()? rescheduleReminder,
    void Function(Object error, StackTrace stack)? onSideEffectError,
  })  : _rescheduleReminder =
            rescheduleReminder ?? NotificationService.rescheduleFromStorage,
        _onSideEffectError = onSideEffectError ??
            ((e, s) =>
                FirebaseCrashlytics.instance.recordError(e, s, fatal: false));

  Future<SessionOutcome> complete(GameState game) async {
    final records = _ref.read(recordsProvider.notifier);
    final isRecord = records.isPersonalRecord(
      game.gridSize,
      game.totalSeconds,
      mode: game.mode,
    );
    if (isRecord) {
      await records.saveRecord(game.gridSize, game.totalSeconds,
          mode: game.mode);
    }

    final session = buildSessionFrom(game, isPersonalRecord: isRecord);
    await _ref.read(sessionsProvider.notifier).saveSession(session);

    final progress = _ref.read(userProgressProvider.notifier);
    final levelBefore = _ref.read(userProgressProvider).level;
    await progress.updateStreak();
    await progress.addCoins(session.coinsEarned);
    await progress.addXp(session.xpEarned);
    final progressAfter = _ref.read(userProgressProvider);

    final unlockedCharacters = await _ref
        .read(characterProvider.notifier)
        .unlockEligible(progressAfter);
    final newAchievements =
        await checkAchievements(session: session, ref: _ref);

    // Side effects must never hold up the result screen: a platform call
    // that throws or never returns would leave the child on a finished grid.
    _submitScores(session, isRecord);
    unawaited(_rescheduleReminder().catchError(_reportSideEffectError));

    return SessionOutcome(
      session: session,
      isRecord: isRecord,
      leveledUp: progressAfter.level > levelBefore,
      newAchievements: newAchievements,
      unlockedCharacters: unlockedCharacters,
    );
  }

  void _reportSideEffectError(Object error, StackTrace stack) {
    _onSideEffectError(error, stack);
  }

  /// Game Center boards are per grid size with no mode component, so only
  /// classic times are posted — other modes would pollute the classic boards.
  void _submitScores(GameSession session, bool isRecord) {
    final gameServices = _ref.read(gameServicesProvider);
    if (!gameServices.isSignedIn) return;
    unawaited(gameServices
        .submitWeeklyXp(_ref.read(weeklyXpProvider))
        .catchError(_reportSideEffectError));
    if (isRecord && session.mode == GameModes.classic) {
      unawaited(gameServices
          .submitBestTime(
            gridSize: session.gridSize,
            timeMs: session.durationSeconds * 1000,
          )
          .catchError(_reportSideEffectError));
    }
  }
}

final sessionCompleterProvider =
    Provider<SessionCompleter>((ref) => SessionCompleter(ref));
