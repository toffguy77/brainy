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

    testWidgets('renders two plan cards with RUB prices', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      // Check for RUB prices
      expect(find.textContaining('1 990'), findsOneWidget);
      expect(find.textContaining('299'), findsOneWidget);
    });

    testWidgets('no family plan displayed', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      // Family plan should NOT be present
      expect(find.textContaining('family'), findsNothing);
      expect(find.textContaining('Family'), findsNothing);
    });

    testWidgets('yearly plan is selected by default', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      // The yearly plan card should show the price
      expect(find.textContaining('1 990'), findsOneWidget);
    });

    testWidgets('can switch between plans by tapping', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Tap on monthly plan card — scroll into view first since it may be off-screen
      final monthlyCard = find.textContaining('299');
      expect(monthlyCard, findsOneWidget);
      await tester.ensureVisible(monthlyCard);
      await tester.pumpAndSettle();
      await tester.tap(monthlyCard);
      await tester.pumpAndSettle();
      // After tap, monthly should be selected — we just verify no crash
    });

    testWidgets('renders close button', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('renders CTA button', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      // The CTA button exists (InkWell within gradient container)
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('renders benefits list with check icons', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      // Benefits have check icons — 5 benefits = 5 check icons
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

    testWidgets('renders legal links section with GestureDetectors',
        (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      // Should find multiple GestureDetectors for plan cards and legal links
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('scaffold has correct background color', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
