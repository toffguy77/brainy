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

// The rename-dialog tests live in their own file.
//
// WORKAROUND, not a fix. Opening this dialog three times inside a single test
// file deadlocks the test isolate: the first six tests pass in milliseconds,
// the seventh wedges so hard that `--timeout` never fires and flutter_tools
// dies with "Bad state: Cannot close sink while adding stream"
// (flutter_platform.dart:766). Every test passes on its own, and two dialog
// tests coexist fine — the third is what breaks it.
//
// Ruled out, each verified by a full run: disposing the TextEditingController
// via a StatefulWidget (a real leak, fixed and kept); awaiting the Hive write
// (a real race, fixed and kept); replacing pumpAndSettle and scrollUntilVisible
// with bounded pumps; closing the dialog in every test; removing
// `autofocus: true` from the field; releasing focus immediately after
// enterText while the field is still mounted.
//
// Splitting the file isolates the leak into a fresh isolate rather than
// stopping it. If the underlying cause is ever found, these tests belong back
// in league_screen_test.dart.

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

List<Override> _overrides() => [
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
    ];

/// Open the rename dialog on the current user's row.
///
/// Never use `pumpAndSettle` while the dialog is open: the focused field's
/// blinking cursor schedules frames forever, so it would spin until the
/// 10-minute test timeout. Bounded pumps cover the route transition.
Future<void> _openEditNameDialog(WidgetTester tester) async {
  final editIcon = find.byIcon(Icons.edit_rounded);
  expect(editIcon, findsOneWidget);
  await tester.ensureVisible(editIcon);
  await tester.pump();
  await tester.tap(editIcon);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

/// Type into the field and release focus while it is still mounted, closing
/// the platform text-input connection before the dialog pops.
Future<void> _enterName(WidgetTester tester, String name) async {
  await tester.enterText(find.byType(TextField), name);
  await tester.pump();
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
}

Future<void> _pumpDialogDismissal(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
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

  group('LeagueScreen rename dialog', () {
    testWidgets('opens on tapping the current user row', (tester) async {
      await tester.pumpWidget(_buildTestApp(overrides: _overrides()));
      await tester.pumpAndSettle();

      await _openEditNameDialog(tester);

      expect(find.text('Edit name'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await _pumpDialogDismissal(tester);
    });

    testWidgets('saves the custom name to Hive', (tester) async {
      await tester.pumpWidget(_buildTestApp(overrides: _overrides()));
      await tester.pumpAndSettle();

      await _openEditNameDialog(tester);
      await _enterName(tester, 'NewPlayer');
      // The save awaits a Hive write, which never completes inside the
      // fake-async zone: run the tap in the real zone.
      await tester.runAsync(() async {
        await tester.tap(find.text('Save'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await _pumpDialogDismissal(tester);

      final box = Hive.box(AppConstants.userBox);
      expect(box.get(AppConstants.customPlayerNameKey), 'NewPlayer');
    });
  });
}
