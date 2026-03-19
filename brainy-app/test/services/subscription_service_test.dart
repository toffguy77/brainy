import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/shared/services/subscription_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SubscriptionService', () {
    late String hivePath;

    setUp(() async {
      hivePath = '/tmp/hive_test_${DateTime.now().millisecondsSinceEpoch}';
      Hive.init(hivePath);
      await Hive.openBox(AppConstants.userBox);
    });

    tearDown(() async {
      await Hive.deleteBoxFromDisk(AppConstants.userBox);
      await Hive.close();
    });

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

    group('Hive cache', () {
      test('isPremium returns false when no cache exists', () async {
        // With no backend available and no cache, should return false
        final result = await SubscriptionService.isPremium();
        expect(result, isFalse);
      });

      test('isPremium returns true when valid cache exists with future expiry',
          () async {
        final box = Hive.box(AppConstants.userBox);
        final futureExpiry = DateTime.now().add(const Duration(days: 30));
        await box.put(AppConstants.subscriptionStatusKey, true);
        await box.put(AppConstants.subscriptionExpiresAtKey,
            futureExpiry.millisecondsSinceEpoch);
        await box.put(AppConstants.subscriptionPlanKey, 'monthly');

        // Re-initialize to load from cache
        await SubscriptionService.initialize();
        final result = await SubscriptionService.isPremium();
        expect(result, isTrue);
      });

      test('isPremium returns false when cache has expired', () async {
        final box = Hive.box(AppConstants.userBox);
        final pastExpiry = DateTime.now().subtract(const Duration(days: 1));
        await box.put(AppConstants.subscriptionStatusKey, true);
        await box.put(AppConstants.subscriptionExpiresAtKey,
            pastExpiry.millisecondsSinceEpoch);
        await box.put(AppConstants.subscriptionPlanKey, 'monthly');

        await SubscriptionService.initialize();
        final result = await SubscriptionService.isPremium();
        expect(result, isFalse);
      });

      test('checkSubscription returns error when backend is unavailable',
          () async {
        final result = await SubscriptionService.checkSubscription();
        expect(result, equals(BrainyPurchaseResult.error));
      });

      test('Hive box stores subscription data correctly', () async {
        final box = Hive.box(AppConstants.userBox);
        final expiresAt = DateTime.now().add(const Duration(days: 365));

        await box.put(AppConstants.subscriptionStatusKey, true);
        await box.put(AppConstants.subscriptionExpiresAtKey,
            expiresAt.millisecondsSinceEpoch);
        await box.put(AppConstants.subscriptionPlanKey, 'yearly');

        expect(box.get(AppConstants.subscriptionStatusKey), isTrue);
        expect(box.get(AppConstants.subscriptionExpiresAtKey),
            expiresAt.millisecondsSinceEpoch);
        expect(box.get(AppConstants.subscriptionPlanKey), 'yearly');
      });

      test('cache with far future expiry is premium', () async {
        final box = Hive.box(AppConstants.userBox);
        final farFuture = DateTime.now().add(const Duration(days: 3650));
        await box.put(AppConstants.subscriptionStatusKey, true);
        await box.put(AppConstants.subscriptionExpiresAtKey,
            farFuture.millisecondsSinceEpoch);
        await box.put(AppConstants.subscriptionPlanKey, 'yearly');

        await SubscriptionService.initialize();
        final result = await SubscriptionService.isPremium();
        expect(result, isTrue);
      });
    });
  });
}
