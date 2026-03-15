import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/session.dart';
import '../../../shared/services/haptic_service.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const ResultScreen({super.key, this.extra});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  GameSession? _session;
  late final bool isRecord;
  int _xpEarned = 0;
  int _totalXp = 0;
  int _level = 1;

  late final AnimationController _titleController;
  late final AnimationController _starsController;
  late final AnimationController _coinsController;
  late final Animation<int> _coinsAnimation;

  ConfettiController? _confettiController;

  GameSession get session => _session!;

  @override
  void initState() {
    super.initState();

    final extra = widget.extra;
    if (extra == null || extra['session'] is! GameSession) {
      isRecord = false;
      _titleController = AnimationController(vsync: this);
      _starsController = AnimationController(vsync: this);
      _coinsController = AnimationController(vsync: this);
      _coinsAnimation = ConstantTween(0).animate(_coinsController);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/game');
      });
      return;
    }

    _session = extra['session'] as GameSession;
    isRecord = extra['isRecord'] as bool? ?? false;
    _xpEarned = extra['xpEarned'] as int? ?? 0;
    _totalXp = extra['totalXp'] as int? ?? 0;
    _level = extra['level'] as int? ?? 1;

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _starsController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200 * session.stars + 400),
    );

    _coinsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _coinsAnimation = IntTween(
      begin: 0,
      end: session.coinsEarned,
    ).animate(CurvedAnimation(
      parent: _coinsController,
      curve: Curves.easeOut,
    ));

    if (isRecord) {
      _confettiController = ConfettiController(
        duration: const Duration(seconds: 3),
      );
    }

    _startAnimations();
  }

  void _startAnimations() {
    _titleController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _starsController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _coinsController.forward();
    });

    if (_confettiController != null) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        _confettiController!.play();
        HapticService.recordBroken();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _starsController.dispose();
    _coinsController.dispose();
    _confettiController?.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final l10n = AppLocalizations.of(context)!;
    if (totalSeconds < 60) {
      return l10n.timeSec(totalSeconds);
    }
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return l10n.timeMinSec(minutes, seconds.toString().padLeft(2, '0'));
  }

  String _getTitle() {
    final l10n = AppLocalizations.of(context)!;
    if (isRecord) return l10n.newRecord;
    if (session.stars == 3) return l10n.greatResult;
    if (session.stars == 2) return l10n.goodResult;
    return l10n.keepPracticing;
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) {
      return const Scaffold(backgroundColor: AppColors.background);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      children: [
                        const SizedBox(height: 48),
                        _buildTitle(),
                        const SizedBox(height: 32),
                        _buildTime(),
                        const SizedBox(height: 32),
                        _buildStars(),
                        if (session.stars < 3) ...[
                          const SizedBox(height: 12),
                          _buildStarHint(),
                        ],
                        const SizedBox(height: 40),
                        _buildStatCards(),
                        const SizedBox(height: 20),
                        _buildXpProgress(),
                        const SizedBox(height: 32),
                        _buildButtons(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_confettiController != null)
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController!,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  maxBlastForce: 30,
                  minBlastForce: 10,
                  gravity: 0.2,
                  colors: const [
                    AppColors.primary,
                    AppColors.secondary,
                    AppColors.accent,
                    AppColors.success,
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _titleController,
        curve: Curves.easeIn,
      ),
      child: Text(
        _getTitle(),
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: isRecord ? 32 : 28,
          fontWeight: FontWeight.w800,
          color: isRecord ? AppColors.accent : AppColors.textPrimary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTime() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: isRecord
            ? Border.all(color: AppColors.accent.withValues(alpha: 0.5), width: 2)
            : null,
      ),
      child: Text(
        _formatTime(session.durationSeconds),
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStars() {
    return AnimatedBuilder(
      animation: _starsController,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final starDelay = index * 0.25;
            final starEnd = starDelay + 0.35;
            final progress = _starsController.value;

            final isEarned = index < session.stars;
            final double starScale;
            if (!isEarned) {
              starScale = 1.0;
            } else if (progress < starDelay) {
              starScale = 0.0;
            } else {
              starScale = Curves.elasticOut.transform(
                ((progress - starDelay) / (starEnd - starDelay))
                    .clamp(0.0, 1.0),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Transform.scale(
                scale: starScale,
                child: Icon(
                  isEarned ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 56,
                  color: isEarned ? AppColors.accent : AppColors.textSecondary,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildStarHint() {
    final l10n = AppLocalizations.of(context)!;
    final thresholds = AppConstants.starThresholds[session.gridSize];
    if (thresholds == null) return const SizedBox.shrink();

    final nextStars = session.stars + 1;
    final targetSeconds = nextStars == 3 ? thresholds[0] : thresholds[1];

    return Text(
      l10n.starHintNext(targetSeconds, nextStars),
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildStatCards() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: l10n.coinsEarned,
            child: AnimatedBuilder(
              animation: _coinsAnimation,
              builder: (context, _) => Text(
                '+${_coinsAnimation.value}',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: l10n.mistakes,
            child: Text(
              '${session.mistakesCount}',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: session.mistakesCount == 0
                    ? AppColors.success
                    : AppColors.error,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: l10n.personalRecord,
            child: Icon(
              isRecord ? Icons.emoji_events_rounded : Icons.remove_rounded,
              size: 28,
              color: isRecord ? AppColors.accent : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildXpProgress() {
    final l10n = AppLocalizations.of(context)!;
    final thresholds = AppConstants.xpThresholds.entries.toList();

    int currentThresholdXp = 0;
    int? nextThresholdXp;
    int? nextLevel;

    for (int i = 0; i < thresholds.length; i++) {
      if (thresholds[i].key <= _level) {
        currentThresholdXp = thresholds[i].value;
      }
      if (thresholds[i].key > _level) {
        nextLevel = thresholds[i].key;
        nextThresholdXp = thresholds[i].value;
        break;
      }
    }

    final isMaxLevel = nextLevel == null;
    final double progressFraction = isMaxLevel
        ? 1.0
        : ((_totalXp - currentThresholdXp) /
                (nextThresholdXp! - currentThresholdXp))
            .clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '+$_xpEarned XP',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                ),
              ),
              const Spacer(),
              Text(
                l10n.levelLabel(_level),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressFraction,
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_totalXp XP',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              if (!isMaxLevel)
                Text(
                  '$nextThresholdXp XP',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              context.go(
                '/game?size=${session.gridSize}&mode=${session.mode}',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(l10n.playAgain),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => context.go('/home'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.textSecondary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(l10n.home),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final Widget child;

  const _StatCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          child,
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
