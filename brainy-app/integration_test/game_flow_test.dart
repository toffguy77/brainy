// On-device smoke test with the real plugins: a round must reach the result
// screen, and reminder scheduling must finish instead of hanging.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/constants/game_modes.dart';
import 'package:brainy/features/game/providers/game_provider.dart';
import 'package:brainy/features/game/screens/game_screen.dart';
import 'package:brainy/l10n/app_localizations.dart';
import 'package:brainy/models/character.dart';
import 'package:brainy/models/game_state.dart';
import 'package:brainy/models/session.dart';
import 'package:brainy/models/user_progress.dart';
import 'package:brainy/shared/services/notification_service.dart';

void _tapToEnd(GameNotifier game, GameState Function() read) {
  while (read().status == GameStatus.playing) {
    final s = read();
    for (final row in s.grid) {
      for (final cell in row) {
        final next = s.mode == GameModes.gorbov
            ? cell.color == s.nextExpectedColor &&
                cell.number ==
                    (s.nextExpectedColor == 'white'
                        ? s.nextWhiteNumber
                        : s.nextRedNumber)
            : cell.number == s.nextNumber;
        if (next && !cell.isFound) {
          game.tapCell(cell.row, cell.col);
          return _tapToEnd(game, read);
        }
      }
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hive.initFlutter();
    Hive.registerAdapter(GameSessionAdapter());
    Hive.registerAdapter(UserProgressAdapter());
    Hive.registerAdapter(CharacterDataAdapter());
    await Hive.openBox<GameSession>(AppConstants.sessionsBox);
    await Hive.openBox<int>(AppConstants.recordsBox);
    final user = await Hive.openBox(AppConstants.userBox);
    await Hive.openBox<CharacterData>(AppConstants.characterBox);
    await Hive.openBox<UserProgress>(AppConstants.progressBox);
    await user.put(AppConstants.userKeyOnboardingCompleted, true);
    await user.put(AppConstants.notificationsEnabledKey, true);
    await user.put(AppConstants.soundEnabledKey, false);
    await NotificationService.initialize();
  });

  testWidgets('reminder scheduling completes on iOS', (tester) async {
    Object? failure;
    await tester.runAsync(() async {
      try {
        await NotificationService.rescheduleFromStorage()
            .timeout(const Duration(seconds: 15));
      } catch (e) {
        failure = e;
      }
    });
    debugPrint('rescheduleFromStorage: ${failure ?? 'ok'}');
    expect(failure, isNull);
  });

  for (final mode in [GameModes.classic, GameModes.reverse, GameModes.gorbov, GameModes.letters]) {
    testWidgets('a $mode round reaches the result screen', (tester) async {
      final router = GoRouter(initialLocation: '/game', routes: [
        GoRoute(path: '/game', builder: (_, __) => GameScreen(gridSize: 5, mode: mode)),
        GoRoute(path: '/result', builder: (_, __) => const Scaffold(body: Text('RESULT'))),
        GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('HOME'))),
      ]);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ru'), Locale('en')],
        ),
      ));
      for (var i = 0; i < 40 && container.read(gameProvider).status != GameStatus.playing; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      _tapToEnd(container.read(gameProvider.notifier), () => container.read(gameProvider));
      for (var i = 0; i < 50 && find.text('RESULT').evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(find.text('HOME'), findsNothing, reason: 'completion failed');
      expect(find.text('RESULT'), findsOneWidget);
    });
  }
}
