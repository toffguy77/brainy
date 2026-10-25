import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/constants/game_modes.dart';
import 'package:brainy/features/character/data/characters_data.dart';
import 'package:brainy/features/game/providers/game_provider.dart';
import 'package:brainy/features/game/providers/session_completion_provider.dart';
import 'package:brainy/features/game/screens/game_screen.dart';
import 'package:brainy/l10n/app_localizations.dart';
import 'package:brainy/models/character.dart';
import 'package:brainy/models/game_state.dart';
import 'package:brainy/models/session.dart';
import 'package:brainy/models/user_progress.dart';

({int row, int col}) _find(GameState s, int ordinal) {
  for (var r = 0; r < s.gridSize; r++) {
    for (var c = 0; c < s.gridSize; c++) {
      if (s.grid[r][c].number == ordinal) return (row: r, col: c);
    }
  }
  throw StateError('no $ordinal');
}

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hive_finish_');
    Hive.init(dir.path);
    Hive.registerAdapter(GameSessionAdapter());
    Hive.registerAdapter(UserProgressAdapter());
    Hive.registerAdapter(CharacterDataAdapter());
    await Hive.openBox<GameSession>(AppConstants.sessionsBox);
    await Hive.openBox<int>(AppConstants.recordsBox);
    final user = await Hive.openBox(AppConstants.userBox);
    await user.put(AppConstants.soundEnabledKey, false);
    await user.put(AppConstants.hapticEnabledKey, false);
    await Hive.openBox<UserProgress>(AppConstants.progressBox)
        .then((b) => b.put(AppConstants.progressDataKey, UserProgress()));
    final chars = await Hive.openBox<CharacterData>(AppConstants.characterBox);
    for (final info in defaultCharacters) {
      await chars.put(info.id,
          CharacterData(id: info.id, nameRu: info.id, nameEn: info.id, isUnlocked: true));
    }
  });

  for (final mode in [GameModes.classic, GameModes.gorbov]) {
    testWidgets('finishing a $mode round opens the result screen', (tester) async {
      final router = GoRouter(initialLocation: '/game', routes: [
        GoRoute(
            path: '/game',
            builder: (_, __) => GameScreen(gridSize: 5, mode: mode)),
        GoRoute(
            path: '/result',
            builder: (_, __) => const Scaffold(body: Text('RESULT'))),
      ]);
      final container = ProviderContainer(overrides: [
        // A reminder call that never returns — what blocked the result
        // screen on a real device.
        sessionCompleterProvider.overrideWith((ref) => SessionCompleter(ref,
            rescheduleReminder: () => Completer<void>().future,
            onSideEffectError: (_, __) {})),
      ]);
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ru')],
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      final game = container.read(gameProvider.notifier);
      expect(container.read(gameProvider).status, GameStatus.playing);

      await tester.runAsync(() async {
        if (mode == GameModes.gorbov) {
          // Alternate white ascending and red descending.
          while (container.read(gameProvider).status == GameStatus.playing) {
            final s = container.read(gameProvider);
            final want = s.nextExpectedColor == 'white'
                ? s.nextWhiteNumber
                : s.nextRedNumber;
            late int r, c;
            for (var i = 0; i < 5; i++) {
              for (var j = 0; j < 5; j++) {
                final cell = s.grid[i][j];
                if (cell.color == s.nextExpectedColor && cell.number == want) {
                  r = i;
                  c = j;
                }
              }
            }
            game.tapCell(r, c);
          }
        } else {
          for (var n = 1; n <= 25; n++) {
            final p = _find(container.read(gameProvider), n);
            game.tapCell(p.row, p.col);
          }
        }
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      expect(container.read(gameProvider).status, GameStatus.finished);
      for (var i = 0; i < 10; i++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('RESULT'), findsOneWidget);
    });
  }
}
