import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../constants/app_constants.dart';

class RevenueCatService {
  RevenueCatService._();

  static Future<void> initialize() async {
    final apiKey = AppConstants.revenueCatApiKey;
    final config = PurchasesConfiguration(apiKey);
    if (Platform.isIOS) {
      config.store = Store.appStore;
    } else if (Platform.isAndroid) {
      config.store = Store.playStore;
    }
    await Purchases.configure(config);
  }

  static Future<bool> hasProEntitlement() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active
          .containsKey(AppConstants.revenueCatEntitlement);
    } catch (_) {
      return false;
    }
  }
}
