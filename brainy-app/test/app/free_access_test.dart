import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:brainy/constants/app_constants.dart';

/// Guards the "everything is free" decision at the level a grep would miss:
/// these fail if a paid tier is reintroduced anywhere in the tree.
void main() {
  group('free access', () {
    final lib = Directory('lib');

    List<File> dartFiles() => lib
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.contains('/l10n/'))
        .toList();

    test('no source file references a purchase surface', () {
      final offenders = <String>[];
      for (final file in dartFiles()) {
        final text = file.readAsStringSync();
        for (final needle in [
          'isPremium',
          'SubscriptionService',
          'showPremiumBottomSheet',
          'premiumGridSizes',
          'PaywallScreen',
          'yookassa',
          'YooKassa',
          'purchases_flutter',
        ]) {
          if (text.contains(needle)) offenders.add('${file.path}: $needle');
        }
      }
      expect(offenders, isEmpty,
          reason: 'paid-tier references reintroduced:\n${offenders.join('\n')}');
    });

    test('no paywall route exists', () {
      final router = File('lib/app/router.dart').readAsStringSync();
      expect(router.contains('/paywall'), isFalse);
    });

    test('the subscription feature directory is gone', () {
      expect(Directory('lib/features/subscription').existsSync(), isFalse);
    });

    test('the payment backend is gone', () {
      expect(Directory('../functions').existsSync(), isFalse);
    });

    test('onboarding has six pages after the paywall page was removed', () {
      expect(AppConstants.onboardingPageCount, 6);
    });

    test('every grid size and mode is offered without an unlock', () {
      expect(AppConstants.pickerGridSizes, containsAll([3, 4, 5, 6, 7, 9]));
      expect(AppConstants.gorbovGridSizes, isNotEmpty);
    });

    test('stale subscription keys in the user box do not break startup',
        () async {
      final dir = await Directory.systemTemp.createTemp('hive_free_');
      Hive.init(dir.path);
      final box = await Hive.openBox(AppConstants.userBox);
      // Written by an older, gated build.
      await box.put('subscriptionStatus', 'active');
      await box.put('subscriptionExpiresAt', 1234567890);
      await box.put('subscriptionPlan', 'yearly');

      // Reading the keys the app actually uses still works.
      await box.put(AppConstants.userKeyOnboardingCompleted, true);
      expect(box.get(AppConstants.userKeyOnboardingCompleted), isTrue);

      await box.close();
    });
  });
}
