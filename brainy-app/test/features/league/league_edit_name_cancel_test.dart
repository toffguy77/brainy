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

// Third rename-dialog test, isolated in its own file.
//
// WORKAROUND, not a fix. See the header of league_edit_name_test.dart for the
// full investigation: a third dialog-opening test in the same file deadlocks
// the isolate. Two coexist; three do not. Splitting keeps each file under that
// threshold. If the underlying cause is found, merge these files back.

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

  testWidgets('LeagueScreen rename dialog cancel does not save',
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

    final editIcon = find.byIcon(Icons.edit_rounded);
    expect(editIcon, findsOneWidget);
    await tester.ensureVisible(editIcon);
    await tester.pump();
    await tester.tap(editIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField), 'ShouldNotSave');
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final box = Hive.box(AppConstants.userBox);
    expect(box.get(AppConstants.customPlayerNameKey), isNull);
  });
}
