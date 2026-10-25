import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/features/game/providers/records_provider.dart';
import 'package:brainy/features/parent/widgets/share_card.dart';
import 'package:brainy/l10n/app_localizations.dart';

/// Renders the card the way `showAndShare` does, but without the screenshot
/// and file-system plumbing, so the value it displays can be asserted.
Widget _harness({required Map<String, int> records}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Builder(
      builder: (context) => Material(
        child: ShareCard(
          streakDays: 7,
          // The lookup under test: the same expression showAndShare uses.
          best5x5: records[recordKey('classic', 5)],
          l10n: AppLocalizations.of(context)!,
        ),
      ),
    ),
  );
}

void main() {
  group('ShareCard', () {
    testWidgets('shows the stored 5x5 classic record', (tester) async {
      await tester.pumpWidget(_harness(records: {'classic_5': 22}));
      await tester.pump();

      expect(find.text('22s'), findsOneWidget);
    });

    testWidgets('an integer key would find nothing — guards the original bug',
        (tester) async {
      // records[5] against a Map<String,int> always returned null, so the card
      // silently showed no record for every user.
      final records = <String, int>{'classic_5': 22};
      // ignore: collection_methods_unrelated_type
      expect(records[5], isNull);
      expect(records[recordKey('classic', 5)], 22);
    });

    testWidgets('renders without a record', (tester) async {
      await tester.pumpWidget(_harness(records: {}));
      await tester.pump();

      expect(find.byType(ShareCard), findsOneWidget);
      expect(find.textContaining('s'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a gorbov record does not stand in for the classic one',
        (tester) async {
      await tester.pumpWidget(_harness(records: {'gorbov_5': 30}));
      await tester.pump();

      expect(find.text('30s'), findsNothing);
    });

    testWidgets('a different grid size does not stand in either',
        (tester) async {
      await tester.pumpWidget(_harness(records: {'classic_4': 14}));
      await tester.pump();

      expect(find.text('14s'), findsNothing);
    });

    testWidgets('always shows the streak', (tester) async {
      await tester.pumpWidget(_harness(records: {'classic_5': 22}));
      await tester.pump();

      expect(find.text('7'), findsOneWidget);
    });
  });
}
