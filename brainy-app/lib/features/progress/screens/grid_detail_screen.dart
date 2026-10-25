import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../constants/game_modes.dart';
import '../../game/game_mode_text.dart';
import '../providers/grid_stats_provider.dart';

class GridDetailScreen extends ConsumerStatefulWidget {
  final int gridSize;
  final String mode;

  const GridDetailScreen({
    super.key,
    required this.gridSize,
    this.mode = GameModes.classic,
  });

  @override
  ConsumerState<GridDetailScreen> createState() => _GridDetailScreenState();
}

class _GridDetailScreenState extends ConsumerState<GridDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = ref.watch(gridStatsProvider((mode: widget.mode, gridSize: widget.gridSize)));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${gameModeLabel(l10n, widget.mode)} · '
          '${l10n.gridDetailTitle(widget.gridSize)}',
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
          children: [
            const SizedBox(height: 8),
            _PeriodFilter(
              selected: stats.period,
              onChanged: (period) {
                ref
                    .read(gridStatsProvider((mode: widget.mode, gridSize: widget.gridSize)).notifier)
                    .setPeriod(period);
              },
              l10n: l10n,
            ),
            const SizedBox(height: 16),
            _ChartCard(stats: stats, l10n: l10n),
            const SizedBox(height: 16),
            if (!stats.isEmpty) ...[
              _ChartLegend(l10n: l10n),
              const SizedBox(height: 16),
              _StatsRow(stats: stats, l10n: l10n),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PeriodFilter extends StatelessWidget {
  final TimePeriod selected;
  final ValueChanged<TimePeriod> onChanged;
  final AppLocalizations l10n;

  const _PeriodFilter({
    required this.selected,
    required this.onChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final periods = [
      (TimePeriod.week, l10n.periodWeek),
      (TimePeriod.month, l10n.periodMonth),
      (TimePeriod.threeMonths, l10n.periodThreeMonths),
      (TimePeriod.year, l10n.periodYear),
      (TimePeriod.allTime, l10n.periodAll),
    ];

    return Row(
      children: periods.map((entry) {
        final isSelected = entry.$1 == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => onChanged(entry.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  entry.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final GridStatsState stats;
  final AppLocalizations l10n;

  const _ChartCard({required this.stats, required this.l10n});

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
            l10n.chartTimeLabel,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          if (stats.isEmpty)
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.gridDetailNoData(stats.gridSize),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.gridDetailPlayMore,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: _buildChart(),
            ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final allSpots = [...stats.dailyBestSpots, ...stats.allSessionSpots];
    if (allSpots.isEmpty) return const SizedBox.shrink();

    final minY = allSpots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = allSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final maxX = allSpots.map((s) => s.x).reduce((a, b) => a > b ? a : b);
    final yPadding = (maxY - minY) * 0.15;

    final recordY = stats.bestTimeAllTime > 0
        ? stats.bestTimeAllTime.toDouble()
        : null;

    return LineChart(
      duration: const Duration(milliseconds: 300),
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                if (value == meta.min || value == meta.max) {
                  return const SizedBox.shrink();
                }
                return Text(
                  '${value.toInt()}s',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                if (value == meta.min || value == meta.max) {
                  return const SizedBox.shrink();
                }
                return _buildBottomTitle(value, maxX);
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: (minY - yPadding).clamp(0, double.infinity),
        maxY: maxY + yPadding,
        minX: 0,
        maxX: maxX,
        extraLinesData: recordY != null
            ? ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: recordY,
                    color: AppColors.success.withValues(alpha: 0.6),
                    strokeWidth: 1.5,
                    dashArray: [6, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                      labelResolver: (_) => '${recordY.toInt()}s',
                    ),
                  ),
                ],
              )
            : null,
        lineBarsData: [
          // Scatter: all sessions as individual dots
          LineChartBarData(
            spots: stats.allSessionSpots,
            show: true,
            isCurved: false,
            color: Colors.transparent,
            barWidth: 0,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(
                radius: 3,
                color: AppColors.primary.withValues(alpha: 0.2),
                strokeWidth: 0,
              ),
            ),
          ),
          // Daily best line
          LineChartBarData(
            spots: stats.dailyBestSpots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.primary,
            barWidth: 2.5,
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
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTitle(double value, double maxX) {
    final now = DateTime.now();
    final daysAgo = (maxX - value).toInt();
    final date = now.subtract(Duration(days: daysAgo));

    String label;
    switch (stats.period) {
      case TimePeriod.week:
        label = DateFormat('E').format(date).substring(0, 2);
        break;
      case TimePeriod.month:
        label = '${date.day}';
        break;
      case TimePeriod.threeMonths:
      case TimePeriod.year:
      case TimePeriod.allTime:
        label = DateFormat('MMM').format(date).substring(0, 3);
        break;
    }

    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 9,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final AppLocalizations l10n;

  const _ChartLegend({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: AppColors.primary,
          label: l10n.legendDailyBest,
          isLine: true,
        ),
        const SizedBox(width: 20),
        _LegendItem(
          color: AppColors.primary.withValues(alpha: 0.3),
          label: l10n.legendAllAttempts,
          isLine: false,
        ),
        const SizedBox(width: 20),
        _LegendItem(
          color: AppColors.success,
          label: l10n.legendRecord,
          isDashed: true,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isLine;
  final bool isDashed;

  const _LegendItem({
    required this.color,
    required this.label,
    this.isLine = false,
    this.isDashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDashed)
          SizedBox(
            width: 16,
            height: 2,
            child: CustomPaint(painter: _DashedLinePainter(color: color)),
          )
        else if (isLine)
          Container(width: 16, height: 2, color: color)
        else
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    const dashWidth = 3.0;
    const dashSpace = 2.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + dashWidth, size.height / 2),
        paint,
      );
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatsRow extends StatelessWidget {
  final GridStatsState stats;
  final AppLocalizations l10n;

  const _StatsRow({required this.stats, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final bestStars = _starsForTime(stats.mode, stats.gridSize, stats.bestTime ?? 0);
    final avgStars =
        _starsForTime(stats.mode, stats.gridSize, stats.averageTime?.toInt() ?? 0);

    return Row(
      children: [
        _StatCard(
          label: l10n.statBestTime,
          value: '${stats.bestTime}s',
          color: AppColors.success,
          stars: bestStars,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: l10n.statAverageTime,
          value: '${stats.averageTime?.toStringAsFixed(1)}s',
          color: AppColors.accent,
          stars: avgStars,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: l10n.statTotalGames,
          value: '${stats.totalGames}',
          color: AppColors.primary,
        ),
      ],
    );
  }

  int _starsForTime(String mode, int gridSize, int seconds) {
    final thresholds = AppConstants.starThresholdsFor(mode, gridSize);
    if (thresholds == null || seconds <= 0) return 0;
    if (seconds <= thresholds[0]) return 3;
    if (seconds <= thresholds[1]) return 2;
    return 1;
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final int? stars;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    this.stars,
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
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            if (stars != null && stars! > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  return Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: i < stars!
                        ? AppColors.accent
                        : AppColors.textSecondary.withValues(alpha: 0.3),
                  );
                }),
              ),
            ],
            const SizedBox(height: 4),
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
