import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../game/providers/sessions_provider.dart';
import '../../game/providers/user_progress_provider.dart';
import '../../parent/providers/parent_provider.dart';
import '../../character/data/characters_data.dart';
import '../../character/widgets/dressed_avatar.dart';
import '../../../constants/game_modes.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late int _selectedGridSize;
  String _selectedMode = GameModes.classic;
  late final AnimationController _idleController;
  late final Animation<double> _bobAnimation;

  @override
  void initState() {
    super.initState();
    final savedMode = Hive.box(AppConstants.userBox)
        .get(AppConstants.lastSelectedModeKey) as String?;
    if (savedMode != null && GameModes.all.contains(savedMode)) {
      _selectedMode = savedMode;
    }
    _selectedGridSize = AppConstants.clampGridSizeForMode(
      _selectedMode,
      ref.read(userProgressProvider).lastSelectedGridSize,
    );
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _bobAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = ref.watch(userProgressProvider);
    final sessions = ref.watch(sessionsProvider);
    final parentSettings = ref.watch(parentProvider);
    final isFixedMode =
        parentSettings.gridSizeMode == AppConstants.gridSizeModeFixed;
    // A parent-fixed size may not exist in the chosen mode (letters stops at
    // 5x5, Gorbov starts at 5x5), so it is clamped like a picked size.
    final effectiveGridSize = AppConstants.clampGridSizeForMode(
      _selectedMode,
      isFixedMode ? parentSettings.fixedGridSize : _selectedGridSize,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildTopBar(progress, l10n),
              const Spacer(flex: 1),
              _buildCharacterPlaceholder(),
              const SizedBox(height: 8),
              Text(
                l10n.levelLabel(progress.level),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(flex: 1),
              _buildModeToggle(l10n),
              Text(
                _modeHint(_selectedMode, l10n),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              _buildGridSizePicker(l10n, isFixedMode, effectiveGridSize),
              const SizedBox(height: 24),
              _buildPlayButton(l10n, effectiveGridSize),
              const SizedBox(height: 16),
              _buildLastResult(sessions, l10n),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToParent() {
    context.go('/parent/pin');
  }

  Widget _buildTopBar(progress, AppLocalizations l10n) {
    return Row(
      children: [
        _CoinsDisplay(coins: progress.coins),
        const Spacer(),
        _StreakDisplay(
          streak: progress.currentStreak,
          label: l10n.streakDays(progress.currentStreak),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _navigateToParent,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterPlaceholder() {
    final progress = ref.watch(userProgressProvider);
    final activeInfo = defaultCharacters.firstWhere(
      (c) => c.id == progress.activeCharacterId,
      orElse: () => defaultCharacters.first,
    );

    return AnimatedBuilder(
      animation: _bobAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bobAnimation.value),
          child: child,
        );
      },
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              activeInfo.color.withValues(alpha: 0.8),
              activeInfo.color.withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: activeInfo.color.withValues(alpha: 0.5),
            width: 3,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: DressedAvatar(
              characterId: progress.activeCharacterId, size: 112),
        ),
      ),
    );
  }

  static const _modes = GameModes.all;

  String _modeLabel(String mode, AppLocalizations l10n) => switch (mode) {
        GameModes.reverse => l10n.gameModeReverse,
        GameModes.gorbov => l10n.gameModeGorbov,
        GameModes.letters => l10n.gameModeLetters,
        _ => l10n.gameModeClassic,
      };

  String _modeHint(String mode, AppLocalizations l10n) => switch (mode) {
        GameModes.reverse => l10n.gameModeReverseHint,
        GameModes.gorbov => l10n.gameModeGorbovHint,
        GameModes.letters => l10n.gameModeLettersHint,
        _ => l10n.gameModeClassicHint,
      };

  /// Four modes no longer fit a two-segment toggle at these font sizes, so the
  /// selector is a 2x2 grid of chips.
  Widget _buildModeToggle(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          for (int i = 0; i < _modes.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  for (int j = i; j < i + 2 && j < _modes.length; j++) ...[
                    if (j > i) const SizedBox(width: 8),
                    Expanded(child: _modeChip(_modes[j], l10n)),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _modeChip(String mode, AppLocalizations l10n) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () => _onModeTap(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? null : AppColors.surface,
          gradient: isSelected
              ? (mode == GameModes.gorbov
                  ? const LinearGradient(
                      colors: [Color(0xFFE17055), Color(0xFFFDCB6E)])
                  : AppColors.primaryGradient)
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            _modeLabel(mode, l10n),
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  void _onModeTap(String mode) {
    setState(() {
      _selectedMode = mode;
      // A size valid in the previous mode may not exist in the new one.
      _selectedGridSize =
          AppConstants.clampGridSizeForMode(mode, _selectedGridSize);
    });
    Hive.box(AppConstants.userBox).put(AppConstants.lastSelectedModeKey, mode);
  }

  Widget _buildGridSizePicker(
      AppLocalizations l10n, bool isFixedMode, int effectiveGridSize) {
    if (isFixedMode) {
      return Column(
        children: [
          Text(
            l10n.selectGridSize,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _GridSizeChip(
            size: effectiveGridSize,
            isSelected: true,
            onTap: () {},
          ),
        ],
      );
    }

    return Column(
      children: [
        Text(
          l10n.selectGridSize,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: AppConstants.gridSizesForMode(_selectedMode).map((size) {
            final isSelected = _selectedGridSize == size;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _GridSizeChip(
                size: size,
                isSelected: isSelected,
                onTap: () => _onGridSizeTap(size),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _onGridSizeTap(int size) {
    setState(() => _selectedGridSize = size);
    ref.read(userProgressProvider.notifier).setSelectedGridSize(size);
  }

  Widget _buildPlayButton(AppLocalizations l10n, int effectiveGridSize) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              context.go('/game?size=$effectiveGridSize&mode=$_selectedMode');
            },
            child: Center(
              child: Text(
                l10n.playNow,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLastResult(List sessions, AppLocalizations l10n) {
    if (sessions.isEmpty) {
      return Text(
        l10n.noSessionsYet,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      );
    }
    final last = sessions.first;
    return Text(
      '${_modeLabel(last.mode, l10n)} · '
      '${l10n.lastResult(last.gridSize, last.durationSeconds)}',
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _CoinsDisplay extends StatelessWidget {
  final int coins;
  const _CoinsDisplay({required this.coins});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monetization_on_rounded,
            color: AppColors.accent,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            '$coins',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakDisplay extends StatelessWidget {
  final int streak;
  final String label;
  const _StreakDisplay({required this.streak, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: streak > 0 ? Colors.orange : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: streak > 0 ? Colors.orange : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridSizeChip extends StatelessWidget {
  final int size;
  final bool isSelected;
  final VoidCallback onTap;

  const _GridSizeChip({
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            '$size×$size',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
