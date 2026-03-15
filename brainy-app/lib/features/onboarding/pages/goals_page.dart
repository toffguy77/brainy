import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_primary_button.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(onboardingProvider);

    final options = [
      ('concentration', l10n.onboardingGoalConcentration, Icons.center_focus_strong_rounded),
      ('reading', l10n.onboardingGoalReading, Icons.menu_book_rounded),
      ('exams', l10n.onboardingGoalExams, Icons.school_rounded),
      ('fun', l10n.onboardingGoalFun, Icons.sports_esports_rounded),
    ];

    return Column(
      children: [
        const SizedBox(height: 64),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            l10n.onboardingGoalsTitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            l10n.onboardingGoalsSubtitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        ...options.map((option) {
          final (key, label, icon) = option;
          final isSelected = state.goals.contains(key);
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: _GoalCard(
              icon: icon,
              label: label,
              isSelected: isSelected,
              onTap: () =>
                  ref.read(onboardingProvider.notifier).toggleGoal(key),
            ),
          );
        }),
        const Spacer(),
        OnboardingPrimaryButton(
          label: l10n.onboardingNext,
          onPressed: state.canAdvanceFromGoals
              ? () => ref.read(onboardingProvider.notifier).nextPage()
              : null,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
