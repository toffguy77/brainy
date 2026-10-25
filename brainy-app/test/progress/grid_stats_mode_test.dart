import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/constants/game_modes.dart';
import 'package:brainy/features/parent/screens/parent_dashboard_screen.dart';
import 'package:brainy/features/progress/providers/grid_stats_provider.dart';
import 'package:brainy/l10n/app_localizations.dart';
import 'package:brainy/models/session.dart';
import 'package:brainy/models/user_progress.dart';

GameSession _s(String id, String mode, int size, int seconds) => GameSession(
      id: id,
      playedAt: DateTime.now().subtract(Duration(hours: id.hashCode % 48)),
      gridSize: size,
      durationSeconds: seconds,
      mistakesCount: 0,
      isPersonalRecord: false,
      mode: mode,
      coinsEarned: 10,
    );

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hive_stats_');
    Hive.init(dir.path);
    Hive.registerAdapter(GameSessionAdapter());
    Hive.registerAdapter(UserProgressAdapter());
    await Hive.openBox<GameSession>(AppConstants.sessionsBox);
    await Hive.openBox<int>(AppConstants.recordsBox);
    await Hive.openBox(AppConstants.userBox);
    await Hive.openBox<UserProgress>(AppConstants.progressBox);
  });

  setUp(() async {
    final sessions = Hive.box<GameSession>(AppConstants.sessionsBox);
    await sessions.clear();
    for (final s in [
      _s('c1', GameModes.classic, 5, 30),
      _s('c2', GameModes.classic, 5, 40),
      _s('r1', GameModes.reverse, 5, 50),
      _s('l1', GameModes.letters, 4, 60),
    ]) {
      await sessions.put(s.id, s);
    }
    final records = Hive.box<int>(AppConstants.recordsBox);
    await records.clear();
    await records.put('classic_5', 30);
    await records.put('reverse_5', 50);
    await records.put('letters_4', 60);
    await Hive.box<UserProgress>(AppConstants.progressBox)
        .put(AppConstants.progressDataKey, UserProgress());
  });

  test('stats count only the requested mode and use its record', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final classic = container
        .read(gridStatsProvider((mode: GameModes.classic, gridSize: 5)));
    expect(classic.totalGames, 2);
    expect(classic.bestTimeAllTime, 30);

    final reverse = container
        .read(gridStatsProvider((mode: GameModes.reverse, gridSize: 5)));
    expect(reverse.totalGames, 1);
    expect(reverse.bestTimeAllTime, 50);

    final gorbov = container
        .read(gridStatsProvider((mode: GameModes.gorbov, gridSize: 5)));
    expect(gorbov.isEmpty, isTrue);
  });

  testWidgets('dashboard switches best results by mode and badges sessions',
      (tester) async {
    tester.view.physicalSize = const Size(1170, 4000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en'), Locale('ru')],
        home: ParentDashboardScreen(),
      ),
    ));
    await tester.pump();

    expect(find.text('Best: 30s'), findsOneWidget);
    expect(find.text('Best: 60s'), findsNothing);
    expect(find.text('Rev'), findsOneWidget);
    expect(find.text('ABC'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('statsMode-letters')));
    await tester.pump();
    expect(find.text('Best: 60s'), findsOneWidget);
    expect(find.text('Best: 30s'), findsNothing);
    // Letters only has 3x3..5x5 tables.
    expect(find.text('9×9'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
