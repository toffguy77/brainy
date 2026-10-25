import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/l10n/app_localizations.dart';
import 'package:brainy/shared/services/notification_service.dart';

void main() {
  group('notification text', () {
    late AppLocalizations ru;
    late AppLocalizations en;

    setUpAll(() async {
      ru = await AppLocalizations.delegate.load(const Locale('ru'));
      en = await AppLocalizations.delegate.load(const Locale('en'));
    });

    test('every motivation variant is non-empty in both locales', () {
      for (var i = 0; i < NotificationService.variantCount; i++) {
        expect(NotificationService.motivationVariant(ru, i), isNotEmpty);
        expect(NotificationService.motivationVariant(en, i), isNotEmpty);
      }
    });

    test('every streak variant is non-empty in both locales', () {
      for (var i = 0; i < NotificationService.variantCount; i++) {
        expect(NotificationService.streakVariant(ru, i, 5), isNotEmpty);
        expect(NotificationService.streakVariant(en, i, 5), isNotEmpty);
      }
    });

    test('motivation variants are distinct — the pool is not one repeated string',
        () {
      final seen = {
        for (var i = 0; i < NotificationService.variantCount; i++)
          NotificationService.motivationVariant(ru, i)
      };
      expect(seen.length, NotificationService.variantCount);
    });

    test('streak variants that mention the count interpolate it', () {
      // Not every variant names the number, but those that do must substitute.
      var interpolated = 0;
      for (var i = 0; i < NotificationService.variantCount; i++) {
        final text = NotificationService.streakVariant(ru, i, 42);
        expect(text, isNot(contains('{count}')),
            reason: 'variant $i left the placeholder unsubstituted');
        if (text.contains('42')) interpolated++;
      }
      expect(interpolated, greaterThan(0));
    });

    test('no variant leaks the old {N} placeholder format', () {
      for (var i = 0; i < NotificationService.variantCount; i++) {
        expect(NotificationService.streakVariant(en, i, 7), isNot(contains('{N}')));
        expect(NotificationService.motivationVariant(en, i), isNot(contains('{N}')));
      }
    });

    test('the daily index is deterministic for a given day', () {
      final day = DateTime(2026, 8, 1);
      expect(NotificationService.variantIndexFor(day),
          NotificationService.variantIndexFor(day));
    });

    test('the index changes from one day to the next', () {
      final a = NotificationService.variantIndexFor(DateTime(2026, 8, 1));
      final b = NotificationService.variantIndexFor(DateTime(2026, 8, 2));
      expect(a, isNot(b));
    });

    test('the index always lands inside the pool', () {
      for (var d = 0; d < 400; d++) {
        final index =
            NotificationService.variantIndexFor(DateTime(2026, 1, 1).add(Duration(days: d)));
        expect(index, inInclusiveRange(0, NotificationService.variantCount - 1));
      }
    });

    test('both locales expose the same number of variants', () {
      // The index is computed once and used for whichever locale is active, so
      // an unequal pool size would index out of range.
      for (var i = 0; i < NotificationService.variantCount; i++) {
        expect(NotificationService.motivationVariant(ru, i), isNotEmpty);
        expect(NotificationService.motivationVariant(en, i), isNotEmpty);
      }
    });

    test('russian and english variants actually differ', () {
      expect(NotificationService.motivationVariant(ru, 0),
          isNot(NotificationService.motivationVariant(en, 0)));
    });
  });
}
