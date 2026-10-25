import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../game/providers/records_provider.dart' show recordKey, recordsProvider;
import '../../game/providers/sessions_provider.dart';
import '../../game/providers/user_progress_provider.dart';
import '../widgets/share_card.dart';
import '../../../constants/game_modes.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final progress = ref.watch(userProgressProvider);
    final sessions = ref.watch(sessionsProvider);
    final records = ref.watch(recordsProvider);

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekSessions = sessions
        .where((s) => s.playedAt.isAfter(weekAgo))
        .toList();

    final avgTime = weekSessions.isEmpty
        ? 0
        : (weekSessions.fold<int>(
                0, (sum, s) => sum + s.durationSeconds) ~/
            weekSessions.length);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          l10n.parentTitle,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.textPrimary),
            onPressed: () => ShareCard.showAndShare(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded,
                color: AppColors.textPrimary),
            onPressed: () => context.go('/parent/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _WeekSummaryCard(
            streak: progress.currentStreak,
            avgTime: avgTime,
            sessionCount: weekSessions.length,
            l10n: l10n,
          ),
          const SizedBox(height: 16),
          _ProgressChart(sessions: sessions, l10n: l10n),
          const SizedBox(height: 16),
          _BestResultsCard(records: records, l10n: l10n),
          const SizedBox(height: 16),
          _RecentSessionsList(sessions: sessions, l10n: l10n),
        ],
      ),
    );
  }
}

class _WeekSummaryCard extends StatelessWidget {
  final int streak;
  final int avgTime;
  final int sessionCount;
  final AppLocalizations l10n;

  const _WeekSummaryCard({
    required this.streak,
    required this.avgTime,
    required this.sessionCount,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.parentThisWeek,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: Colors.orange,
                  value: '$streak',
                  label: l10n.parentDays,
                  subtitle: l10n.parentStreak,
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.timer_rounded,
                  iconColor: AppColors.secondary,
                  value: '$avgTime',
                  label: l10n.parentSec,
                  subtitle: l10n.parentAvgTime,
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.videogame_asset_rounded,
                  iconColor: AppColors.primary,
                  value: '$sessionCount',
                  label: '',
                  subtitle: l10n.parentSessions,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String subtitle;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProgressChart extends StatelessWidget {
  final List sessions;
  final AppLocalizations l10n;

  const _ProgressChart({required this.sessions, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 14));

    // Filter 5×5 sessions from the last 14 days and group by day
    final filtered = sessions.where((s) =>
        s.gridSize == 5 &&
        s.playedAt.isAfter(twoWeeksAgo));

    final dailyBest = <int, int>{}; // dayIndex -> best time
    for (final s in filtered) {
      final dayIndex = now.difference(s.playedAt).inDays;
      final existing = dailyBest[dayIndex];
      if (existing == null || s.durationSeconds < existing) {
        dailyBest[dayIndex] = s.durationSeconds;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.parentProgressChart,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (dailyBest.isEmpty)
            SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  l10n.parentNoChartData,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: 3,
                        getTitlesWidget: (value, meta) {
                          final date = now.subtract(
                              Duration(days: 13 - value.toInt()));
                          return Text(
                            DateFormat('d/M').format(date),
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 9,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: dailyBest.entries.map((e) {
                        final x = 13 - e.key.toDouble();
                        return FlSpot(x, e.value.toDouble());
                      }).toList()
                        ..sort((a, b) => a.x.compareTo(b.x)),
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: AppColors.surface,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  minX: 0,
                  maxX: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BestResultsCard extends StatelessWidget {
  final Map<String, int> records;
  final AppLocalizations l10n;
  const _BestResultsCard({required this.records, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.parentBestResults,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.allGridSizes.map((size) {
              final record = records[recordKey(GameModes.classic, size)];
              return _RecordChip(
                label: '$size×$size',
                value: record != null
                    ? l10n.parentBestTime(record)
                    : l10n.parentNoRecord,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RecordChip extends StatelessWidget {
  final String label;
  final String value;

  const _RecordChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentSessionsList extends StatelessWidget {
  final List sessions;
  final AppLocalizations l10n;

  const _RecentSessionsList({required this.sessions, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final recent = sessions.take(10).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.parentRecentSessions,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  l10n.parentNoSessions,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ...recent.map((s) => _SessionRow(session: s)),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final dynamic session;

  const _SessionRow({required this.session});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd.MM').format(session.playedAt);
    final stars = session.stars;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              dateStr,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${session.gridSize}×${session.gridSize}',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          if (session.mode == GameModes.gorbov)
            Container(
              margin: const EdgeInsets.only(left: 4),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFE17055).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '\u0413',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE17055),
                ),
              ),
            ),
          const SizedBox(width: 12),
          Text(
            '${session.durationSeconds}s',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              return Icon(
                Icons.star_rounded,
                size: 16,
                color: i < stars ? AppColors.accent : AppColors.textSecondary.withValues(alpha: 0.3),
              );
            }),
          ),
          if (session.isPersonalRecord) ...[
            const SizedBox(width: 6),
            const Icon(Icons.emoji_events_rounded,
                size: 16, color: AppColors.accent),
          ],
        ],
      ),
    );
  }
}
