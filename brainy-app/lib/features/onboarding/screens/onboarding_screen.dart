import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../providers/onboarding_provider.dart';
import '../pages/welcome_page.dart';
import '../pages/age_page.dart';
import '../pages/goals_page.dart';
import '../pages/frequency_page.dart';
import '../pages/paywall_page.dart';
import '../pages/schulte_info_page.dart';
import '../pages/science_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(onboardingProvider).currentPage;

    ref.listen(onboardingProvider, (prev, next) {
      if (prev?.currentPage != next.currentPage) {
        _pageController.animateToPage(
          next.currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
      if (next.isCompleted && !(prev?.isCompleted ?? false)) {
        context.go('/home');
      }
    });

    return PopScope(
      canPop: currentPage == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          ref.read(onboardingProvider.notifier).previousPage();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    WelcomePage(),
                    SchulteInfoPage(),
                    SciencePage(),
                    AgePage(),
                    GoalsPage(),
                    FrequencyPage(),
                    PaywallPage(),
                  ],
                ),
              ),
              _BottomNav(currentPage: currentPage),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends ConsumerWidget {
  final int currentPage;

  const _BottomNav({required this.currentPage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        children: [
          Opacity(
            opacity: currentPage > 0 ? 1.0 : 0.0,
            child: IconButton(
              onPressed: currentPage > 0
                  ? () =>
                      ref.read(onboardingProvider.notifier).previousPage()
                  : null,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Spacer(),
          _PageIndicator(
            currentPage: currentPage,
            totalPages: AppConstants.onboardingPageCount,
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _PageIndicator({
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(4),
              border: isActive
                  ? null
                  : Border.all(color: AppColors.textSecondary, width: 1),
            ),
          ),
        );
      }),
    );
  }
}
