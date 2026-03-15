import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_primary_button.dart';

class SciencePage extends ConsumerWidget {
  const SciencePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 64),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(38),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('🧠', style: TextStyle(fontSize: 36)),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.onboardingScienceTitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingScienceSubtitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          _FactCard(
            value: l10n.onboardingScienceFact1Value,
            label: l10n.onboardingScienceFact1Label,
            valueColor: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _FactCard(
            value: l10n.onboardingScienceFact2Value,
            label: l10n.onboardingScienceFact2Label,
            valueColor: AppColors.secondary,
          ),
          const SizedBox(height: 12),
          _FactCard(
            value: l10n.onboardingScienceFact3Value,
            label: l10n.onboardingScienceFact3Label,
            valueColor: AppColors.accent,
          ),
          const Spacer(),
          OnboardingPrimaryButton(
            label: l10n.onboardingNext,
            onPressed: () =>
                ref.read(onboardingProvider.notifier).nextPage(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _FactCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _FactCard({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
