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

import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../constants/app_constants.dart';
import 'device_id_service.dart';

/// Subscription plan types.
enum SubscriptionPlan { monthly, yearly }

/// Result of a purchase or subscription check attempt.
enum BrainyPurchaseResult { success, cancelled, error }

class SubscriptionService {
  SubscriptionService._();

  static final _functions = FirebaseFunctions.instance;

  static bool _backendChecked = false;

  static Future<void> initialize() async {
    // Load cached subscription status from Hive.
    // Backend verification happens lazily on first isPremium() call.
    _loadCache();
  }

  static void _loadCache() {
    try {
      final box = Hive.box(AppConstants.userBox);
      final expiresAtMs = box.get(AppConstants.subscriptionExpiresAtKey) as int?;
      if (expiresAtMs != null) {
        final expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresAtMs);
        _cachedIsPremium = expiresAt.isAfter(DateTime.now());
        _cachedExpiresAt = expiresAt;
        _cachedPlan = box.get(AppConstants.subscriptionPlanKey) as String?;
      }
    } catch (e) {
      debugPrint('[SubscriptionService] Error loading cache: $e');
    }
  }

  static bool? _cachedIsPremium;
  static DateTime? _cachedExpiresAt;
  static String? _cachedPlan;

  static Future<void> _verifyWithBackend() async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final result = await _functions
          .httpsCallable('checkSubscription')
          .call<Map<String, dynamic>>({'deviceId': deviceId});

      final data = result.data;
      final isPremium = data['isPremium'] as bool? ?? false;
      final plan = data['plan'] as String?;
      final expiresAtStr = data['expiresAt'] as String?;

      if (isPremium && expiresAtStr != null) {
        final expiresAt = DateTime.parse(expiresAtStr);
        _cacheSubscription(
          isPremium: true,
          plan: plan,
          expiresAt: expiresAt,
        );
      } else {
        _cacheSubscription(isPremium: false, plan: null, expiresAt: null);
      }
    } catch (e) {
      debugPrint('[SubscriptionService] Backend unavailable, using cache');
      // Keep using cached value on network error
    }
  }

  static void _cacheSubscription({
    required bool isPremium,
    required String? plan,
    required DateTime? expiresAt,
  }) {
    _cachedIsPremium = isPremium;
    _cachedExpiresAt = expiresAt;
    _cachedPlan = plan;

    try {
      final box = Hive.box(AppConstants.userBox);
      box.put(AppConstants.subscriptionStatusKey, isPremium);
      if (expiresAt != null) {
        box.put(AppConstants.subscriptionExpiresAtKey,
            expiresAt.millisecondsSinceEpoch);
      } else {
        box.delete(AppConstants.subscriptionExpiresAtKey);
      }
      if (plan != null) {
        box.put(AppConstants.subscriptionPlanKey, plan);
      } else {
        box.delete(AppConstants.subscriptionPlanKey);
      }
    } catch (e) {
      debugPrint('[SubscriptionService] Error caching subscription: $e');
    }
  }

  /// Check if user has active premium subscription.
  /// Uses Hive cache first, falls back to backend check.
  static Future<bool> isPremium() async {
    // Check cache first
    if (_cachedIsPremium != null && _cachedExpiresAt != null) {
      if (_cachedExpiresAt!.isAfter(DateTime.now())) {
        return true;
      }
    }

    // Cache expired or missing — check backend (once per session)
    if (!_backendChecked) {
      _backendChecked = true;
      try {
        await _verifyWithBackend();
        return _cachedIsPremium ?? false;
      } catch (_) {
        return _cachedIsPremium ?? false;
      }
    }

    return _cachedIsPremium ?? false;
  }

  /// Purchase a subscription plan via YooKassa.
  /// Returns the payment result after the full flow completes.
  static Future<BrainyPurchaseResult> purchase(SubscriptionPlan plan) async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final planStr = plan == SubscriptionPlan.monthly ? 'monthly' : 'yearly';

      // For now, call createPayment directly without SDK tokenization.
      // The YooKassa payment form will be shown via confirmation URL.
      final result = await _functions
          .httpsCallable('createPayment')
          .call<Map<String, dynamic>>({
        'deviceId': deviceId,
        'plan': planStr,
      });

      final data = result.data;
      final status = data['status'] as String?;

      if (status == 'succeeded') {
        _cacheSubscription(
          isPremium: true,
          plan: planStr,
          expiresAt: DateTime.now().add(
            plan == SubscriptionPlan.monthly
                ? const Duration(days: 30)
                : const Duration(days: 365),
          ),
        );
        return BrainyPurchaseResult.success;
      }

      if (status == 'pending') {
        // Payment requires confirmation (3DS or redirect).
        // The confirmation URL should be opened by the caller.
        // Poll for completion.
        final confirmed = await _pollForConfirmation(deviceId);
        return confirmed
            ? BrainyPurchaseResult.success
            : BrainyPurchaseResult.error;
      }

      return BrainyPurchaseResult.error;
    } catch (e) {
      debugPrint('[SubscriptionService] Purchase error: $e');
      if (e is FirebaseFunctionsException && e.code == 'cancelled') {
        return BrainyPurchaseResult.cancelled;
      }
      return BrainyPurchaseResult.error;
    }
  }

  /// Poll backend for subscription confirmation after payment.
  static Future<bool> _pollForConfirmation(String deviceId) async {
    const maxAttempts = 15;
    const delay = Duration(seconds: 2);

    for (var i = 0; i < maxAttempts; i++) {
      await Future<void>.delayed(delay);
      try {
        final result = await _functions
            .httpsCallable('checkSubscription')
            .call<Map<String, dynamic>>({'deviceId': deviceId});

        final isPremium = result.data['isPremium'] as bool? ?? false;
        if (isPremium) {
          final plan = result.data['plan'] as String?;
          final expiresAtStr = result.data['expiresAt'] as String?;
          _cacheSubscription(
            isPremium: true,
            plan: plan,
            expiresAt:
                expiresAtStr != null ? DateTime.parse(expiresAtStr) : null,
          );
          return true;
        }
      } catch (_) {
        // Continue polling
      }
    }
    return false;
  }

  /// Check subscription status with backend (replaces restorePurchases).
  static Future<BrainyPurchaseResult> checkSubscription() async {
    try {
      await _verifyWithBackend();
      return (_cachedIsPremium ?? false)
          ? BrainyPurchaseResult.success
          : BrainyPurchaseResult.error;
    } catch (_) {
      return BrainyPurchaseResult.error;
    }
  }
}

/// Premium status provider.
/// Call `ref.invalidate(isPremiumProvider)` after a purchase to refresh.
final isPremiumProvider = FutureProvider<bool>((ref) async {
  return SubscriptionService.isPremium();
});
