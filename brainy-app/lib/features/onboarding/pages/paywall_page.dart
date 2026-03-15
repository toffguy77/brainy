import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_primary_button.dart';

class PaywallPage extends ConsumerStatefulWidget {
  const PaywallPage({super.key});

  @override
  ConsumerState<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends ConsumerState<PaywallPage> {
  bool _paywallShown = false;

  Future<void> _showPaywall() async {
    if (_paywallShown) return;
    _paywallShown = true;

    final result = await RevenueCatUI.presentPaywallIfNeeded(
      AppConstants.revenueCatEntitlement,
      displayCloseButton: true,
    );

    if (!mounted) return;

    if (result == PaywallResult.purchased ||
        result == PaywallResult.restored ||
        result == PaywallResult.notPresented) {
      await ref.read(onboardingProvider.notifier).completeOnboarding();
    } else {
      setState(() => _paywallShown = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 64),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.primaryGradient.createShader(bounds),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: 72,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.onboardingPaywallTitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _BenefitRow(
            icon: Icons.grid_view_rounded,
            text: l10n.onboardingPaywallBenefit1,
          ),
          const SizedBox(height: 16),
          _BenefitRow(
            icon: Icons.people_rounded,
            text: l10n.onboardingPaywallBenefit2,
          ),
          const SizedBox(height: 16),
          _BenefitRow(
            icon: Icons.bar_chart_rounded,
            text: l10n.onboardingPaywallBenefit3,
          ),
          const SizedBox(height: 16),
          _BenefitRow(
            icon: Icons.block_rounded,
            text: l10n.onboardingPaywallBenefit4,
          ),
          const Spacer(),
          OnboardingPrimaryButton(
            label: l10n.onboardingTryFree,
            onPressed: _showPaywall,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () async {
              await ref
                  .read(onboardingProvider.notifier)
                  .completeOnboarding();
            },
            child: Text(
              l10n.onboardingSkipPaywall,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
