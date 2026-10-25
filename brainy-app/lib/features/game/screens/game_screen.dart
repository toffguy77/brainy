import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_provider.dart';
import '../providers/session_completion_provider.dart';
import '../providers/user_progress_provider.dart';
import '../widgets/schulte_grid.dart';
import '../widgets/game_header.dart';
import '../widgets/countdown_overlay.dart';
import '../../../models/game_state.dart';
import '../../../constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/services/haptic_service.dart';
import '../../../shared/services/sound_service.dart';
import '../../../constants/game_modes.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int gridSize;
  final String mode;

  const GameScreen({
    super.key,
    this.gridSize = 5,
    this.mode = GameModes.classic,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(gameProvider.notifier).initGame(
            gridSize: widget.gridSize,
            mode: widget.mode,
            locale: Localizations.localeOf(context).languageCode,
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
                _buildProgressBar(context, gameState),
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

  Widget _buildProgressBar(BuildContext context, GameState gameState) {
    final found = gameState.mode == GameModes.gorbov
        ? (gameState.nextWhiteNumber - 1) + (gameState.redCount - gameState.nextRedNumber)
        : gameState.nextNumber - 1;
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
                AppLocalizations.of(context)!.gameFoundProgress(found, total),
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
    HapticService.gameComplete();
    final outcome =
        await ref.read(sessionCompleterProvider).complete(gameState);

    if (outcome.isRecord) {
      HapticService.recordBroken();
      SoundService.play(SoundEffect.recordBroken);
    } else {
      SoundService.play(SoundEffect.gameComplete);
    }
    SoundService.play(SoundEffect.coins);
    if (outcome.leveledUp) SoundService.play(SoundEffect.levelUp);

    if (!mounted) return;
    final progressAfter = ref.read(userProgressProvider);
    context.go('/result', extra: {
      'session': outcome.session,
      'isRecord': outcome.isRecord,
      'xpEarned': outcome.session.xpEarned,
      'totalXp': progressAfter.xp,
      'level': progressAfter.level,
      'newAchievements': outcome.newAchievements,
    });
  }
}
