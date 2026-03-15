import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_primary_button.dart';

class SchulteInfoPage extends ConsumerWidget {
  const SchulteInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 64),
          _MiniTable(),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingSchulteHint,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.onboardingSchulteTitle,
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
            l10n.onboardingSchulteSubtitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _BenefitRow(emoji: '🎯', text: l10n.onboardingSchulteBenefit1),
          const SizedBox(height: 14),
          _BenefitRow(emoji: '👁️', text: l10n.onboardingSchulteBenefit2),
          const SizedBox(height: 14),
          _BenefitRow(emoji: '📖', text: l10n.onboardingSchulteBenefit3),
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

class _MiniTable extends StatelessWidget {
  static const _numbers = [3, 7, 1, 5, 9, 4, 8, 2, 6];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final number = _numbers[index];
          return _MiniCell(number: number);
        },
      ),
    );
  }
}

class _MiniCell extends StatelessWidget {
  final int number;

  const _MiniCell({required this.number});

  @override
  Widget build(BuildContext context) {
    final isFound = number == 1;
    final isNext = number == 2;

    Color textColor = AppColors.textPrimary;
    Color bgColor = AppColors.surface;
    BoxBorder? border;

    if (isFound) {
      textColor = AppColors.success;
      bgColor = AppColors.success.withValues(alpha: 0.2);
      border = Border.all(color: AppColors.success, width: 2);
    } else if (isNext) {
      textColor = AppColors.primary;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: border,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String emoji;
  final String text;

  const _BenefitRow({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
