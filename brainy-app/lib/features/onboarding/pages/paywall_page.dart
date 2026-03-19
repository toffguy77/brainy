import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/services/subscription_service.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_primary_button.dart';

class PaywallPage extends ConsumerStatefulWidget {
  const PaywallPage({super.key});

  @override
  ConsumerState<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends ConsumerState<PaywallPage> {
  Future<void> _showPaywall() async {
    // Navigate to the custom PaywallScreen
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const _OnboardingPaywallScreen(),
      ),
    );

    if (!mounted) return;

    // If purchase was successful, complete onboarding
    if (result == true) {
      await ref.read(onboardingProvider.notifier).completeOnboarding();
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

/// Inline paywall screen used during onboarding.
/// Returns true via Navigator.pop when purchase succeeds.
class _OnboardingPaywallScreen extends ConsumerStatefulWidget {
  const _OnboardingPaywallScreen();

  @override
  ConsumerState<_OnboardingPaywallScreen> createState() =>
      _OnboardingPaywallScreenState();
}

class _OnboardingPaywallScreenState
    extends ConsumerState<_OnboardingPaywallScreen> {
  int _selectedPlanIndex = 0;
  bool _purchasing = false;

  SubscriptionPlan get _selectedPlan =>
      _selectedPlanIndex == 0 ? SubscriptionPlan.yearly : SubscriptionPlan.monthly;

  Future<void> _purchase() async {
    if (_purchasing) return;
    setState(() => _purchasing = true);

    final result = await SubscriptionService.purchase(_selectedPlan);

    if (!mounted) return;
    setState(() => _purchasing = false);

    switch (result) {
      case BrainyPurchaseResult.success:
        ref.invalidate(isPremiumProvider);
        Navigator.of(context).pop(true);
      case BrainyPurchaseResult.cancelled:
        break;
      case BrainyPurchaseResult.error:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment error. Please try again.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(false),
          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.paywallTitle,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Yearly plan
              _OnboardingPlanCard(
                title: l10n.paywallPlanYear,
                price: '1 990 \u20BD/\u0433\u043E\u0434',
                subtitle: l10n.paywallPerMonth('166\u20BD'),
                badge: l10n.paywallBestPrice,
                isSelected: _selectedPlanIndex == 0,
                onTap: () => setState(() => _selectedPlanIndex = 0),
              ),
              const SizedBox(height: 12),
              // Monthly plan
              _OnboardingPlanCard(
                title: l10n.paywallPlanMonth,
                price: '299 \u20BD/\u043C\u0435\u0441',
                isSelected: _selectedPlanIndex == 1,
                onTap: () => setState(() => _selectedPlanIndex = 1),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _purchasing ? null : _purchase,
                      child: Center(
                        child: _purchasing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.textPrimary,
                                ),
                              )
                            : Text(
                                l10n.paywallTryFree,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String? subtitle;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _OnboardingPlanCard({
    required this.title,
    required this.price,
    this.subtitle,
    this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
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
