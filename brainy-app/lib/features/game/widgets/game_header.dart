import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../../../models/game_state.dart';
import '../../../constants/app_colors.dart';

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
          _NextNumberBadge(number: gameState.nextNumber),
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
  final int number;
  const _NextNumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Найди',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
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

  String get _formatted {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return m > 0 ? '$m:${s.toString().padLeft(2, '0')}' : '$s сек';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatted,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
