import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/onboarding_provider.dart';

class FrequencyPage extends ConsumerWidget {
  const FrequencyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedMinutes = ref.watch(onboardingProvider).dailyGoalMinutes;

    final options = [
      (5, l10n.onboardingFreq5min, l10n.onboardingFreq5minDesc, '⚡'),
      (10, l10n.onboardingFreq10min, l10n.onboardingFreq10minDesc, '⭐'),
      (15, l10n.onboardingFreq15min, l10n.onboardingFreq15minDesc, '🔥'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 64),
          Text(
            l10n.onboardingFrequencyTitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingFrequencySubtitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ...options.map((option) {
            final (minutes, label, desc, emoji) = option;
            final isSelected = selectedMinutes == minutes;
            final isRecommended =
                minutes == AppConstants.recommendedFrequencyMinutes;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FrequencyCard(
                emoji: emoji,
                label: label,
                description: desc,
                isSelected: isSelected,
                isRecommended: isRecommended,
                recommendedLabel: l10n.onboardingRecommended,
                onTap: () {
                  final notifier = ref.read(onboardingProvider.notifier);
                  notifier.setDailyGoalMinutes(minutes);
                  notifier.nextPage();
                },
              ),
            );
          }),
          const Spacer(),
        ],
      ),
    );
  }
}

class _FrequencyCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String description;
  final bool isSelected;
  final bool isRecommended;
  final String recommendedLabel;
  final VoidCallback onTap;

  const _FrequencyCard({
    required this.emoji,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.isRecommended,
    required this.recommendedLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : isRecommended
                        ? AppColors.accent.withValues(alpha: 0.5)
                        : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isRecommended)
            Positioned(
              top: -10,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  recommendedLabel,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.background,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
