import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/user_progress.dart';
import '../../character/data/characters_data.dart';
import '../../game/providers/records_provider.dart';
import '../../game/providers/sessions_provider.dart';
import '../../game/providers/user_progress_provider.dart';
import '../providers/achievements_provider.dart';
import '../widgets/mode_filter.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final progress = ref.watch(userProgressProvider);
    final sessions = ref.watch(sessionsProvider);
    final records = ref.watch(recordsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          l10n.progressTitle,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _LevelCard(progress: progress, l10n: l10n),
            const SizedBox(height: 16),
            _StatsRow(
              progress: progress,
              totalGames: sessions.length,
              l10n: l10n,
            ),
            const SizedBox(height: 24),
            _NextGoalsSection(
              progress: progress,
              l10n: l10n,
              locale: locale,
            ),
            const SizedBox(height: 24),
            _AchievementsSection(l10n: l10n, ref: ref),
            const SizedBox(height: 24),
            _RecordsSection(records: records, l10n: l10n, ref: ref),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final UserProgress progress;
  final AppLocalizations l10n;

  const _LevelCard({required this.progress, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final thresholds = AppConstants.xpThresholds.entries.toList();
    final currentLevel = progress.level;
    final currentXp = progress.xp;

    // Find current and next level thresholds
    int currentThresholdXp = 0;
    int? nextLevel;
    int? nextThresholdXp;

    for (int i = 0; i < thresholds.length; i++) {
      if (thresholds[i].key <= currentLevel) {
        currentThresholdXp = thresholds[i].value;
      }
      if (thresholds[i].key > currentLevel) {
        nextLevel = thresholds[i].key;
        nextThresholdXp = thresholds[i].value;
        break;
      }
    }

    final bool isMaxLevel = nextLevel == null;
    final double progressFraction = isMaxLevel
        ? 1.0
        : ((currentXp - currentThresholdXp) /
                (nextThresholdXp! - currentThresholdXp))
            .clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.3),
            AppColors.secondary.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '$currentLevel',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.levelLabel(currentLevel),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isMaxLevel
                          ? l10n.progressMaxLevel
                          : l10n.progressXpToNextLevel(
                              math.max(0, nextThresholdXp! - currentXp),
                              nextLevel),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // XP progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressFraction,
              minHeight: 10,
              backgroundColor: AppColors.surface,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentXp XP',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              if (!isMaxLevel)
                Text(
                  '$nextThresholdXp XP',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final UserProgress progress;
  final int totalGames;
  final AppLocalizations l10n;

  const _StatsRow({
    required this.progress,
    required this.totalGames,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          icon: Icons.sports_esports_rounded,
          iconColor: AppColors.primary,
          value: '$totalGames',
          label: l10n.progressTotalGames,
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: Icons.star_rounded,
          iconColor: AppColors.accent,
          value: '${progress.xp}',
          label: l10n.progressTotalXp,
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: Icons.local_fire_department_rounded,
          iconColor: Colors.orange,
          value: '${progress.longestStreak}',
          label: l10n.progressBestStreak,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NextGoalsSection extends StatelessWidget {
  final UserProgress progress;
  final AppLocalizations l10n;
  final String locale;

  const _NextGoalsSection({
    required this.progress,
    required this.l10n,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final goals = _buildGoals();
    if (goals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.progressNextGoals,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...goals,
      ],
    );
  }

  List<Widget> _buildGoals() {
    final goals = <Widget>[];

    // Find next level goal
    for (final entry in AppConstants.xpThresholds.entries) {
      if (entry.key > progress.level) {
        // Find characters unlocked at this level
        final charAtLevel = defaultCharacters.where(
          (c) =>
              c.unlockType == UnlockType.level &&
              c.requiredLevel == entry.key,
        );

        final double levelProgress =
            (progress.xp / entry.value).clamp(0.0, 1.0);

        String description = l10n.progressGoalReachLevel(entry.key);
        if (charAtLevel.isNotEmpty) {
          description +=
              ' → ${l10n.progressGoalUnlock(charAtLevel.first.name(l10n))}';
        }

        goals.add(_GoalTile(
          icon: Icons.bolt_rounded,
          iconColor: AppColors.accent,
          title: description,
          progress: levelProgress,
          progressLabel: '${progress.xp} / ${entry.value} XP',
        ));
        break;
      }
    }

    // Find next streak goals from characters
    for (final char in defaultCharacters) {
      if (char.unlockType == UnlockType.streak &&
          char.requiredStreak != null &&
          progress.longestStreak < char.requiredStreak!) {
        final double streakProgress =
            (progress.longestStreak / char.requiredStreak!).clamp(0.0, 1.0);

        goals.add(_GoalTile(
          icon: Icons.local_fire_department_rounded,
          iconColor: Colors.orange,
          title:
              '${l10n.progressGoalStreak(char.requiredStreak!)} → ${l10n.progressGoalUnlock(char.name(l10n))}',
          progress: streakProgress,
          progressLabel:
              l10n.progressStreakProgress(
                  progress.longestStreak, char.requiredStreak!),
        ));
        break; // Only show the nearest streak goal
      }
    }

    return goals;
  }
}

class _GoalTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final double progress;
  final String progressLabel;

  const _GoalTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.progress,
    required this.progressLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            progressLabel,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  final AppLocalizations l10n;
  final WidgetRef ref;

  const _AchievementsSection({required this.l10n, required this.ref});

  @override
  Widget build(BuildContext context) {
    final achievements = ref.watch(achievementsStateProvider);
    final unlockedCount = achievements.where((a) => a.unlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.achievementsTitle,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.achievementsCount(unlockedCount, achievements.length),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: achievements
              .map((a) => _BadgeItem(
                    achievement: a,
                    l10n: l10n,
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final AchievementState achievement;
  final AppLocalizations l10n;

  const _BadgeItem({required this.achievement, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final def = achievement.def;
    final unlocked = achievement.unlocked;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: SizedBox(
        // Wide enough for one-word titles like «Рекордсмен» at 10 pt.
        width: 72,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: unlocked
                  ? Image.asset(
                      def.assetPath,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _badgePlaceholder(),
                    )
                  : Opacity(
                      opacity: 0.4,
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.matrix(<double>[
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                        child: Image.asset(
                          def.assetPath,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _badgePlaceholder(),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              def.title(l10n),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: unlocked
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badgePlaceholder({double size = 52}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.emoji_events_rounded,
        color: AppColors.textSecondary,
        size: size * 0.5,
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final def = achievement.def;
    final unlocked = achievement.unlocked;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            unlocked
                ? Image.asset(
                    def.assetPath,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _badgePlaceholder(size: 80),
                  )
                : Opacity(
                    opacity: 0.4,
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0, 0, 0, 1, 0,
                      ]),
                      child: Image.asset(
                        def.assetPath,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _badgePlaceholder(size: 80),
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
            Text(
              def.title(l10n),
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: unlocked
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              def.description(l10n),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _RecordsSection extends StatelessWidget {
  final Map<String, int> records;
  final AppLocalizations l10n;
  final WidgetRef ref;

  const _RecordsSection({
    required this.records,
    required this.l10n,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(statsModeProvider);
    final hasRecords = AppConstants.gridSizesForMode(mode)
        .any((size) => records.containsKey(recordKey(mode, size)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.progressRecords,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        const ModeFilterChips(),
        const SizedBox(height: 12),
        if (!hasRecords)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              l10n.progressNoRecords,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final size in AppConstants.gridSizesForMode(mode))
                _RecordChip(
                  gridSize: size,
                  seconds: records[recordKey(mode, size)],
                  onTap: () => context
                      .push('/progress/grid-detail?size=$size&mode=$mode'),
                ),
            ],
          ),
      ],
    );
  }
}

class _RecordChip extends StatelessWidget {
  final int gridSize;
  final int? seconds;
  final VoidCallback? onTap;

  const _RecordChip({
    required this.gridSize,
    required this.seconds,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasRecord = seconds != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: hasRecord
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: hasRecord
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                Text(
                  '$gridSize×$gridSize',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: hasRecord
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasRecord
                      ? AppLocalizations.of(context)!.shareSeconds(seconds!)
                      : '—',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasRecord
                        ? AppColors.secondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: hasRecord
                  ? AppColors.textSecondary
                  : AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
