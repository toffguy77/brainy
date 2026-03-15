import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/onboarding_provider.dart';

class AgePage extends ConsumerWidget {
  const AgePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedAge = ref.watch(onboardingProvider).childAge;

    final options = [
      ('6-9', l10n.onboardingAge69, '🧒'),
      ('10-12', l10n.onboardingAge1012, '👦'),
      ('13-14', l10n.onboardingAge1314, '👨‍🎓'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 64),
          Text(
            l10n.onboardingAgeTitle,
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
            l10n.onboardingAgeSubtitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ...options.map((option) {
            final (key, label, emoji) = option;
            final isSelected = selectedAge == key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AgeCard(
                emoji: emoji,
                label: label,
                isSelected: isSelected,
                onTap: () {
                  final notifier = ref.read(onboardingProvider.notifier);
                  notifier.setChildAge(key);
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

class _AgeCard extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AgeCard({
    required this.emoji,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
            Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
