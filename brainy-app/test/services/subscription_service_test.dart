import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/shared/services/subscription_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SubscriptionService', () {
    group('BrainyPurchaseResult', () {
      test('has all expected values', () {
        expect(BrainyPurchaseResult.values, hasLength(3));
        expect(
            BrainyPurchaseResult.values, contains(BrainyPurchaseResult.success));
        expect(BrainyPurchaseResult.values,
            contains(BrainyPurchaseResult.cancelled));
        expect(
            BrainyPurchaseResult.values, contains(BrainyPurchaseResult.error));
      });

      test('values have correct names', () {
        expect(BrainyPurchaseResult.success.name, 'success');
        expect(BrainyPurchaseResult.cancelled.name, 'cancelled');
        expect(BrainyPurchaseResult.error.name, 'error');
      });
    });

    group('SubscriptionPlan', () {
      test('has monthly and yearly values', () {
        expect(SubscriptionPlan.values, hasLength(2));
        expect(SubscriptionPlan.values, contains(SubscriptionPlan.monthly));
        expect(SubscriptionPlan.values, contains(SubscriptionPlan.yearly));
      });

      test('values have correct names', () {
        expect(SubscriptionPlan.monthly.name, 'monthly');
        expect(SubscriptionPlan.yearly.name, 'yearly');
      });
    });

    group('coming soon mode', () {
      test('isPremium always returns false', () async {
        final result = await SubscriptionService.isPremium();
        expect(result, isFalse);
      });

      test('isPremium returns false on consecutive calls', () async {
        expect(await SubscriptionService.isPremium(), isFalse);
        expect(await SubscriptionService.isPremium(), isFalse);
      });

      test('initialize completes without error', () async {
        await expectLater(SubscriptionService.initialize(), completes);
      });
    });
  });
}
