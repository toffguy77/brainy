import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    group('grid sizes', () {
      test('free grid sizes are 3, 4, 5', () {
        expect(AppConstants.freeGridSizes, [3, 4, 5]);
      });

      test('premium grid sizes are 6, 7, 9', () {
        expect(AppConstants.premiumGridSizes, [6, 7, 9]);
      });

      test('allGridSizes contains all sizes', () {
        expect(AppConstants.allGridSizes,
            containsAll([...AppConstants.freeGridSizes, ...AppConstants.premiumGridSizes]));
      });

      test('picker grid sizes exclude 9x9 Gorbov', () {
        expect(AppConstants.pickerGridSizes, [3, 4, 5, 6, 7]);
        expect(AppConstants.pickerGridSizes, isNot(contains(9)));
      });
    });

    group('star thresholds', () {
      test('all grid sizes have thresholds', () {
        for (final size in AppConstants.allGridSizes) {
          expect(AppConstants.starThresholds.containsKey(size), isTrue,
              reason: 'Missing threshold for grid size $size');
        }
      });

      test('each threshold has exactly 2 values [3-star, 2-star]', () {
        for (final entry in AppConstants.starThresholds.entries) {
          expect(entry.value, hasLength(2),
              reason: 'Grid size ${entry.key} should have 2 threshold values');
        }
      });

      test('3-star threshold is less than 2-star threshold', () {
        for (final entry in AppConstants.starThresholds.entries) {
          expect(entry.value[0], lessThan(entry.value[1]),
              reason: 'Grid size ${entry.key}: 3-star (${entry.value[0]}) should be < 2-star (${entry.value[1]})');
        }
      });

      test('thresholds increase with grid size', () {
        final sizes = List<int>.from(AppConstants.allGridSizes)..sort();
        for (var i = 1; i < sizes.length; i++) {
          final prev = AppConstants.starThresholds[sizes[i - 1]]!;
          final curr = AppConstants.starThresholds[sizes[i]]!;
          expect(curr[0], greaterThan(prev[0]),
              reason: '3-star threshold for ${sizes[i]} should be > ${sizes[i - 1]}');
        }
      });
    });

    group('target times', () {
      test('all grid sizes have target times', () {
        for (final size in AppConstants.allGridSizes) {
          expect(AppConstants.targetTimes.containsKey(size), isTrue);
        }
      });

      test('target times increase with grid size', () {
        final sizes = List<int>.from(AppConstants.allGridSizes)..sort();
        for (var i = 1; i < sizes.length; i++) {
          expect(AppConstants.targetTimes[sizes[i]]!,
              greaterThan(AppConstants.targetTimes[sizes[i - 1]]!));
        }
      });
    });

    group('XP thresholds', () {
      test('level 1 starts at 0 XP', () {
        expect(AppConstants.xpThresholds[1], 0);
      });

      test('has 20 levels', () {
        expect(AppConstants.xpThresholds.length, 20);
      });

      test('XP requirements increase with level', () {
        for (var level = 2; level <= 20; level++) {
          expect(AppConstants.xpThresholds[level]!,
              greaterThan(AppConstants.xpThresholds[level - 1]!));
        }
      });
    });

    group('coins', () {
      test('streak rewards increase with streak length', () {
        expect(AppConstants.coinsForStreak30,
            greaterThan(AppConstants.coinsForStreak7));
        expect(AppConstants.coinsForStreak7,
            greaterThan(AppConstants.coinsPerSession));
      });
    });

    group('RevenueCat', () {
      test('product IDs are defined', () {
        expect(AppConstants.productIdMonthly, 'brainy_pro_monthly');
        expect(AppConstants.productIdYearly, 'brainy_pro_yearly');
        expect(AppConstants.productIdFamily, 'brainy_pro_family');
      });

      test('entitlement is brainy_pro', () {
        expect(AppConstants.revenueCatEntitlement, 'brainy_pro');
      });
    });

    group('legal URLs', () {
      test('all legal URLs use the same base', () {
        expect(AppConstants.privacyPolicyUrlRu, startsWith(AppConstants.legalBaseUrl));
        expect(AppConstants.privacyPolicyUrlEn, startsWith(AppConstants.legalBaseUrl));
        expect(AppConstants.termsUrlRu, startsWith(AppConstants.legalBaseUrl));
        expect(AppConstants.termsUrlEn, startsWith(AppConstants.legalBaseUrl));
      });
    });
  });
}
