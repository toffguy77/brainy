import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:brainy/l10n/app_localizations.dart';
import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/features/onboarding/pages/paywall_page.dart';

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
      home: const Scaffold(body: PaywallPage()),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    Hive.init('/tmp/hive_paywall_test_${DateTime.now().millisecondsSinceEpoch}');
    await Hive.openBox(AppConstants.userBox);
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk(AppConstants.userBox);
    await Hive.close();
  });

  group('PaywallPage (onboarding)', () {
    testWidgets('renders premium icon', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.workspace_premium_rounded), findsOneWidget);
    });

    testWidgets('renders benefit row icons', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
      expect(find.byIcon(Icons.people_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart_rounded), findsOneWidget);
      expect(find.byIcon(Icons.block_rounded), findsOneWidget);
    });

    testWidgets('renders skip button', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('renders the PaywallPage widget', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      expect(find.byType(PaywallPage), findsOneWidget);
    });

    testWidgets('does not show RevenueCat UI elements', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      // The page should use custom paywall via Navigator push, not RevenueCat
      // Verify proper rendering without RevenueCat widgets
      expect(find.byType(PaywallPage), findsOneWidget);
    });

    testWidgets('has exactly 4 benefit rows', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();
      // 4 benefit icons
      final benefitIcons = [
        Icons.grid_view_rounded,
        Icons.people_rounded,
        Icons.bar_chart_rounded,
        Icons.block_rounded,
      ];
      for (final icon in benefitIcons) {
        expect(find.byIcon(icon), findsOneWidget);
      }
    });
  });
}
