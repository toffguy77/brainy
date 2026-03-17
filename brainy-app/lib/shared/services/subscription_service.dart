import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../constants/app_constants.dart';

/// Result of a purchase or restore attempt.
enum PurchaseResult { success, cancelled, error }

class SubscriptionService {
  SubscriptionService._();

  static Future<void> initialize() async {
    if (kDebugMode) {
      await Purchases.setLogLevel(LogLevel.debug);
    }
    final config = PurchasesConfiguration(AppConstants.revenueCatApiKey);
    if (Platform.isIOS) {
      config.store = Store.appStore;
    } else if (Platform.isAndroid) {
      config.store = Store.playStore;
    }
    await Purchases.configure(config);
  }

  static Future<bool> isPremium() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active
          .containsKey(AppConstants.revenueCatEntitlement);
    } catch (_) {
      return false;
    }
  }

  static Future<List<Package>> getAvailablePackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      final offering =
          offerings.getOffering(AppConstants.revenueCatOfferingId) ??
              offerings.current;
      return offering?.availablePackages ?? [];
    } catch (_) {
      return [];
    }
  }

  static Future<PurchaseResult> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      final active = customerInfo.entitlements.active
          .containsKey(AppConstants.revenueCatEntitlement);
      return active ? PurchaseResult.success : PurchaseResult.error;
    } on PlatformException catch (e) {
      if (e.code == '1' ||
          e.details?['userCancelled'] == true ||
          e.message?.contains('userCancelled') == true) {
        return PurchaseResult.cancelled;
      }
      return PurchaseResult.error;
    } catch (_) {
      return PurchaseResult.error;
    }
  }

  static Future<PurchaseResult> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final active = customerInfo.entitlements.active
          .containsKey(AppConstants.revenueCatEntitlement);
      return active ? PurchaseResult.success : PurchaseResult.error;
    } on PlatformException catch (e) {
      if (e.code == '1' ||
          e.details?['userCancelled'] == true ||
          e.message?.contains('userCancelled') == true) {
        return PurchaseResult.cancelled;
      }
      return PurchaseResult.error;
    } catch (_) {
      return PurchaseResult.error;
    }
  }
}

/// Premium status provider.
/// Call `ref.invalidate(isPremiumProvider)` after a purchase to refresh.
final isPremiumProvider = FutureProvider<bool>((ref) async {
  return SubscriptionService.isPremium();
});
