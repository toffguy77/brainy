import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/features/league/providers/league_provider.dart';
import 'package:brainy/features/league/providers/game_services_provider.dart';
import 'package:brainy/features/league/screens/league_screen.dart';
import 'package:brainy/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:brainy/models/league.dart';

Widget _buildTestApp({required List<Override> overrides}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en')],
      home: LeagueScreen(),
    ),
  );
}

void main() {
  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    await Hive.openBox(AppConstants.userBox);
  });

  setUp(() async {
    if (Hive.isBoxOpen(AppConstants.userBox)) {
      await Hive.box(AppConstants.userBox).clear();
    }
  });

  group('LeagueScreen', () {
    testWidgets('shows connect card when not signed in', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        overrides: [
          isGameServicesSignedInProvider.overrideWith((ref) => false),
          weeklyXpProvider.overrideWithValue(100),
          currentLeagueProvider.overrideWithValue(LeagueTier.bronze),
          leagueStandingsProvider.overrideWith((ref) async {
            return [
              const LeaguePlayer(
                  name: 'Test', weeklyXp: 200),
              const LeaguePlayer(
                  name: 'You', weeklyXp: 100, isCurrentUser: true),
            ];
          }),
        ],
      ));

      await tester.pumpAndSettle();

      expect(find.text('Connect'), findsOneWidget);
      expect(find.text('Compete with real players!'), findsOneWidget);
    });

    testWidgets('hides connect card when signed in', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        overrides: [
          isGameServicesSignedInProvider.overrideWith((ref) => true),
          weeklyXpProvider.overrideWithValue(200),
          currentLeagueProvider.overrideWithValue(LeagueTier.silver),
          leagueStandingsProvider.overrideWith((ref) async {
            return [
              const LeaguePlayer(
                  name: 'RealPlayer', weeklyXp: 300),
              const LeaguePlayer(
                  name: 'Me', weeklyXp: 200, isCurrentUser: true),
            ];
          }),
        ],
      ));

      await tester.pumpAndSettle();

      expect(find.text('Connect'), findsNothing);
      expect(find.text('Full Ranking'), findsOneWidget);
    });

    testWidgets('shows leaderboard with player names', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        overrides: [
          isGameServicesSignedInProvider.overrideWith((ref) => true),
          weeklyXpProvider.overrideWithValue(250),
          currentLeagueProvider.overrideWithValue(LeagueTier.silver),
          leagueStandingsProvider.overrideWith((ref) async {
            return [
              const LeaguePlayer(
                  name: 'TopPlayer', weeklyXp: 500),
              const LeaguePlayer(
                  name: 'MiddlePlayer', weeklyXp: 300),
              const LeaguePlayer(
                  name: 'Me', weeklyXp: 250, isCurrentUser: true),
            ];
          }),
        ],
      ));

      await tester.pumpAndSettle();

      expect(find.text('TopPlayer'), findsOneWidget);
      expect(find.text('MiddlePlayer'), findsOneWidget);
      expect(find.text('You'), findsOneWidget);
      expect(find.text('500 XP'), findsOneWidget);
    });

    testWidgets('shows edit icon on current user row', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        overrides: [
          isGameServicesSignedInProvider.overrideWith((ref) => false),
          weeklyXpProvider.overrideWithValue(100),
          currentLeagueProvider.overrideWithValue(LeagueTier.bronze),
          leagueStandingsProvider.overrideWith((ref) async {
            return [
              const LeaguePlayer(
                  name: 'Other', weeklyXp: 200),
              const LeaguePlayer(
                  name: 'Me', weeklyXp: 100, isCurrentUser: true),
            ];
          }),
        ],
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    });

    testWidgets('tap on current user row opens edit name dialog',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(
        overrides: [
          isGameServicesSignedInProvider.overrideWith((ref) => true),
          playerNameProvider.overrideWith((ref) => 'OldName'),
          weeklyXpProvider.overrideWithValue(100),
          currentLeagueProvider.overrideWithValue(LeagueTier.bronze),
          leagueStandingsProvider.overrideWith((ref) async {
            return [
              const LeaguePlayer(
                  name: 'OldName', weeklyXp: 100, isCurrentUser: true),
            ];
          }),
        ],
      ));

      await tester.pumpAndSettle();

      // Scroll down to make the edit icon visible, then tap it
      await tester.scrollUntilVisible(
        find.byIcon(Icons.edit_rounded),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byIcon(Icons.edit_rounded));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('Edit name'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('edit name dialog saves custom name to Hive',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(
        overrides: [
          isGameServicesSignedInProvider.overrideWith((ref) => true),
          playerNameProvider.overrideWith((ref) => 'OldName'),
          weeklyXpProvider.overrideWithValue(100),
          currentLeagueProvider.overrideWithValue(LeagueTier.bronze),
          leagueStandingsProvider.overrideWith((ref) async {
            return [
              const LeaguePlayer(
                  name: 'OldName', weeklyXp: 100, isCurrentUser: true),
            ];
          }),
        ],
      ));

      await tester.pumpAndSettle();

      // Scroll and open dialog
      await tester.scrollUntilVisible(
        find.byIcon(Icons.edit_rounded),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byIcon(Icons.edit_rounded));
      await tester.pumpAndSettle();

      // Clear and type new name
      await tester.enterText(find.byType(TextField), 'NewPlayer');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify saved in Hive
      final box = Hive.box(AppConstants.userBox);
      expect(box.get(AppConstants.customPlayerNameKey), 'NewPlayer');
    });

    testWidgets('edit name dialog cancel does not save', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        overrides: [
          isGameServicesSignedInProvider.overrideWith((ref) => true),
          playerNameProvider.overrideWith((ref) => 'OldName'),
          weeklyXpProvider.overrideWithValue(100),
          currentLeagueProvider.overrideWithValue(LeagueTier.bronze),
          leagueStandingsProvider.overrideWith((ref) async {
            return [
              const LeaguePlayer(
                  name: 'OldName', weeklyXp: 100, isCurrentUser: true),
            ];
          }),
        ],
      ));

      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byIcon(Icons.edit_rounded),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byIcon(Icons.edit_rounded));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'ShouldNotSave');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      final box = Hive.box(AppConstants.userBox);
      expect(box.get(AppConstants.customPlayerNameKey), isNull);
    });

    testWidgets('shows loading state', (tester) async {
      // Use a Completer that never completes to keep it in loading state
      // without leaving pending timers.
      final completer = Completer<List<LeaguePlayer>>();
      addTearDown(() {
        if (!completer.isCompleted) completer.complete([]);
      });

      await tester.pumpWidget(_buildTestApp(
        overrides: [
          isGameServicesSignedInProvider.overrideWith((ref) => true),
          weeklyXpProvider.overrideWithValue(0),
          currentLeagueProvider.overrideWithValue(LeagueTier.bronze),
          leagueStandingsProvider.overrideWith((ref) => completer.future),
        ],
      ));

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
