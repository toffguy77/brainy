// --- RevenueCat implementation (commented out for YooKassa migration) ---
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
// import '../../constants/app_constants.dart';
//
// /// Result of a purchase or restore attempt.
// enum BrainyPurchaseResult { success, cancelled, error }
//
// class SubscriptionService {
//   SubscriptionService._();
//
//   static Future<void> initialize() async {
//     if (kDebugMode) {
//       await Purchases.setLogLevel(LogLevel.debug);
//     }
//     final config = PurchasesConfiguration(AppConstants.revenueCatApiKey);
//     if (Platform.isIOS) {
//       config.store = Store.appStore;
//     } else if (Platform.isAndroid) {
//       config.store = Store.playStore;
//     }
//     await Purchases.configure(config);
//   }
//
//   static Future<bool> isPremium() async {
//     try {
//       final customerInfo = await Purchases.getCustomerInfo();
//       return customerInfo.entitlements.active
//           .containsKey(AppConstants.revenueCatEntitlement);
//     } catch (_) {
//       return false;
//     }
//   }
//
//   static Future<List<Package>> getAvailablePackages() async {
//     try {
//       final offerings = await Purchases.getOfferings();
//       final offering =
//           offerings.getOffering(AppConstants.revenueCatOfferingId) ??
//               offerings.current;
//       return offering?.availablePackages ?? [];
//     } catch (e) {
//       return [];
//     }
//   }
//
//   static Future<BrainyPurchaseResult> purchasePackage(Package package) async {
//     try {
//       final result = await Purchases.purchase(PurchaseParams.package(package));
//       final active = result.customerInfo.entitlements.active
//           .containsKey(AppConstants.revenueCatEntitlement);
//       return active ? BrainyPurchaseResult.success : BrainyPurchaseResult.error;
//     } on PlatformException catch (e) {
//       final errorCode = PurchasesErrorHelper.getErrorCode(e);
//       if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
//         return BrainyPurchaseResult.cancelled;
//       }
//       return BrainyPurchaseResult.error;
//     } catch (_) {
//       return BrainyPurchaseResult.error;
//     }
//   }
//
//   static Future<BrainyPurchaseResult> restorePurchases() async {
//     try {
//       final customerInfo = await Purchases.restorePurchases();
//       final active = customerInfo.entitlements.active
//           .containsKey(AppConstants.revenueCatEntitlement);
//       return active ? BrainyPurchaseResult.success : BrainyPurchaseResult.error;
//     } on PlatformException catch (e) {
//       final errorCode = PurchasesErrorHelper.getErrorCode(e);
//       if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
//         return BrainyPurchaseResult.cancelled;
//       }
//       return BrainyPurchaseResult.error;
//     } catch (_) {
//       return BrainyPurchaseResult.error;
//     }
//   }
// }
// --- End RevenueCat implementation ---

// --- YooKassa implementation (commented out — payments not yet deployed) ---
// Full YooKassa + Cloud Functions implementation is on branch feat/yookassa-payment
// (commit 3b9684a). Uncomment when Cloud Functions are deployed and YooKassa
// credentials are configured. See brainy-tasks/TASK_10_1_yookassa.md for details.
// --- End YooKassa implementation ---

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Subscription plan types.
enum SubscriptionPlan { monthly, yearly }

/// Result of a purchase or subscription check attempt.
enum BrainyPurchaseResult { success, cancelled, error }

class SubscriptionService {
  SubscriptionService._();

  /// No-op until payment backend is deployed.
  static Future<void> initialize() async {}

  /// Premium is not available yet — always returns false.
  static Future<bool> isPremium() async => false;
}

/// Premium status provider.
/// Call `ref.invalidate(isPremiumProvider)` after a purchase to refresh.
final isPremiumProvider = FutureProvider<bool>((ref) async {
  return SubscriptionService.isPremium();
});
