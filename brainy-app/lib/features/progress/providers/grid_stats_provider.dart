import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../game/providers/records_provider.dart';
import '../../game/providers/sessions_provider.dart';
import '../../../models/session.dart';

enum TimePeriod { week, month, threeMonths, year, allTime }

/// Which table the stats are for: a mode and a grid size.
typedef GridStatsKey = ({String mode, int gridSize});

class GridStatsState {
  final String mode;
  final int gridSize;
  final TimePeriod period;
  final List<FlSpot> dailyBestSpots;
  final List<FlSpot> allSessionSpots;
  final int? bestTime;
  final double? averageTime;
  final int totalGames;
  final int bestTimeAllTime;

  const GridStatsState({
    required this.mode,
    required this.gridSize,
    required this.period,
    required this.dailyBestSpots,
    required this.allSessionSpots,
    this.bestTime,
    this.averageTime,
    required this.totalGames,
    required this.bestTimeAllTime,
  });

  bool get isEmpty => totalGames == 0;
}

class GridStatsNotifier extends FamilyNotifier<GridStatsState, GridStatsKey> {
  TimePeriod _period = TimePeriod.week;

  @override
  GridStatsState build(GridStatsKey key) {
    final sessions = ref.watch(sessionsProvider);
    final records = ref.watch(recordsProvider);
    return _compute(key.mode, key.gridSize, sessions, records);
  }

  void setPeriod(TimePeriod period) {
    _period = period;
    ref.invalidateSelf();
  }

  GridStatsState _compute(
    String mode,
    int gridSize,
    List<GameSession> allSessions,
    Map<String, int> records,
  ) {
    final bestTimeAllTime = records[recordKey(mode, gridSize)] ?? 0;

    final gridSessions = allSessions
        .where((s) => s.gridSize == gridSize && s.mode == mode)
        .toList();

    // Determine period and check if week has data
    var period = _period;
    if (period == TimePeriod.week) {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final hasWeekData = gridSessions.any((s) => s.playedAt.isAfter(weekAgo));
      if (!hasWeekData) period = TimePeriod.allTime;
    }

    // Filter by period
    final now = DateTime.now();
    final startDate = _periodStart(period, now);
    final filtered = startDate == null
        ? gridSessions
        : gridSessions.where((s) => s.playedAt.isAfter(startDate)).toList();

    if (filtered.isEmpty) {
      return GridStatsState(
        mode: mode,
        gridSize: gridSize,
        period: period,
        dailyBestSpots: [],
        allSessionSpots: [],
        totalGames: 0,
        bestTimeAllTime: bestTimeAllTime,
      );
    }

    // Determine date range for X axis
    final earliest = startDate ?? filtered.last.playedAt;
    final totalDays = now.difference(earliest).inDays + 1;

    // Group by day -> daily best
    final dailyBest = <int, int>{};
    final allSpots = <FlSpot>[];

    for (final s in filtered) {
      final dayIndex = now.difference(s.playedAt).inDays;
      final x = (totalDays - 1 - dayIndex).toDouble();
      allSpots.add(FlSpot(x, s.durationSeconds.toDouble()));

      final existing = dailyBest[dayIndex];
      if (existing == null || s.durationSeconds < existing) {
        dailyBest[dayIndex] = s.durationSeconds;
      }
    }

    final dailyBestSpots = dailyBest.entries.map((e) {
      final x = (totalDays - 1 - e.key).toDouble();
      return FlSpot(x, e.value.toDouble());
    }).toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    // Stats
    final bestTime =
        filtered.map((s) => s.durationSeconds).reduce((a, b) => a < b ? a : b);
    final avgTime =
        filtered.map((s) => s.durationSeconds).reduce((a, b) => a + b) /
            filtered.length;

    return GridStatsState(
      mode: mode,
      gridSize: gridSize,
      period: period,
      dailyBestSpots: dailyBestSpots,
      allSessionSpots: allSpots,
      bestTime: bestTime,
      averageTime: avgTime,
      totalGames: filtered.length,
      bestTimeAllTime: bestTimeAllTime,
    );
  }

  DateTime? _periodStart(TimePeriod period, DateTime now) {
    switch (period) {
      case TimePeriod.week:
        return now.subtract(const Duration(days: 7));
      case TimePeriod.month:
        return now.subtract(const Duration(days: 30));
      case TimePeriod.threeMonths:
        return now.subtract(const Duration(days: 90));
      case TimePeriod.year:
        return now.subtract(const Duration(days: 365));
      case TimePeriod.allTime:
        return null;
    }
  }
}

final gridStatsProvider =
    NotifierProvider.family<GridStatsNotifier, GridStatsState, GridStatsKey>(
        GridStatsNotifier.new);
