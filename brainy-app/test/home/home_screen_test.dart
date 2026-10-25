import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/constants/game_modes.dart';
import 'package:brainy/features/character/data/characters_data.dart';
import 'package:brainy/features/home/screens/home_screen.dart';
import 'package:brainy/l10n/app_localizations.dart';
import 'package:brainy/models/character.dart';
import 'package:brainy/models/session.dart';
import 'package:brainy/models/user_progress.dart';

Future<void> _pumpHome(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size * 3;
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
      home: HomeScreen(),
    ),
  ));
  await tester.pump();
}

/// Hive I/O never completes inside testWidgets' fake-async zone, so data is
/// seeded from setUp, which runs outside it.
Future<void> _addSessions(String mode, int size, int seconds, int count) async {
  final box = Hive.box<GameSession>(AppConstants.sessionsBox);
  final now = DateTime.now();
  for (var i = 0; i < count; i++) {
    final s = GameSession(
      id: 's$mode$size$i',
      playedAt: now.subtract(Duration(minutes: i)),
      gridSize: size,
      durationSeconds: seconds,
      mistakesCount: 0,
      isPersonalRecord: false,
      mode: mode,
      coinsEarned: 10,
    );
    await box.put(s.id, s);
  }
}

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hive_home_');
    Hive.init(dir.path);
    Hive.registerAdapter(GameSessionAdapter());
    Hive.registerAdapter(UserProgressAdapter());
    Hive.registerAdapter(CharacterDataAdapter());
    await Hive.openBox<GameSession>(AppConstants.sessionsBox);
    await Hive.openBox(AppConstants.userBox);
    await Hive.openBox<UserProgress>(AppConstants.progressBox);
    await Hive.openBox<CharacterData>(AppConstants.characterBox);
  });

  setUp(() async {
    await Hive.box<GameSession>(AppConstants.sessionsBox).clear();
    await Hive.box(AppConstants.userBox).clear();
    await Hive.box<UserProgress>(AppConstants.progressBox).clear();
    await Hive.box<CharacterData>(AppConstants.characterBox).clear();
    await Hive.box<UserProgress>(AppConstants.progressBox)
        .put(AppConstants.progressDataKey, UserProgress(lastSelectedGridSize: 4));
    // Seeded so CharacterNotifier.build does not write from inside the
    // fake-async zone; those writes never finish and block Hive's queue.
    for (final info in defaultCharacters) {
      await Hive.box<CharacterData>(AppConstants.characterBox).put(
          info.id,
          CharacterData(id: info.id, nameRu: info.id, nameEn: info.id,
              isUnlocked: info.unlockType == UnlockType.free));
    }
  });

  // No Hive.close(): writes the widgets start inside the fake-async zone never
  // complete, and closing would wait on them forever.

  // iPhone SE (2nd/3rd gen) is the smallest device the iOS 17.6 target runs on.
  testWidgets('fits an iPhone SE screen without overflow', (tester) async {
    await _pumpHome(tester, size: const Size(375, 667));
    expect(tester.takeException(), isNull);
  });

  group('daily goal', () {
    group('in progress', () {
      setUp(() => _addSessions(GameModes.classic, 4, 90, 2)); // 3 minutes
      testWidgets('shows today against the goal', (tester) async {
        await _pumpHome(tester);
        expect(find.text('Today: 3 of 10 min'), findsOneWidget);
      });
    });

    group('met', () {
      setUp(() => _addSessions(GameModes.classic, 9, 200, 3)); // 10 minutes
      testWidgets('is celebrated', (tester) async {
        await _pumpHome(tester);
        expect(find.text('Daily goal reached!'), findsOneWidget);
      });
    });
  });

  group('adaptive suggestion', () {
    setUp(() => _addSessions(GameModes.classic, 4,
        AppConstants.adaptiveTargetSeconds(GameModes.classic, 4)!,
        AppConstants.sessionsForAdaptive));

    testWidgets('fast recent games offer the next size; tapping selects it',
        (tester) async {
      await _pumpHome(tester);
      expect(find.text('Ready for 5×5? Give it a go!'), findsOneWidget);

      // The tap persists the size; run it in the real zone so Hive completes.
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('adaptiveSuggestion')));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
      expect(find.byKey(const Key('adaptiveSuggestion')), findsNothing);
      expect(
          Hive.box<UserProgress>(AppConstants.progressBox)
              .get(AppConstants.progressDataKey)!
              .lastSelectedGridSize,
          5);
    });

    group('with a parent-fixed size', () {
      setUp(() async {
        final box = Hive.box(AppConstants.userBox);
        await box.put(
            AppConstants.parentGridSizeModeKey, AppConstants.gridSizeModeFixed);
        await box.put(AppConstants.parentFixedGridSizeKey, 4);
      });
      testWidgets('is not offered', (tester) async {
        await _pumpHome(tester);
        expect(find.byKey(const Key('adaptiveSuggestion')), findsNothing);
      });
    });
  });

  group('parent fixed 9x9', () {
    setUp(() async {
      final box = Hive.box(AppConstants.userBox);
      await box.put(
          AppConstants.parentGridSizeModeKey, AppConstants.gridSizeModeFixed);
      await box.put(AppConstants.parentFixedGridSizeKey, 9);
    });

    testWidgets('shows as 5x5 once letters is selected', (tester) async {
      await _pumpHome(tester);
      expect(find.text('9×9'), findsOneWidget);

      await tester.runAsync(() async {
        await tester.tap(find.text('Letters'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
      expect(find.text('5×5'), findsOneWidget);
      expect(find.text('9×9'), findsNothing);
      expect(Hive.box(AppConstants.userBox).get(AppConstants.lastSelectedModeKey),
          GameModes.letters);
    });
  });
}
