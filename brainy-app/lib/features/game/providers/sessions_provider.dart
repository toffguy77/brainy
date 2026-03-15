import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/session.dart';

class SessionsNotifier extends Notifier<List<GameSession>> {
  static const String _boxName = 'sessions';

  @override
  List<GameSession> build() {
    final box = Hive.box<GameSession>(_boxName);
    return box.values.toList()
      ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
  }

  Future<void> saveSession(GameSession session) async {
    final box = Hive.box<GameSession>(_boxName);
    await box.put(session.id, session);
    state = [session, ...state];
  }

  List<GameSession> getSessionsForPeriod(DateTime from, DateTime to) {
    return state
        .where((s) => s.playedAt.isAfter(from) && s.playedAt.isBefore(to))
        .toList();
  }

  List<GameSession> getLast7Days() {
    final from = DateTime.now().subtract(const Duration(days: 7));
    return getSessionsForPeriod(from, DateTime.now());
  }
}

final sessionsProvider =
    NotifierProvider<SessionsNotifier, List<GameSession>>(SessionsNotifier.new);
