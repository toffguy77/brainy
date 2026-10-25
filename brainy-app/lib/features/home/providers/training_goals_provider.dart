import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../../../models/session.dart';
import '../../game/providers/sessions_provider.dart';

/// Seconds of play on [now]'s calendar day, including mistake penalties —
/// the time the child actually spent at the table.
int todayPlaySeconds(Iterable<GameSession> sessions, DateTime now) => sessions
    .where((s) =>
        s.playedAt.year == now.year &&
        s.playedAt.month == now.month &&
        s.playedAt.day == now.day)
    .fold(0, (sum, s) => sum + s.durationSeconds);

/// The next larger grid size worth suggesting, or null. A suggestion needs
/// [AppConstants.sessionsForAdaptive] recent games at [currentSize] in [mode]
/// whose average meets the mode's adaptive target; it never leaves the
/// mode's own size list.
int? suggestNextGridSize({
  required String mode,
  required int currentSize,
  required Iterable<GameSession> sessions,
}) {
  final target = AppConstants.adaptiveTargetSeconds(mode, currentSize);
  if (target == null) return null;

  final recent = sessions
      .where((s) => s.mode == mode && s.gridSize == currentSize)
      .toList()
    ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
  if (recent.length < AppConstants.sessionsForAdaptive) return null;

  final window = recent.take(AppConstants.sessionsForAdaptive);
  final average =
      window.fold(0, (sum, s) => sum + s.durationSeconds) / window.length;
  if (average > target) return null;

  final sizes = AppConstants.gridSizesForMode(mode);
  final larger = sizes.where((s) => s > currentSize);
  return larger.isEmpty ? null : larger.first;
}

final todayPlaySecondsProvider = Provider<int>(
  (ref) => todayPlaySeconds(ref.watch(sessionsProvider), DateTime.now()),
);
