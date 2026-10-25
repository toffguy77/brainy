import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/features/game/providers/game_provider.dart';
import 'package:brainy/features/game/screens/game_screen.dart';
import 'package:brainy/features/game/widgets/schulte_grid.dart';
import 'package:brainy/l10n/app_localizations.dart';
import 'package:brainy/models/game_state.dart';

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hive_pause_');
    Hive.init(dir.path);
    final box = await Hive.openBox(AppConstants.userBox);
    await box.put(AppConstants.soundEnabledKey, false);
    await box.put(AppConstants.hapticEnabledKey, false);
  });

  testWidgets('leaving the app pauses the game and hides the grid',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en'), Locale('ru')],
        home: GameScreen(gridSize: 3),
      ),
    ));
    await tester.pump(); // post-frame initGame
    await tester.pump(const Duration(seconds: 3)); // countdown
    await tester.pump(const Duration(seconds: 2));
    expect(container.read(gameProvider).status, GameStatus.playing);
    final elapsed = container.read(gameProvider).elapsedSeconds;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump(const Duration(seconds: 5));

    expect(container.read(gameProvider).status, GameStatus.paused);
    expect(container.read(gameProvider).elapsedSeconds, elapsed);
    expect(find.byKey(const Key('pauseOverlay')), findsOneWidget);
    expect(find.text('Paused'), findsOneWidget);
    // The grid is covered: no hit test reaches it.
    expect(find.byType(SchulteGrid).hitTestable(), findsNothing);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.tap(find.byKey(const Key('pauseOverlay')));
    await tester.pump();
    expect(container.read(gameProvider).status, GameStatus.playing);
    expect(find.byKey(const Key('pauseOverlay')), findsNothing);

    container.read(gameProvider.notifier).resetGame();
  });
}
