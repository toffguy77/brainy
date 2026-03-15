import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/services/subscription_service.dart';
import '../../game/providers/sessions_provider.dart';
import '../../game/providers/user_progress_provider.dart';
import '../../parent/providers/parent_provider.dart';
import '../../subscription/widgets/premium_bottom_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late int _selectedGridSize;
  late final AnimationController _idleController;
  late final Animation<double> _bobAnimation;

  @override
  void initState() {
    super.initState();
    _selectedGridSize = ref.read(userProgressProvider).lastSelectedGridSize;
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
    final isPremium = ref.watch(isPremiumProvider).value ?? false;
    final isFixedMode = parentSettings.gridSizeMode == 'fixed';
    final effectiveGridSize =
        isFixedMode ? parentSettings.fixedGridSize : _selectedGridSize;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildTopBar(progress, l10n),
              const Spacer(flex: 2),
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
              const Spacer(flex: 2),
              _buildGridSizePicker(l10n, isFixedMode, effectiveGridSize, isPremium),
              const SizedBox(height: 24),
              _buildPlayButton(l10n, effectiveGridSize, isPremium),
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
    return AnimatedBuilder(
      animation: _bobAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bobAnimation.value),
          child: child,
        );
      },
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Icon(
          Icons.face_rounded,
          size: 100,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildGridSizePicker(
      AppLocalizations l10n, bool isFixedMode, int effectiveGridSize, bool isPremium) {
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
            isLocked: false,
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
          children: AppConstants.pickerGridSizes.map((size) {
            final isLocked =
                !isPremium && AppConstants.premiumGridSizes.contains(size);
            final isSelected = _selectedGridSize == size;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _GridSizeChip(
                size: size,
                isSelected: isSelected,
                isLocked: isLocked,
                onTap: () => _onGridSizeTap(size, isLocked, l10n),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _onGridSizeTap(int size, bool isLocked, AppLocalizations l10n) {
    if (isLocked) {
      showPremiumBottomSheet(
        context,
        feature: '$size×$size',
        benefit: l10n.onboardingPaywallBenefit1,
      );
      return;
    }
    setState(() => _selectedGridSize = size);
    ref.read(userProgressProvider.notifier).setSelectedGridSize(size);
  }

  Widget _buildPlayButton(AppLocalizations l10n, int effectiveGridSize, bool isPremium) {
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
              if (!isPremium && AppConstants.premiumGridSizes.contains(effectiveGridSize)) {
                showPremiumBottomSheet(
                  context,
                  feature: '$effectiveGridSize×$effectiveGridSize',
                  benefit: l10n.onboardingPaywallBenefit1,
                );
                return;
              }
              context.go('/game?size=$effectiveGridSize&mode=classic');
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
      l10n.lastResult(last.gridSize, last.durationSeconds),
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
  final bool isLocked;
  final VoidCallback onTap;

  const _GridSizeChip({
    required this.size,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isLocked
                  ? AppColors.surface.withValues(alpha: 0.5)
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: isLocked
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$size×$size',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Icon(
                      Icons.lock_rounded,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                  ],
                )
              : Text(
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
