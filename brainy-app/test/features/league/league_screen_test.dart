import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
