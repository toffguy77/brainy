import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_provider.dart';
import '../providers/records_provider.dart';
import '../providers/sessions_provider.dart';
import '../providers/user_progress_provider.dart';
import '../../progress/providers/achievements_provider.dart';
import '../widgets/schulte_grid.dart';
import '../widgets/game_header.dart';
import '../widgets/countdown_overlay.dart';
import '../../../models/game_state.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../shared/services/haptic_service.dart';
import '../../../shared/services/notification_service.dart';
import '../../league/providers/game_services_provider.dart';
import '../../league/providers/league_provider.dart';
import '../../parent/providers/parent_provider.dart';
import '../../../shared/services/sound_service.dart';
import '../../../shared/services/subscription_service.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int gridSize;
  final String mode;

  const GameScreen({
    super.key,
    this.gridSize = 5,
    this.mode = 'classic',
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Guard: premium grid sizes require subscription
      if (AppConstants.premiumGridSizes.contains(widget.gridSize)) {
        final hasPremium = await SubscriptionService.isPremium();
        if (!hasPremium && mounted) {
          context.go('/paywall');
          return;
        }
      }
      if (!mounted) return;
      ref.read(gameProvider.notifier).initGame(
            gridSize: widget.gridSize,
            mode: widget.mode,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    ref.listen(gameProvider, (prev, next) {
      if (next.status == GameStatus.finished && !_finished) {
        _finished = true;
        _handleGameFinished(next);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                GameHeader(gameState: gameState),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SchulteGrid(gameState: gameState),
                  ),
                ),
                const SizedBox(height: 16),
                _buildProgressBar(gameState),
                const SizedBox(height: 24),
              ],
            ),
            if (gameState.status == GameStatus.countdown)
              CountdownOverlay(value: gameState.countdownValue ?? 3),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(GameState gameState) {
    final found = gameState.nextNumber - 1;
    final total = gameState.totalNumbers;
    final progress = total > 0 ? found / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Найдено: $found / $total',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surface,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGameFinished(GameState gameState) async {
    // Sound & haptic for game completion
    HapticService.gameComplete();
    if (gameState.mistakesCount == 0) {
      SoundService.play(SoundEffect.gameComplete);
    }

    final records = ref.read(recordsProvider.notifier);
    final isRecord = records.isPersonalRecord(
      gameState.gridSize,
      gameState.totalSeconds,
    );

    if (isRecord) {
      records.saveRecord(gameState.gridSize, gameState.totalSeconds);
      HapticService.recordBroken();
      SoundService.play(SoundEffect.recordBroken);
    } else {
      SoundService.play(SoundEffect.gameComplete);
    }

    final session = ref
        .read(gameProvider.notifier)
        .buildSession(isPersonalRecord: isRecord);

    ref.read(sessionsProvider.notifier).saveSession(session);

    final progress = ref.read(userProgressProvider.notifier);
    final levelBefore = ref.read(userProgressProvider).level;
    await progress.updateStreak();
    await progress.addCoins(session.coinsEarned);
    SoundService.play(SoundEffect.coins);
    await progress.addXp(session.xpEarned);

    // Submit scores to Game Center / Play Games
    final gameServices = ref.read(gameServicesProvider);
    if (gameServices.isSignedIn) {
      final weeklyXp = ref.read(weeklyXpProvider);
      gameServices.submitWeeklyXp(weeklyXp);
      if (isRecord) {
        gameServices.submitBestTime(
          gridSize: session.gridSize,
          timeMs: session.durationSeconds * 1000,
        );
      }
    }

    final levelAfter = ref.read(userProgressProvider).level;
    if (levelAfter > levelBefore) {
      SoundService.play(SoundEffect.levelUp);
    }

    // Reschedule notification — hasPlayedToday=true will cancel it
    final parentSettings = ref.read(parentProvider);
    final progressData = ref.read(userProgressProvider);
    NotificationService.reschedule(
      enabled: parentSettings.notificationsEnabled,
      hasCustomTime: parentSettings.hasCustomReminderTime,
      hour: parentSettings.customReminderHour,
      minute: parentSettings.customReminderMinute,
      currentStreak: progressData.currentStreak,
      hasPlayedToday: true,
    );

    // Check achievements
    final newAchievements = await checkAchievements(session: session, ref: ref);

    if (!mounted) return;
    final progressAfter = ref.read(userProgressProvider);
    context.go('/result', extra: {
      'session': session,
      'isRecord': isRecord,
      'xpEarned': session.xpEarned,
      'totalXp': progressAfter.xp,
      'level': progressAfter.level,
      'newAchievements': newAchievements,
    });
  }
}
