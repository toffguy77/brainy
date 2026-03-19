import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/constants/app_constants.dart';

void main() {
  group('YooKassa subscription constants', () {
    test('monthly price is 299 RUB', () {
      expect(AppConstants.monthlyPriceRub, 299.0);
    });

    test('yearly price is 1990 RUB', () {
      expect(AppConstants.yearlyPriceRub, 1990.0);
    });

    test('yearly price is cheaper per month than monthly', () {
      final yearlyPerMonth = AppConstants.yearlyPriceRub / 12;
      expect(yearlyPerMonth, lessThan(AppConstants.monthlyPriceRub));
    });

    test('Hive keys are defined and non-empty', () {
      expect(AppConstants.subscriptionStatusKey, isNotEmpty);
      expect(AppConstants.subscriptionExpiresAtKey, isNotEmpty);
      expect(AppConstants.subscriptionPlanKey, isNotEmpty);
    });

    test('Hive keys are unique', () {
      final keys = {
        AppConstants.subscriptionStatusKey,
        AppConstants.subscriptionExpiresAtKey,
        AppConstants.subscriptionPlanKey,
      };
      expect(keys.length, 3);
    });

    test('Hive keys have expected values', () {
      expect(AppConstants.subscriptionStatusKey, 'subscriptionStatus');
      expect(AppConstants.subscriptionExpiresAtKey, 'subscriptionExpiresAt');
      expect(AppConstants.subscriptionPlanKey, 'subscriptionPlan');
    });

    test('YooKassa client key and shop ID are defined', () {
      expect(AppConstants.yookassaClientKey, isNotNull);
      expect(AppConstants.yookassaShopId, isNotNull);
    });

    test('YooKassa client key and shop ID are non-empty', () {
      expect(AppConstants.yookassaClientKey, isNotEmpty);
      expect(AppConstants.yookassaShopId, isNotEmpty);
    });

    test('prices are positive', () {
      expect(AppConstants.monthlyPriceRub, greaterThan(0));
      expect(AppConstants.yearlyPriceRub, greaterThan(0));
    });

    test('yearly price is greater than monthly price', () {
      expect(AppConstants.yearlyPriceRub, greaterThan(AppConstants.monthlyPriceRub));
    });

    test('yearly savings are significant (at least 40%)', () {
      final yearlyPerMonth = AppConstants.yearlyPriceRub / 12;
      final savings = 1 - (yearlyPerMonth / AppConstants.monthlyPriceRub);
      expect(savings, greaterThan(0.40));
    });
  });
}
