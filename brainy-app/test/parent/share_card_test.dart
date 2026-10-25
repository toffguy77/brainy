import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/features/parent/widgets/share_card.dart';
import 'package:brainy/l10n/app_localizations.dart';
import 'package:brainy/models/user_progress.dart';

/// Builds the card through [ShareCard.fromState] — the same factory
/// `showAndShare` uses — so reverting the record lookup fails these tests.
Widget _harness({
  required Map<String, int> records,
  int streak = 7,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('ru')],
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: Material(
          child: Center(
            child: ShareCard.fromState(
              progress: UserProgress(currentStreak: streak),
              records: records,
              l10n: AppLocalizations.of(context)!,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the stored 5x5 classic record with its label',
      (tester) async {
    await tester.pumpWidget(_harness(records: {'classic_5': 22}));
    expect(find.text('22s'), findsOneWidget);
    expect(find.text('Best 5×5 result'), findsOneWidget);
  });

  testWidgets('a fresh install shows the streak and no record slot',
      (tester) async {
    await tester.pumpWidget(_harness(records: {}, streak: 0));
    expect(find.text('Best 5×5 result'), findsNothing);
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('Just getting started!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('records of other modes or sizes do not stand in', (tester) async {
    await tester.pumpWidget(
        _harness(records: {'gorbov_5': 30, 'reverse_5': 25, 'classic_4': 14}));
    expect(find.text('Best 5×5 result'), findsNothing);
    expect(find.text('30s'), findsNothing);
    expect(find.text('14s'), findsNothing);
  });

  testWidgets('Russian uses its own seconds unit and plural', (tester) async {
    await tester.pumpWidget(_harness(
        records: {'classic_5': 22}, streak: 3, locale: const Locale('ru')));
    expect(find.text('22 с'), findsOneWidget);
    expect(find.text('3 дня тренировок подряд!'), findsOneWidget);
  });

  testWidgets('long values and large text do not overflow', (tester) async {
    await tester.pumpWidget(_harness(
      records: {'classic_5': 9999},
      streak: 365,
      locale: const Locale('ru'),
      textScale: 1.3,
    ));
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(ShareCard)).width, 340);
  });
}
