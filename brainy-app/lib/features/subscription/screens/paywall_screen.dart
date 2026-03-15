import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/services/haptic_service.dart';
import '../../../shared/services/subscription_service.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen>
    with TickerProviderStateMixin {
  List<Package> _packages = [];
  bool _loading = true;
  int _selectedPlanIndex = 0;
  bool _purchasing = false;
  late final AnimationController _benefitController;

  @override
  void initState() {
    super.initState();
    _benefitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _loadPackages();
  }

  @override
  void dispose() {
    _benefitController.dispose();
    super.dispose();
  }

  Future<void> _loadPackages() async {
    final packages = await SubscriptionService.getAvailablePackages();
    if (!mounted) return;
    setState(() {
      _packages = packages;
      _loading = false;
      // Default to annual plan (first package) or index 0
      _selectedPlanIndex = 0;
    });
  }

  Future<void> _purchase() async {
    if (_packages.isEmpty || _purchasing) return;
    setState(() => _purchasing = true);

    final success =
        await SubscriptionService.purchasePackage(_packages[_selectedPlanIndex]);

    if (!mounted) return;
    setState(() => _purchasing = false);

    if (success) {
      HapticService.purchase();
      ref.invalidate(isPremiumProvider);
      await _showSuccessDialog();
    } else {
      _showErrorDialog();
    }
  }

  Future<void> _restore() async {
    setState(() => _purchasing = true);
    final success = await SubscriptionService.restorePurchases();
    if (!mounted) return;
    setState(() => _purchasing = false);

    if (success) {
      HapticService.purchase();
      ref.invalidate(isPremiumProvider);
      await _showSuccessDialog();
    } else {
      _showErrorDialog();
    }
  }

  Future<void> _showSuccessDialog() async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.primaryGradient.createShader(bounds),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.paywallWelcome,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
            },
            child: Text(
              l10n.onboardingLetsGo,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          l10n.paywallErrorTitle,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          l10n.paywallErrorMessage,
          style: const TextStyle(
            fontFamily: 'Nunito',
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size: 28,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Premium icon
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradient.createShader(bounds),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      l10n.paywallTitle,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    Text(
                      l10n.paywallSubtitle,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    // Animated benefits
                    _AnimatedBenefitsList(controller: _benefitController),
                    const SizedBox(height: 32),
                    // Plan cards
                    if (_loading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          l10n.paywallLoading,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    else if (_packages.isEmpty)
                      _FallbackPlanCards(
                        selectedIndex: _selectedPlanIndex,
                        onSelect: (i) =>
                            setState(() => _selectedPlanIndex = i),
                      )
                    else
                      _PackagePlanCards(
                        packages: _packages,
                        selectedIndex: _selectedPlanIndex,
                        onSelect: (i) =>
                            setState(() => _selectedPlanIndex = i),
                      ),
                    const SizedBox(height: 24),
                    // CTA button
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
                    const SizedBox(height: 12),
                    // Disclaimer
                    Text(
                      l10n.paywallDisclaimer,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Restore + Terms + Privacy
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LinkButton(
                          label: l10n.paywallRestore,
                          onTap: _purchasing ? null : _restore,
                        ),
                        _dot(),
                        _LinkButton(
                          label: l10n.paywallTerms,
                          onTap: () {
                            // TODO: open terms URL
                          },
                        ),
                        _dot(),
                        _LinkButton(
                          label: l10n.paywallPrivacy,
                          onTap: () {
                            // TODO: open privacy URL
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '·',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}

// --- Animated benefits list ---

class _AnimatedBenefitsList extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedBenefitsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final benefits = [
      (Icons.grid_view_rounded, l10n.paywallBenefit1),
      (Icons.people_rounded, l10n.paywallBenefit2),
      (Icons.bar_chart_rounded, l10n.paywallBenefit3),
      (Icons.block_rounded, l10n.paywallBenefit4),
      (Icons.swap_horiz_rounded, l10n.paywallBenefit5),
    ];

    return Column(
      children: List.generate(benefits.length, (i) {
        final start = i * 0.15;
        final end = (start + 0.4).clamp(0.0, 1.0);
        final animation = CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: Padding(
              padding: EdgeInsets.only(bottom: i < benefits.length - 1 ? 12 : 0),
              child: _BenefitRow(
                icon: benefits[i].$1,
                text: benefits[i].$2,
              ),
            ),
          ),
        );
      }),
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
        const Icon(
          Icons.check_rounded,
          color: AppColors.success,
          size: 20,
        ),
      ],
    );
  }
}

// --- Plan cards (from RevenueCat packages) ---

class _PackagePlanCards extends StatelessWidget {
  final List<Package> packages;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _PackagePlanCards({
    required this.packages,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: List.generate(packages.length, (i) {
        final pkg = packages[i];
        final product = pkg.storeProduct;
        final isSelected = i == selectedIndex;
        final isAnnual = pkg.packageType == PackageType.annual;

        return Padding(
          padding: EdgeInsets.only(bottom: i < packages.length - 1 ? 12 : 0),
          child: _PlanCard(
            title: _packageTitle(pkg, l10n),
            price: product.priceString,
            subtitle: isAnnual
                ? l10n.paywallPerMonth(_monthlyPrice(product))
                : null,
            badge: isAnnual ? l10n.paywallBestPrice : null,
            isSelected: isSelected,
            onTap: () => onSelect(i),
          ),
        );
      }),
    );
  }

  String _packageTitle(Package pkg, AppLocalizations l10n) {
    switch (pkg.packageType) {
      case PackageType.annual:
        return l10n.paywallPlanYear;
      case PackageType.monthly:
        return l10n.paywallPlanMonth;
      default:
        return pkg.storeProduct.title;
    }
  }

  String _monthlyPrice(StoreProduct product) {
    final monthly = product.price / 12;
    return monthly.toStringAsFixed(0);
  }
}

// --- Fallback plan cards (when RevenueCat not configured) ---

class _FallbackPlanCards extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _FallbackPlanCards({
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final plans = [
      (l10n.paywallPlanYear, '\$24.99/yr', l10n.paywallPerMonth('\$2'), l10n.paywallBestPrice),
      (l10n.paywallPlanMonth, '\$3.99/mo', null, null),
      (l10n.paywallPlanFamily, '\$39.99/yr', null, null),
    ];

    return Column(
      children: List.generate(plans.length, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i < plans.length - 1 ? 12 : 0),
          child: _PlanCard(
            title: plans[i].$1,
            price: plans[i].$2,
            subtitle: plans[i].$3,
            badge: plans[i].$4,
            isSelected: i == selectedIndex,
            onTap: () => onSelect(i),
          ),
        );
      }),
    );
  }
}

// --- Single plan card ---

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String? subtitle;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
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
            // Radio indicator
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
            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
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
            // Price
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

// --- Link button ---

class _LinkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _LinkButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          color: AppColors.textSecondary,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.textSecondary,
        ),
      ),
    );
  }
}
