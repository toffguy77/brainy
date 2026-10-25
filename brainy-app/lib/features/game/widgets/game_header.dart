import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../../../models/game_state.dart';
import '../../../constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../constants/game_modes.dart';

class GameHeader extends ConsumerWidget {
  final GameState gameState;
  const GameHeader({super.key, required this.gameState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _PauseButton(gameState: gameState),
          const Spacer(),
          _NextNumberBadge(gameState: gameState),
          const Spacer(),
          _TimerDisplay(seconds: gameState.totalSeconds),
        ],
      ),
    );
  }
}

class _PauseButton extends ConsumerWidget {
  final GameState gameState;
  const _PauseButton({required this.gameState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (gameState.status == GameStatus.playing ||
            gameState.status == GameStatus.paused) {
          ref.read(gameProvider.notifier).togglePause();
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          gameState.status == GameStatus.paused
              ? Icons.play_arrow_rounded
              : Icons.pause_rounded,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _NextNumberBadge extends StatelessWidget {
  final GameState gameState;
  const _NextNumberBadge({required this.gameState});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isGorbov = gameState.mode == GameModes.gorbov;

    String hintText;
    String displayLabel;
    Color badgeColor;

    if (isGorbov) {
      if (gameState.nextExpectedColor == 'white') {
        hintText = l10n.gorbovHintWhite(gameState.nextWhiteNumber);
        displayLabel = '${gameState.nextWhiteNumber}';
        badgeColor = AppColors.textPrimary;
      } else {
        hintText = l10n.gorbovHintRed(gameState.nextRedNumber);
        displayLabel = '${gameState.nextRedNumber}';
        badgeColor = AppColors.gorbovRed;
      }
    } else {
      hintText = l10n.gameFind;
      displayLabel = gameState.expectedLabel;
      badgeColor = Colors.white;
    }

    return Column(
      children: [
        Text(
          hintText,
          style: const TextStyle(
            fontFamily: 'Nunito',
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: isGorbov && gameState.nextExpectedColor == 'red'
                ? const LinearGradient(colors: [Color(0xFFE17055), Color(0xFFFDCB6E)])
                : AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            displayLabel,
            style: TextStyle(
              color: badgeColor,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimerDisplay extends StatelessWidget {
  final int seconds;
  const _TimerDisplay({required this.seconds});

  String _formatted(AppLocalizations l10n) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return m > 0
        ? l10n.timeMinSec(m, s.toString().padLeft(2, '0'))
        : l10n.timeSec(s);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatted(l10n),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
