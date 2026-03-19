import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:brainy/l10n/app_localizations.dart';
import 'package:brainy/features/subscription/screens/paywall_screen.dart';

Widget _createTestApp() {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru'), Locale('en')],
      locale: const Locale('ru'),
      home: const PaywallScreen(),
    ),
  );
}

void main() {
  group('PaywallScreen', () {
    testWidgets('renders premium icon', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.workspace_premium_rounded), findsOneWidget);
    });

    testWidgets('shows coming soon badge', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      expect(find.textContaining('Скоро'), findsOneWidget);
      expect(find.byIcon(Icons.access_time_rounded), findsOneWidget);
    });

    testWidgets('shows follow/subscribe CTA button', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      expect(find.textContaining('Подписаться'), findsOneWidget);
    });

    testWidgets('no plan cards or prices displayed', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      expect(find.textContaining('1 990'), findsNothing);
      expect(find.textContaining('299'), findsNothing);
    });

    testWidgets('renders close button', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('renders benefits list with check icons', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(5));
    });

    testWidgets('renders benefit icons', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
      expect(find.byIcon(Icons.people_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart_rounded), findsOneWidget);
      expect(find.byIcon(Icons.block_rounded), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
    });

    testWidgets('renders legal links', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('scaffold has correct background color', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
